//
//  DownloadTableViewCell.swift
//  rxtableview
//
//  Created by mac3 on 2017/8/31.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button2: UIButton!
    
    let disposeBag = DisposeBag()
    
    let indexVariable = Variable(0)
    
    var stopHandler : ((Int) -> Void)?
    var deleteHandler : ((Int) -> Void)?
    var startHandler : ((Int) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //删除按钮
        button.rx.tap
            .asObservable()
            .withLatestFrom(indexVariable.asObservable()) 
            .subscribe( onNext: { [weak self] (index) in
                self?.deleteHandler!(index)
            }).disposed(by: disposeBag)
        //暂停按钮
        button1.rx.tap
            .asObservable()
            .withLatestFrom(indexVariable.asObservable())
            .subscribe( onNext: { [weak self] (index) in
                self?.stopHandler!(index)
            }).disposed(by: disposeBag)
        //开始按钮
        button2.rx.tap
            .asObservable()
            .withLatestFrom(indexVariable.asObservable())
            .subscribe( onNext: { [weak self] (index) in
                self?.startHandler!(index)
            }).disposed(by: disposeBag)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func set(data:DownLoadItemable,tag:Int,stopHandler:@escaping (Int) -> Void,deleteHandler:@escaping (Int) -> Void,startHandler:@escaping (Int) -> Void) {
        self.data = data
        self.tag = tag
        self.stopHandler = stopHandler
        self.deleteHandler = deleteHandler
        self.startHandler = startHandler
    }
    
    var data : DownLoadItemable? {
        willSet {
            indexVariable.value = tag
            
            label1.text = newValue?.filename
            label2.isHidden = false
            progressView.isHidden = true
            switch newValue!.status {
            case .prepare:
                label2.text = "等待开始下载"
            case .download(let progress) :
                label2.isHidden = true
                progressView.isHidden = false
                progressView.progress = progress
            case .error(let msg) :
                label2.text = msg
            case .stop:
                label2.text = "已暂停，点击开始下载"
            }
        }
    }
    
}
