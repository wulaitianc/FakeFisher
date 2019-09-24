//
//  FakeFisher.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/24.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation
import UIKit

public protocol FakeFisherCompatible{}

extension UIImageView: FakeFisherCompatible{}

extension FakeFisherCompatible{
    public var ff: FakeFisherWrapper<Self>{
        return FakeFisherWrapper(self)
    }
}

public struct FakeFisherWrapper<T>{
    let base: T
    init(_ base: T) {
        self.base = base
    }
}
