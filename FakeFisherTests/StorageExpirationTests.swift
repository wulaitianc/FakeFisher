//
//  StorageExpirationTests.swift
//  FakeFisherTests
//
//  Created by NAVER on 2019/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import XCTest
@testable import FakeFisher

class StorageExpirationTests: XCTestCase {
    func testForeverExpiration(){
        let forever = StorageExpiration.forever
        XCTAssertEqual(forever.timeInterval, Double.infinity)
        XCTAssertFalse(forever.isExpired)
        XCTAssertEqual(forever.estimateExpiratinSinceNow, Date.distantFuture)
    }
    
    func testSecondsExpiration() {
        let seconds = StorageExpiration.seconds(100)
        XCTAssertEqual(seconds.timeInterval, 100)
        XCTAssertFalse(seconds.isExpired)
        XCTAssertEqual(seconds.estimateExpiratinSinceNow.timeIntervalSince1970, Date().timeIntervalSince1970 + 100, accuracy: 0.2)
    }
    
    func testDaysExpiration() {
        let days = StorageExpiration.days(5)
        XCTAssertEqual(days.timeInterval,
                       TimeInterval(TimeConstants.secondsInOneDay * 5),
                       accuracy: 0.1)
        XCTAssertFalse(days.isExpired)
        XCTAssertEqual(days.estimateExpiratinSinceNow.timeIntervalSince1970,
                       Date().addingTimeInterval(TimeInterval(TimeConstants.secondsInOneDay * 5)).timeIntervalSince1970,
                       accuracy: 0.1)
    }
    
    func testDateExpiration() {
        let finalDate = Date().addingTimeInterval(TimeInterval(TimeConstants.secondsInOneDay))
        let date = StorageExpiration.date(finalDate)
        XCTAssertEqual(date.timeInterval,
                       finalDate.timeIntervalSinceNow,
                       accuracy: 0.1)
        XCTAssertFalse(date.isExpired)
        XCTAssertEqual(date.estimateExpiratinSinceNow.timeIntervalSinceNow,
                       TimeInterval(TimeConstants.secondsInOneDay),
                       accuracy: 0.1)
    }
    
    func testExpiredExpiration() {
        let expired = StorageExpiration.expired
        XCTAssertEqual(expired.timeInterval, -Double.infinity)
        XCTAssertTrue(expired.isExpired)
        XCTAssertEqual(expired.estimateExpiratinSinceNow, Date.distantPast)
    }
}
