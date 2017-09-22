//
//  LrcView.swift
//  LrcTableView
//
//  Created by mac3 on 2017/9/22.
//  Copyright © 2017年 mac3. All rights reserved.
//

import UIKit

class LrcData {
    var beginTime: TimeInterval = 0
    var endTime: TimeInterval = 0
    var text: String = ""
    
    func getPregress(_ duration: TimeInterval) -> Float {
        let t = endTime - beginTime
        let d = duration - beginTime
        if beginTime < duration && duration < endTime {
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
    init(_ path: String) {
        
        let handle = FileHandle(forReadingAtPath: path)
        let data = handle?.readDataToEndOfFile()
        handle?.closeFile()
        let string = String(data: data!, encoding: String.Encoding.utf8)
        let array = (string?.components(separatedBy: "\n"))!
        
        var lasttime: String = ""
        for item in array.reversed() {
            if item.contains("[ti:") || item.contains("[ar:") || item.contains("[al:") {
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
            if item.beginTime < duration && item.endTime > duration {
                return i
            }
            i += 1
        }
        return list.count - 1
    }
}


class LrcView: UIView {

    var tableView: UITableView!
    var visualView: UIVisualEffectView!
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var lrc: LrcInfo?
    var currentIndex = 0
    var playIndex = 0
    var isTouch = false
    var time: TimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = UIColor.yellow
        tableView = UITableView(frame: CGRect.zero, style: .plain)
        tableView.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "cell")
        tableView.backgroundColor = UIColor.clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsSelection = false
        tableView.contentInset = UIEdgeInsets(top: self.tableView.frame.height/2, left: 0, bottom: self.tableView.frame.height/2, right: 0)
        tableView.showsVerticalScrollIndicator = false
        
        imageView = UIImageView(frame: CGRect.zero)
        imageView.image = UIImage(named: "zxy.jpg")
        addSubview(imageView)
        visualView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        visualView.frame = imageView.bounds
        visualView.alpha = 0.0
        imageView.addSubview(visualView)
        
        scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.addSubview(tableView)
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.isPagingEnabled = true
        addSubview(scrollView)
        
        reloaddata()
        tableView.reloadData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloaddata() {
        let path = Bundle.main.path(forResource: "120125029", ofType: "lrc")
        lrc = LrcInfo(path!)
    }
    
    func progress(_ duration:TimeInterval) {
        if let lrc = lrc {
            time += 0.01
            let index = lrc.getIndex(time)
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
            cell?.progress = time
        }
    }
    
    override func layoutSubviews() {
        scrollView.frame = bounds
        imageView.frame = bounds
        visualView.frame = imageView.bounds
        scrollView.contentSize = CGSize(width:scrollView.frame.width * 2,height:scrollView.frame.height)
        tableView.frame = CGRect(x: frame.width, y: 0, width: frame.width, height: frame.height)
    }
}

extension LrcView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (lrc?.list.count)!
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
            visualView.alpha = progrpess*0.8
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
