//
//  Storage.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/18.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public struct TimeConstants {
    static let secondsInOneMinute = 60
    static let minitesInOneHour = 60
    static let HoursInOneDay = 24
    static let secondsInOneDay = secondsInOneMinute * minitesInOneHour * HoursInOneDay
}

public enum StorageExpiration {
    case forever
    case seconds(TimeInterval)
    case days(Int)
    case date(Date)
    case expired
    
    func estimateExpirationSince(date: Date) -> Date {
        switch self {
        case .forever: return .distantFuture
        case .seconds(let sec): return date.addingTimeInterval(sec)
        case .days(let days): return date.addingTimeInterval(TimeInterval(TimeConstants.secondsInOneDay * days))
        case .date(let ref): return ref
        case .expired: return .distantPast
        }
    }
    
    var estimateExpiratinSinceNow: Date {
        return estimateExpirationSince(date: Date())
    }
    
    var timeInterval: TimeInterval{
        switch self {
        case .forever: return .infinity
        case .seconds(let sec): return sec
        case .days(let days): return TimeInterval(TimeConstants.secondsInOneDay * days)
        case .date(let ref): return ref.timeIntervalSince(Date())
        case .expired: return -.infinity
        }
    }
    
    var isExpired: Bool {
        return timeInterval <= 0
    }
}

