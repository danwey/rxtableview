//
//  DownLoadViewController.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/11.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class DownLoadViewController: UIViewController {

    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "下载管理器"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "添加任务", style: .done, target: self, action: #selector(DownLoadViewController.touch1))
        view.backgroundColor = .white
        
//        manager.add(DownloadSong(fileurl: "http://192.168.30.112:8080/music/test.mp3", filename: "test.mp3"))
//        manager.add(DownloadSong(fileurl: "http://192.168.30.112:8080/music/M500001J4FTi3A2UH8.mp3", filename: "M500001J4FTi3A2UH8.mp3"))
//        
//        let tableView = UITableView(frame: UIScreen.main.bounds)
//        tableView.register(UINib.init(nibName: "DownloadTableViewCell", bundle: nil), forCellReuseIdentifier: "Cell")
//        view.addSubview(tableView)
//        tableView.tintColor = UIColor.red
//
//        manager.listVariable
//            .asDriver()
//            .drive(tableView.rx.items) { (tableView, row, element) in
//                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! DownloadTableViewCell
//                cell.set(data: element, tag: row, stopHandler: { (_) in
//                    manager.stop()
//                }, deleteHandler: { (index) in
//                    manager.remove(index)
//                }, startHandler: { [weak self] (index) in
//                    let test = manager.list[index]
//                    let song = Song(name: test.filename, user: test.filename, url: test.saveurl, cover: nil)
//                    musicManager.list.append(song)
//                    let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController")
//                    self?.navigationController?.pushViewController(vc, animated: true)
//                })
//                return cell
//            }
//            .disposed(by: disposeBag)
//        
//        tableView.rx.itemSelected.subscribe(onNext: { (indexPath) in
//            manager.start(indexPath.row)
//        }).disposed(by: disposeBag)
        
    }
    
    @objc func touch1() {
    }

}
