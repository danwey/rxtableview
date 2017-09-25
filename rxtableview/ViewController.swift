//
//  ViewController.swift
//  rxtableview
//
//  Created by BmMac on 2017/8/30.
//  Copyright © 2017年 wei. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import SwiftyJSON

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    
    let disposeBag = DisposeBag()
    var viewModel: TestViewModel?
//    let down = DownLoad(url: URL(string: "http://192.168.30.237:8080/music/test.mp3")!)
//    let datalist = PublishSubject<String>()
    
//    var tableView: UITableView {
//        let tableView = UITableView(frame: CGRect(x: 0, y: 300, width: 200, height: 200))
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
//        view.addSubview(tableView)
//        return tableView
//    }
    var items : Driver<[String]>?
    let itemDatas = Variable<[String]> (["First Item","Second Item","Third Item"])
//        Observable.just([
//        "First Item",
//        "Second Item",
//        "Third Item"
//        ])


    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = TestViewModel()

        let vm = viewModel!
        
//        let itemDatas = Variable<[String]> (["First Item","Second Item","Third Item"])
        items = itemDatas.asDriver()
        
        button.rx.tap.subscribe(onNext: { [weak self] in
//            self?.down.start()
            
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URL.init(string: "http://192.168.30.239:8080/api/musicList.json")!, completionHandler: { (data, response, error) in
                let str = String.init(data: data!, encoding: String.Encoding.utf8)!
                let json = JSON.init(parseJSON: str)
                let songs = json["data"].map{ Song($0.1) }
                musicManager.list = songs
            }).resume()
            
            let vc = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MusicViewController")
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        textField.rx.text.orEmpty.bind(to: vm.searchText)
            .disposed(by:disposeBag)

        vm.results.drive(onNext: { [weak self] (text) in
            print(text)
            self?.label.text = text
        }, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)

        let tableView = UITableView(frame: CGRect(x: 0, y: 300, width: 200, height: 200))
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)
        

        tableView.rx.itemSelected.subscribe(onNext: { [weak self] (indexPath) in
            self?.itemDatas.value = ["aa"]
        }).disposed(by: disposeBag)

//        datalist.onNext("sdfsdf")

//        tableView.rx.modelSelected(String.self).map { (string) -> String in
//            return string
//        }.a
    }
    
}

