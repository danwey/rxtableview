//
//  WeiMusicManager.swift
//  WeiPlayer
//
//  Created by BmMac on 2017/8/28.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

//这句到时放到全局位置
//let manager = DownLoadManager("temp")

protocol MusicDelegate {
    func periodicTime(curduration:TimeInterval,duration:TimeInterval)
    func loadTime(progress: Float)
}

class WeiMusicManager:NSObject {
    
    static let share = WeiMusicManager()
    
    var player:AVPlayer?
    var playerItem:AVPlayerItem?
    var duration:TimeInterval = 0
    var curduration:TimeInterval = 0
    var delegete:MusicDelegate?
    var url:URL?
    var currentIndex:Int = 0
    public var list:[Song] = []

    var playerPeriodicObserver:Any?
    //初起化
    private override init() {
        super.init()
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setActive(true)
            try session.setCategory(AVAudioSessionCategoryPlayback)
        } catch {
            print(error)
        }
    }
    func start() {
//        let song = list[currentIndex]
//        manager.start(currentIndex)
        
//        let url = URL(string: "http://dl.stream.qqmusic.qq.com/M500003LMrZn0lum8Z.mp3?continfo=DC97053378A21E19BC806A7FF6B5490E651EE9CA2112EC86&vkey=951224A8F50620D893475573CE0C5FED65D801DE39D46F5C64218578AF2955FF171077C3EA53A613A95A916A85EF7BAF5B484EE3252B4C7A&guid=6b40cbfa088052977226a453a80fdc5937d7c250&fromtag=43&uin=0")!//URL.init(fileURLWithPath: song.url!)
        
        let down = DownLoad(url: URL(string: "http://14.29.86.17/musicoc.music.tc.qq.com/M500002bvqCh4BVDd1.mp3?continfo=E25299986B35B3B06B2F1A76CF82656C43953FFE0C858839&vkey=687EB63539CBE22CA9F7378870C56C19248BC7246FC88DFF231231795E2587B83A219A5DB238564ABCD6F09F96F7A8EEC774B25302F58D17&guid=6b40cbfa088052977226a453a80fdc5937d7c250&fromtag=43&uin=0")!)
        down.start()
        var newurl = URLComponents(url: down.url, resolvingAgainstBaseURL: false)
        newurl?.scheme = "streaming"
        let asset = AVURLAsset(url: newurl!.url!)
        asset.resourceLoader.setDelegate(down, queue: DispatchQueue.main)
        playerItem = AVPlayerItem(asset: asset)
        
        playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        
        player = AVPlayer(playerItem: playerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(WeiMusicManager.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(30,30), queue: nil, using: { [weak self] (time) in
            print("\(time.seconds)")
            self?.curduration = time.seconds
            self?.delegete?.periodicTime(curduration: (self?.curduration)!, duration: (self?.duration)!)
        })
        updateLockScreenInfo()
    }
    //停止
    func stop() {
        print("stop")
        if let playerItem = playerItem {
            playerItem.removeObserver(self, forKeyPath: "status")
        }
        if let player = player {
            if let playerPeriodicObserver = playerPeriodicObserver {
                player.removeTimeObserver(playerPeriodicObserver)
            }
        }
        NotificationCenter.default.removeObserver(self)
    }
    
    deinit {
        stop()
    }
    
    //播放
    open func play() {
        player?.play()
    }
    //重播
    open func replay() {
        start()
        play()
    }
    //当前歌曲播放完
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if self.curduration < self.duration {
            print("wait")
        }else {
            next()
        }
    }
    //暂停
    open func pause() {
        player?.pause()
    }
    //下一首
    open func next() {
        print("next")
        start()
        play()
    }
    //上一首
    open func previous() {
        print("previous")
    }
    //调节声音大小
    open func volume(value:Float) {
        player?.volume = value
    }
    //设置进度
    open func seekTime(duration:TimeInterval, completionHandler: @escaping (Bool) -> Swift.Void) {
        let seekTime = CMTimeMake(Int64(duration*self.duration), 1)
        player?.seek(to: seekTime, completionHandler: completionHandler)
    }
    //更新锁屏
    open func updateLockScreenInfo() {
        let dict:[String : Any] = [
            MPMediaItemPropertyAlbumTitle:"卫兰",
            MPMediaItemPropertyPlaybackDuration:180,
            MPNowPlayingInfoPropertyElapsedPlaybackTime:90,
            MPMediaItemPropertyArtist:"难为自己",
            MPMediaItemPropertyArtwork:MPMediaItemArtwork(image: UIImage(named: "test")!)
            ]
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = dict
    }
    
    //显示播放详情页
    open func show() {
        print("show")
    }
    //隐藏播放详情页
    open func hide() {
        print("hide")
    }
    //键值监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let item =  object as? AVPlayerItem, let keyPath = keyPath {
            if item == self.playerItem {
                switch keyPath {
                case "status":
                    switch item.status {
                    case .readyToPlay:
                        print("readToPlay")
                        duration = item.duration.seconds
                    case .failed:
                        print("failed")
                        print(item.error)
                    case .unknown:
                        print("unknown")
                    }
                default:
                    break
                }
            }
        }
    }
}


