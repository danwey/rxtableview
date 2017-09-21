//
//  DownloadSong.swift
//  rxtableview
//
//  Created by BmMac on 2017/8/31.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation

class DownloadSong : DownLoadItemable {
    
    var fileurl: String
    var filename: String
    var status: DownloadStatus
    
    init(fileurl:String,filename:String,status:DownloadStatus = .prepare) {
        self.filename = filename
        self.fileurl = fileurl
        self.status = status
    }
}
