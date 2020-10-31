//
//  HelperExtension.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation


extension Date{
    var isPast: Bool{
        return self.timeIntervalSince(Date()) <= 0
    }
}

extension DispatchQueue {
    // This method will dispatch the `block` to self.
    // If `self` is the main queue, and current thread is main thread, the block
    // will be invoked immediately instead of being dispatched.
    func safeAsync(_ block: @escaping ()->()) {
        if self === DispatchQueue.main && Thread.isMainThread {
            block()
        } else {
            async { block() }
        }
    }
}
