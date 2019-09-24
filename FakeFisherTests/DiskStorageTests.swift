//
//  DiskStorageTests.swift
//  FakeFisherTests
//
//  Created by NAVER on 2019/9/20.
//  Copyright © 2019 Bill. All rights reserved.
//

import XCTest
@testable import FakeFisher

class DiskStorageTests: XCTestCase {

    var diskStorage: DiskStorage.Backend!
    
    override func setUp() {
        let config = DiskStorage.Config(name: "AAAAAAAAAAAAA")
        do {
            diskStorage = try DiskStorage.Backend(config)
        } catch let error {
            print(error)
        }
    }

    func testSave() {
        let string = "1234567"
        let file = DiskStorage.FileData(value: string.data(using: .utf8)!,
                                        expiration: nil,
                                        fileName: string)
        diskStorage.store(file)
        
        do {
            let data = try diskStorage.getFile(forFileName: string)
            XCTAssertNotNil(data)
            let result = String(data: data!, encoding: .utf8)
            XCTAssertNotNil(result)
            XCTAssertEqual(result!, string)
        } catch let e {
            print(e)
        }
    }
    
    func testRemoveFile() {
        let text = "54321"
        let fileName = "testRemoveFile"
        let file = DiskStorage.FileData(value: text.data(using: .utf8)!, expiration: nil, fileName: fileName)
        diskStorage.store(file)
        let localPath = diskStorage.getLocalFilePath(fileName)
    
        XCTAssertTrue(diskStorage.fileManager.fileExists(atPath: localPath))
        try? diskStorage.removeFile(fileName)
        XCTAssertFalse(diskStorage.fileManager.fileExists(atPath: localPath))
    }

    func testRemoveExpired() {
        let text1 = "12345"
        let fileName1 = "testRemoveExpired"
        let file1 = DiskStorage.FileData(value: text1.data(using: .utf8)!,
                                         expiration: .seconds(1),
                                         fileName: fileName1)
        diskStorage.store(file1)
        let localPath = diskStorage.getLocalFilePath(fileName1)
        XCTAssertTrue(diskStorage.fileManager.fileExists(atPath: localPath))
        sleep(3)
        try? diskStorage.removeExpiredFile()
        XCTAssertFalse(diskStorage.fileManager.fileExists(atPath: localPath))
    }
}
