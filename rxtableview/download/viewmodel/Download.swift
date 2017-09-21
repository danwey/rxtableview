//
//  Download.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/21.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

class DownLoad : NSObject {
    //参数
    var url : URL
    //内部变量
    fileprivate var length : Int64 = 0
    fileprivate var session : URLSession?
    fileprivate var task : URLSessionDataTask?
    fileprivate var handle : FileHandle?
    fileprivate var data : Data?
    fileprivate var loadingReq : AVAssetResourceLoadingRequest?
    fileprivate var readoffset = 0
    //方法
    init(url : URL) {
        self.url = url
        super.init()
        session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
    }
    deinit {
        session?.invalidateAndCancel()
    }
    func start() {
        
        var request = URLRequest(url: url)
        
        handle = FileHandle(forUpdatingAtPath: getsavePath())
        data = handle?.readDataToEndOfFile()
        
        if data == nil {
            data = Data()
        }
        length = Int64(data!.count)
        request.setValue("bytes=\(offset)-", forHTTPHeaderField: "Range")
        task = session?.dataTask(with: request)
        task?.resume()
    }
    func stop() {
        handle?.closeFile()
        task?.cancel()
    }
    //内部方法
    func getsavePath() -> String {
        let filename = url.lastPathComponent
        let dstPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first!
        let dir = (dstPath as NSString).appendingPathComponent("temp")
        let path = (dir as NSString).appendingPathComponent(filename)
        if !FileManager.default.fileExists(atPath: dir) {
            do {
                try FileManager.default.createDirectory(atPath: dir, withIntermediateDirectories: true, attributes: nil)
            } catch _ {}
        }
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        print(path)
        return path
    }
    
    var offset : Int64 {
        if let data = data {
            return Int64(data.count)
        }
        return 0
    }
}

extension DownLoad : URLSessionDataDelegate {
    //开始下载
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        length = self.offset + response.expectedContentLength
        completionHandler(.allow)
    }
    //下载进度
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let offset = self.offset
        let progress = Float(dataTask.countOfBytesReceived + offset)/Float(dataTask.countOfBytesExpectedToReceive + offset)
        handle?.write(data)
        self.data?.append(data)
        print("progress:\(progress)")
        proessLoadingRequest()
    }
    //下载完成
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if error == nil {
            if readoffset != length {
                proessLoadingRequest()
            }
            print("finish")
        }else {
            print(error!)
        }
        handle?.closeFile()
        handle = nil
    }
}

extension DownLoad : AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        loadingReq = nil
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        loadingReq = loadingRequest
        proessLoadingRequest()
        return true
    }
    
    func proessLoadingRequest() {
        objc_sync_enter(self)
        if let loadingReq = loadingReq,let data = data {
            let contentType1 = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "video/mp4" as CFString, nil)
            let contentType = contentType1?.takeRetainedValue() as String?
            loadingReq.contentInformationRequest?.contentType = contentType
            loadingReq.contentInformationRequest?.isByteRangeAccessSupported = true
            loadingReq.contentInformationRequest?.contentLength = length
            
            if loadingReq.dataRequest?.requestedLength == 2 {
                if data.count >= 2 {
                    let subData = data.subdata(in: 0..<2)
                    loadingReq.dataRequest?.respond(with: subData)
                    loadingReq.finishLoading()
                    self.loadingReq = nil
                }
            }else {
                let reqLength = Int((loadingReq.dataRequest?.requestedOffset)!) + (loadingReq.dataRequest?.requestedLength)!
                let newData = data.subdata(in: readoffset..<data.count)
                loadingReq.dataRequest?.respond(with: newData)
                readoffset = data.count
                if offset >= reqLength {
                    loadingReq.finishLoading()
                    self.loadingReq = nil
                }
            }
        }
        objc_sync_exit(self)
    }
}
