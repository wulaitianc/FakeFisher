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
