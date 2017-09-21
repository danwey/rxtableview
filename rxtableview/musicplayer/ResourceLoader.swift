//
//  ResourceLoader.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/19.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import AVFoundation
import MobileCoreServices

class ResurceLoader : NSObject {
    
    let data : Data
    
    override init() {
        let path = Bundle.main.path(forResource: "郑俊弘 - 投降吧", ofType: "mp3")
        let handle = FileHandle(forReadingAtPath: path!)
        data = (handle?.readDataToEndOfFile())!
        handle?.closeFile()
    }
}

extension ResurceLoader : AVAssetResourceLoaderDelegate {
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel loadingRequest: AVAssetResourceLoadingRequest) {
        print("cancel")
        
        print("requestedOffset:\(String(describing: loadingRequest.dataRequest?.requestedOffset))")
        print("currentOffset:\(String(describing: loadingRequest.dataRequest?.currentOffset))")
        print("requestedLength:\(String(describing: loadingRequest.dataRequest?.requestedLength))")
        
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForResponseTo authenticationChallenge: URLAuthenticationChallenge) -> Bool {
        print("shouldWaitForResponseTo")
        return true
    }
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, didCancel authenticationChallenge: URLAuthenticationChallenge) {
        print("didCancel")
    }
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
        print("loadingRequest")
        
        print("requestedOffset:\(String(describing: loadingRequest.dataRequest?.requestedOffset))")
        print("currentOffset:\(String(describing: loadingRequest.dataRequest?.currentOffset))")
        print("requestedLength:\(String(describing: loadingRequest.dataRequest?.requestedLength))")
        
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
            Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true, block: { [weak self] (_) in
                self?.aa(loadingRequest: loadingRequest, offset: offset, length: 1449)
                offset = offset + 1449
            })
        }
        
//        DispatchQueue.init(label: "test").async { [weak self] () in
//            sleep(1)
//            let contentType1 = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, "video/mp4" as CFString, nil)
//            let contentType = contentType1?.takeRetainedValue() as String?
//
//            loadingRequest.contentInformationRequest?.contentType = contentType
//            loadingRequest.contentInformationRequest?.isByteRangeAccessSupported = true
//
//            loadingRequest.contentInformationRequest?.contentLength = 4536110//Int64(data.count)
//
//            var length = (loadingRequest.dataRequest?.requestedLength)!
//            print("length:\(length)")
//
//            let offset = Int((loadingRequest.dataRequest?.currentOffset)!)
////            if length != 2 {
////                length = length/2
////            }
//            let newData = self?.data.subdata(in: offset..<(offset + length))
//            print("newData.count:\(newData!.count)")
//            loadingRequest.dataRequest?.respond(with: newData!)
//
//            let arlr = Int((loadingRequest.dataRequest?.requestedOffset)!) + (loadingRequest.dataRequest?.requestedLength)!
//            print("arlr:\(arlr)")
//            if (offset + length >= arlr) {
//                print("finish")
//                loadingRequest.finishLoading()
//            }
//        }
        
        
        return true
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
    
    func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForRenewalOfRequestedResource renewalRequest: AVAssetResourceRenewalRequest) -> Bool {
        print("renewalRequest")
        return true
    }
    
}

