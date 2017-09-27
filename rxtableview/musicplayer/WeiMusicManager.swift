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
import RxSwift

class WeiMusicManager:NSObject {
    //只有out put
    var progress = Variable<(TimeInterval,TimeInterval)>((0,0))
    var downlaodProgress = Variable<(Float)>(0)
    var song = Variable<Song?>(nil)

    fileprivate var player:AVPlayer?
    fileprivate var playerItem:AVPlayerItem?
    fileprivate var duration:TimeInterval = 0
    fileprivate var curduration:TimeInterval = 0
    fileprivate var url:URL?
    fileprivate var currentIndex:Int = 0
    fileprivate var down: DownLoad?
    public var list:[Song] = []
    public var test = NSMutableArray()
    var currentSong: Song? {
        return nil
    }
    fileprivate var cover: UIImage? {
        return nil
    }
    var playerPeriodicObserver:Any?

    override init() {
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
        if (currentIndex >= list.count) {
            return
        }
        let song = list[currentIndex]
        self.song.value = song
        down?.stop()
        down = DownLoad(url: URL(string: song.url!)!,delegate: self)
        down?.start()
        if let down = down {
            var newurl = URLComponents(url: down.url, resolvingAgainstBaseURL: false)
            newurl?.scheme = "streaming"
            let asset = AVURLAsset(url: newurl!.url!)
            asset.resourceLoader.setDelegate(down, queue: DispatchQueue.main)
            playerItem = AVPlayerItem(asset: asset)
            
            playerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
            
            player = AVPlayer(playerItem: playerItem)
            NotificationCenter.default.addObserver(self, selector: #selector(WeiMusicManager.itemDidFinishPlaying(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
            playerPeriodicObserver = player?.addPeriodicTimeObserver(forInterval: CMTimeMake(3,30), queue: nil, using: { [weak self] (time) in
                self?.curduration = time.seconds
                self?.progress.value = (curduration: (self?.curduration)!, duration: (self?.duration)!)
            })
            updateLockScreenInfo()
        }
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
    func play() {
        player?.play()
    }
    //重播
    func replay() {
        start()
        play()
    }
    //随机播放
    func random() {
        //随机排序
        //        var list = [1,2,3,4,5,6,7,8,9,10,11,12]
        //        var newlist:[Int] = []
        //
        //        for _ in list {
        //            let index = Int(arc4random()) % list.count
        //            let value = list.remove(at: index)
        //            newlist.append(value)
        //        }
        //        print(newlist)
    }
    //当前歌曲播放完
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if self.curduration < self.duration {
            print("wait")
        }else {
            next()
        }
    }
    func reset() {
        
    }
    //暂停
    open func pause() {
        player?.pause()
    }
    //下一首
    open func next() {
        if list.count > 0 {
            currentIndex = (currentIndex + 1)%list.count
            start()
            play()
        }
    }
    //上一首
    open func previous() {
        if list.count > 0 {
            currentIndex = (currentIndex + list.count - 1)%list.count
            start()
            play()
        }
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

extension WeiMusicManager: DownLoadDelegate {
    func downloadProgress(_ progress: Float) {
        downlaodProgress.value = progress
    }
}

