//
//  MusicViewController.swift
//  WeiPlayer
//
//  Created by BmMac on 2017/8/25.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

//这句到时放到全局位置
let musicManager = WeiMusicManager.share

class MusicViewController: UIViewController {
    
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var stop_Button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var coverImage: UIImageView!
    @IBOutlet weak var slider: UISlider!
    @IBOutlet weak var progress: UIProgressView!
    var canSetSlider = true
    let disposeBag = DisposeBag()
    
    //要不要写成单例？
    override func viewDidLoad() {
        super.viewDidLoad()
        coverImage.layer.cornerRadius = 100
        coverImage.layer.masksToBounds = true
        musicManager.delegete = self
//        manager.valueVariable.asDriver().drive(progress.rx.progress).disposed(by: disposeBag)
        
        musicManager.start()
        musicManager.play()
    }
    
    @IBAction func musicPlay(_ sender: Any) {
        musicManager.play()
    }
    
    @IBAction func musicStop(_ sender: Any) {
        musicManager.pause()
    }
    
    @IBAction func musicNext(_ sender: Any) {
        musicManager.next()
    }
    
    @IBAction func musicPrevious(_ sender: Any) {
        musicManager.previous()
    }
    
    @IBAction func touchUp(_ sender: Any) {
        let slider = sender as! UISlider
        musicManager.seekTime(duration: TimeInterval(slider.value)) { [weak self] (isSucceed) in
            self?.canSetSlider = true
        }
    }
    
    @IBAction func touchDown(_ sender: Any) {
        canSetSlider = false

    }
    
    @IBAction func changeValue(_ sender: Any) {
//        self.timeLabel.text = "\(min1):\(sec1)"
        
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
}

extension MusicViewController:MusicDelegate {
    func periodicTime(curduration: TimeInterval, duration: TimeInterval) {
        if canSetSlider {
            slider.value = Float(curduration/duration)
            let min = Int(curduration) / 60
            let sec = Int(curduration) % 60
            self.label.text = String(format:"%02d:%02d",min,sec)
            let min1 = Int(duration) / 60
            let sec1 = Int(duration) % 60
            self.timeLabel.text = String(format:"%02d:%02d",min1,sec1)
        }
    }
    func loadTime(progress: Float) {
        self.progress.progress = progress
    }
}
