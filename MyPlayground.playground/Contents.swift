//: Playground - noun: a place where people can play

import UIKit

//import RxSwift
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

//print(Thread.current)
//print("this is main")
//
//
//DispatchQueue.init(label: "subl").async {
//    print(Thread.current)
//    print("this is subl async")
//
//
//    DispatchQueue.main.async {
//        print(Thread.current)
//        print("this is main async")
//    }
//}
//
//sleep(3)
//
//print("main end")

//print(Thread.current)
//
//DispatchQueue.global().async {
//    print(Thread.current)
//    DispatchQueue.main.async {
//        print(Thread.current)
//    }
//}
//
//let group = DispatchGroup()
//
//
//let queueBook = DispatchQueue(label: "book")
//queueBook.async(group: group) {
//    // 下载图书
//    sleep(2)
//    print(Thread.current)
//    print("下载图书")
//}
//let queueVideo = DispatchQueue(label: "video")
//queueVideo.async(group: group) {
//    // 下载视频
//    sleep(1)
//    print(Thread.current)
//    print("下载视频")
//}
//
//group.notify(queue: DispatchQueue.main) {
//    // 下载完成
//    print(Thread.current)
//    print("下载完成")
//}

var list = [1,2,3,4,5,6,7,8,9,10,11,12]
var newlist:[Int] = []

for _ in list {
    let index = Int(arc4random()) % list.count
    let value = list.remove(at: index)
    newlist.append(value)
}
print(newlist)

//func aa(list:[Int]) -> [Int] {
//
//}


//let semaphore = DispatchSemaphore(value: 1)
//
//var index = 0
//
//func aa () {
//    semaphore.wait()
//    index += 1
//    print("index:\(index) thead:\(Thread.current)")
//    semaphore.signal()
//}
//
//aa()
//
//DispatchQueue(label: "test").async {
//    aa()
//}
//
//
//DispatchQueue(label: "test1").async {
//    aa()
//}
//
//
//DispatchQueue(label: "test2").async {
//    aa()
//}
//
//DispatchQueue(label: "test3").async {
//    aa()
//}
//
//DispatchQueue(label: "test4").async {
//    aa()
//}
//DispatchQueue(label: "test5").async {
//    aa()
//}



