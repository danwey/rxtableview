//
//  DownLoadManager.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/11.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import RxSwift
import AVFoundation
import MobileCoreServices

enum DownloadStatus {
    case prepare
    case download(progress:Float)
    case stop
    case error(msg:String)
}

protocol DownLoadItemable {
    var filename: String { get }
    var fileurl: String { get }
    var saveurl: String { get }
    var status: DownloadStatus {get set}
}

extension DownLoadItemable {
    var saveurl: String {
        let filefullpath = "\(NSHomeDirectory())/Library/Caches/temp" + "/" + "M500001J4FTi3A2UH8.mp3"
        return filefullpath
    }
}

class DownLoadManager: NSObject {
    
    //output
    let listVariable = Variable<[DownLoadItemable]>([])
    let valueVariable = Variable<Float>(0)

    //input
//    let loginEnabled: Driver<Bool>
    
    //功能声明 只对 只下载 music 和 video
    //功能声明 此类还没做多线程 功能，在多线程调用 可能 会 出现问题
    //添加键值 存储
    //添加 已下载 功能
    
    
    //下载中的
    fileprivate(set) var list:[DownLoadItemable] = []
    //已下载的
    fileprivate(set) var listed:[DownLoadItemable] = []
    
    fileprivate var crrent:Int = 0
    fileprivate var task:URLSessionDataTask?
    fileprivate var session:URLSession?
    fileprivate var handle:FileHandle?
    fileprivate var savedir:String
    fileprivate var offset:UInt64 = 0
    fileprivate var currenturl:URL?
    fileprivate var filefullpath:String?

    fileprivate var defaults:UserDefaults
    fileprivate var defaultsed:UserDefaults
    fileprivate let semaphore = DispatchSemaphore(value: 1)
    fileprivate var loadings = NSMutableArray()
    
    let data : Data
    
    init(_ dir : String ) {
        defaults = UserDefaults(suiteName: "download")!
        defaultsed = UserDefaults(suiteName: "dowwloaded")!
        savedir = dir
        
        let path = Bundle.main.path(forResource: "郑俊弘 - 投降吧", ofType: "mp3")
        let handle = FileHandle(forReadingAtPath: path!)
        data = (handle?.readDataToEndOfFile())!
        handle?.closeFile()
        
        super.init()
        
        let dstPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        savedir =  (dstPath as NSString).appendingPathComponent(dir)
        
//        listed = defaultsed.dictionaryRepresentation().keys.map{ DownLoadItemable(filename:$0,fileurl:$0) }
        
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    deinit {
        session?.invalidateAndCancel()
    }
    //添加下载项
    func add(_ item : DownLoadItemable) {
        semaphore.wait()
        //list.contains(item)
        if !false && defaults.string(forKey: item.fileurl) == nil {
            list.append(item)
            listVariable.value = list
        }
        semaphore.signal()
    }
    //移除下载项
    func remove(_ index:Int) {
        semaphore.wait()
        if index < list.count {
            if (index > crrent) {
                crrent -= 1
            }
            list.remove(at: index)
            listVariable.value = list
            //还要删除对应的文件
        }
        semaphore.signal()
    }
    var currentdl : DownLoadItemable {
        return list[crrent]
    }
    //停止下载
    func stop() {
        task?.cancel()
    }
    //开始下载
    func start(_ index:Int) {
        if index >= list.count {
            print("没有此下载项目")
            return
        }
        if (crrent == index) {
            switch list[index].status {
            case .stop:
                print("stop")
            case .prepare:
                print("prepare")
            default:
                print("请先停止")
                return
            }
        }
        stop()//停止先前的下载
        crrent = index
        
        let aa = list[crrent].fileurl
        let currenturl = URL.init(string: aa)
        
        let request = URLRequest(url: currenturl!)
        
        if !FileManager.default.fileExists(atPath: savedir) {
            do {
                try FileManager.default.createDirectory(atPath: savedir, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        
        filefullpath = savedir + "/" + currenturl!.lastPathComponent
//        list[crrent].saveurl = filefullpath!
        print(filefullpath!)
        FileManager.default.createFile(atPath: filefullpath!, contents: nil, attributes: nil)
        
        handle = FileHandle(forWritingAtPath: filefullpath!)
        offset = handle!.seekToEndOfFile()
        print("offset:\(offset)")
//        request.setValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        
        task = session?.dataTask(with: request)
        task?.resume()
    }
}


struct DownloadError: Error {
    var msg:String
}
extension DownLoadManager : URLSessionDataDelegate {
    //开始下载
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        //        print(response.mimeType)
        print("start")
        if ( dataTask.countOfBytesExpectedToReceive > 0 ) {//&& response.mimeType!.contains("video")
            completionHandler(.allow)
        }else {
            urlSession(session, task: dataTask, didCompleteWithError: DownloadError.init(msg: "此项目下载完了"))
        }
    }
    //下载进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let offset = Int64(self.offset)
        let progress = Float(dataTask.countOfBytesReceived + offset)/Float(dataTask.countOfBytesExpectedToReceive + offset)
        list[crrent].status = DownloadStatus.download(progress:progress)
        listVariable.value = list
        valueVariable.value = progress
        handle?.write(data)
        print(data.count)
        print("progress:\(progress)")
    }
    //下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            print("finish")
            remove(crrent)
            crrent = 0
        }else {
            //要区别什么 error 和 stop
//            let error = error as! DownloadError
//            print(error.msg)
//            list[crrent].status = DownloadStatus.stop //DownloadStatus.error(msg: "下载失败")
//            do {
//                try FileManager.default.removeItem(atPath: filefullpath!)
//            } catch {
//                print("remove file error")
//            }
        }
//        valueVariable.value = 1.0
        listVariable.value = list
        handle?.closeFile()
        handle = nil
    }
}

extension DownLoadManager : AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        loadings.removeObject(identicalTo: loadingRequest)
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadings.add(loadingRequest)
        
//        let contentType1 = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "video/mp4" as CFString, nil)
//        let contentType = contentType1?.takeRetainedValue() as String?
//        loadingRequest.contentInformationRequest?.contentType = contentType
//        loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
//        loadingRequest.contentInformationRequest?.contentLength = 4536110//Int64(data.coun
//
//
//        let length = (loadingRequest.dataRequest?.requestedLength)!
//        if length == 2 {
//            loadingRequest.finishLoading()
//        }else {
//            var offset = 0
//            Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [weak self] (_) in
//                self?.aa(loadingRequest: loadingRequest, offset: offset, length: 1449)
//                offset = offset + 1449
//            })
//        }
        
        return true
    }
    
    func proessLoadingRequest() {
        for loading in loadings {
            let loadingRequest = loading as! AVAssetResourceLoadingRequest
            let contentType1 = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "video/mp4" as CFString, nil)
            let contentType = contentType1?.takeRetainedValue() as String?
            loadingRequest.contentInformationRequest?.contentType = contentType
            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
            loadingRequest.contentInformationRequest?.contentLength = 4536110//Int64(data.coun
            
            let length = (loadingRequest.dataRequest?.requestedLength)!
            if length == 2 {
                loadingRequest.finishLoading()
            }else {
                var offset = 0
            }
        }
    }
    
    func aa(loadingRequest: AVAssetResourceLoadingRequest,offset:Int,length:Int) {
        print("offset:\(offset)")
        if (offset + length) > data.count { return }
        let newData = data.subdata(in: offset..<(offset + length))
        loadingRequest.dataRequest?.respond(with: newData)
        
        let arlr = Int((loadingRequest.dataRequest?.requestedOffset)!) + (loadingRequest.dataRequest?.requestedLength)!
        print("arlr:\(arlr)")
        if (offset + length >= arlr) {
            print("finish")
            loadingRequest.finishLoading()
        }
    }
    
}

