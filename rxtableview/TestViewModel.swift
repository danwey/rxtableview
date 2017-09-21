//
//  TestViewModel.swift
//  rxtableview
//
//  Created by mac3 on 2017/9/1.
//  Copyright © 2017年 wei. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class TestViewModel {
   //input
    var searchText = Variable("")
    
  //output
    var results:Driver<String>
    
    init() {
        let searchTextObservable = searchText.asObservable()
        
        let queryResultObservable = searchTextObservable
            .throttle(1.3, scheduler: MainScheduler.instance)
            .filter{ $0.count > 0 }
            .flatMap { query in
                Observable.of(query)
            }.asDriver(onErrorJustReturn: "driver1 error")
        
        let noResultObservable = searchTextObservable
            .filter { $0.count == 0 }
            .map {_ -> String in
                "tests"
            }.asDriver(onErrorJustReturn: "driver1 error")
        results = Driver.of(queryResultObservable,noResultObservable).merge()
    }
}
