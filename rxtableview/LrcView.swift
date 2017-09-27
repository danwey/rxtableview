//
//  LrcView.swift
//  LrcTableView
//
//  Created by mac3 on 2017/9/22.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit
import Kingfisher

class LrcData {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var text: String = ""
    
    func getPregress(_ duration: TimeInterval) -> Float {
        let t = endTime - beginTime
        let d = duration - beginTime
        if beginTime <= duration && duration < endTime {
            return Float(d/t)
        }
        return 0
    }
}

class LrcInfo {
    //只对 00:00.00做处理
    static func getTime(_ time:String) -> TimeInterval {
        if time.count > 0 {
            let item = time.components(separatedBy: ":")
            let minute = TimeInterval(item.first!)
            let second = TimeInterval(item.last!)
            return minute! * 60 + second!
        }
        return 0
    }
    var list:[LrcData] = []
    init(path: String) {
        
        let handle = FileHandle(forReadingAtPath: path)
        let data = handle?.readDataToEndOfFile()
        handle?.closeFile()
        let string = String(data: data!, encoding: String.Encoding.utf8)
        setup(string)
    }
    init(string: String?) {
        setup(string)
    }
    func setup(_ string:String?) {
        let array = (string?.components(separatedBy: "\n"))!
        
        var lasttime: String = ""
        for item in array.reversed() {
            if item.contains("[ti:") || item.contains("[ar:") || item.contains("[al:") || item.contains("[by:") {
                continue
            }
            let newItem = item.replacingOccurrences(of: "[", with: "")
            let items = newItem.components(separatedBy: "]")
            let time = items.first!
            let song = items.last!
            let lrc = LrcData()
            lrc.beginTime = LrcInfo.getTime(time)
            lrc.endTime = LrcInfo.getTime(lasttime)
            lasttime = time
            lrc.text = song
            list.insert(lrc, at: 0)
        }
    }
    func getIndex(_ duration:TimeInterval) -> Int {
        var i = 0
        for item in list {
            if item.beginTime <= duration && duration < item.endTime {
                return i
            }
            i += 1
        }
        return list.count - 1
    }
}


class LrcView: UIView {

    var tableView: UITableView!
//    var visualView: UIVisualEffectView!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var lrc: LrcInfo?
    var currentIndex = 0
    var playIndex = 0
    var isTouch = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setup()
    }
    
    var song: Song? {
        didSet {
            reloaddata()
        }
    }
    
    func setup() {
        backgroundColor = .clear
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: self.tableView.frame.height/2, left: 0, bottom: self.tableView.frame.height/2, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
//        visualView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
//        visualView.frame = imageView.bounds
//        visualView.alpha = 0.0
//        imageView.addSubview(visualView)
        
        scrollView = UIScrollView(frame: .zero)
        scrollView.addSubview(tableView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        addSubview(scrollView)
        
        imageView = UIImageView(frame: .zero)
        //        imageView.image = UIImage(named: "zxy.jpg")
        scrollView.addSubview(imageView)
        
        reloaddata()
    }
    
    func reloaddata() {
        if let song = song {
            imageView.kf.setImage(with: URL.init(string: (song.cover)!))
    //        let path = Bundle.main.path(forResource: "120125029", ofType: "lrc")
            URLSession(configuration: URLSessionConfiguration.default).dataTask(with: URL.init(string: (song.lrc)!)!, completionHandler: { [weak self] (data, response, error) in
                let string = String.init(data: data!, encoding: String.Encoding.utf8)
                self?.lrc = LrcInfo(string:string!)
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            }).resume()
        }
    }
    
    func progress(_ duration:TimeInterval) {
        if let lrc = lrc {
            let index = lrc.getIndex(duration)
            let indexpath = IndexPath(row: index, section: 0)
            if playIndex != index {
                let lastIndexpath = IndexPath(row: playIndex, section: 0)
                let cell = tableView.cellForRow(at: lastIndexpath) as? TableViewCell
                cell?.progress = 0
                playIndex = index
                if !isTouch {
                    self.tableView.scrollToRow(at: indexpath, at: .middle, animated: true)
                }
            }
            
            let cell = tableView.cellForRow(at: indexpath) as? TableViewCell
            cell?.progress = duration
        }
    }
    
    override func layoutSubviews() {
        scrollView.frame = bounds
        imageView.frame = bounds
        imageView.layer.cornerRadius = bounds.width/2
        imageView.layer.masksToBounds = true
//        visualView.frame = imageView.bounds
        scrollView.contentSize = CGSize(width:scrollView.frame.width * 2,height:scrollView.frame.height)
        tableView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
    }
}

extension LrcView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let lrc = lrc {
            return lrc.list.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! TableViewCell
        let data = lrc?.list[indexPath.row]
        cell.data = data
        return cell
    }
}
extension LrcView: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.scrollView {
            var progrpess = scrollView.contentOffset.x / scrollView.frame.width
            progrpess = min(progrpess, 1.0)
            progrpess = max(progrpess, 0.0)
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView == self.tableView {
            isTouch = true
        }
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if scrollView == self.tableView {
            isTouch = false
        }
    }
}
