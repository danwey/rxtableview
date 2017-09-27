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
import Kingfisher

//这句到时放到全局位置
let musicManager = WeiMusicManager()

class MusicViewController: UIViewController {
    
    @IBOutlet weak var play_Button: UIButton!
    @IBOutlet weak var stop_Button: UIButton!
    @IBOutlet weak var list_Button: UIButton!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var slider: WWSlider!
    @IBOutlet weak var lrcView: LrcView!
    @IBOutlet weak var imageView: UIImageView!
    
    
    var canSetSlider = true
    let disposeBag = DisposeBag()
    
    //要不要写成单例？
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = true
        musicManager.progress.asDriver().drive(onNext: { (curduration,duration) in
            if self.canSetSlider {
                self.slider.value = Float(curduration/duration)
                let min = Int(curduration) / 60
                let sec = Int(curduration) % 60
                self.label.text = String(format:"%02d:%02d",min,sec)
                let min1 = Int(duration) / 60
                let sec1 = Int(duration) % 60
                self.timeLabel.text = String(format:"%02d:%02d",min1,sec1)
                self.lrcView.progress(curduration)
            }
        }).disposed(by: disposeBag)
        musicManager.downlaodProgress.asDriver().drive(onNext: { (progress) in
            self.slider.loadProgress = progress
        }).disposed(by: disposeBag)
        musicManager.song.asDriver().drive(onNext: { (song) in
            if let song = song {
                self.title = song.name
                self.lrcView.song = song
                self.imageView.kf.setImage(with: URL.init(string: song.cover!))
            }
        }).disposed(by: disposeBag)
        stop_Button.isHidden = true//之后改成 rxswift
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
    @IBAction func musicList(_ sender: Any) {
        let vc = PlayListViewController()
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func touchUp(_ sender: Any) {
        let slider = sender as! UISlider
        musicManager.pause()
        musicManager.seekTime(duration: TimeInterval(slider.value)) { [weak self] (isSucceed) in
            self?.canSetSlider = true
            musicManager.play()
        }
    }
    
    @IBAction func touchDown(_ sender: Any) {
        canSetSlider = false

    }
    
    @IBAction func changeValue(_ sender: Any) {
//        self.timeLabel.text = "\(min1):\(sec1)"
        
    }
}


