//
//  DiskStorage.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/20.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum DiskStorage {
    public class Backend{
        let fileManager: FileManager
        let config: Config
        var directoryPath: String
        
        init(_ config: Config, fileManager: FileManager = .default) throws {
            self.fileManager = fileManager
            self.config = config
            if let directory = config.directoryPath {
                self.directoryPath = directory
            }else{
                do {
                    let pathURL = try fileManager.url(for: .cachesDirectory,
                                               in: .userDomainMask,
                                               appropriateFor: nil,
                                               create: true)
                    self.directoryPath = pathURL.path
                } catch let error {
                    throw FakeFisherError.cacheError(reason: .cannotCreateDirectory(path: "", error: error))
                }
            }
                        
            try initFileDiectory()
        }
        
        func initFileDiectory() throws {
            guard !fileManager.fileExists(atPath: directoryPath) else {return}
            
            do {
                try fileManager.createDirectory(atPath: directoryPath,
                                                withIntermediateDirectories: true,
                                                attributes: nil)
            } catch let error {
                throw FakeFisherError.cacheError(reason: .cannotCreateDirectory(path: directoryPath, error: error))
            }
        }
        
        func store(_ file: FileData) -> Bool {
            let expiration = file.expiration ?? config.expiration
            guard !expiration.isExpired else {return false}
            
            let fileAttribute = [FileAttributeKey.creationDate: Date(),
                                 FileAttributeKey.modificationDate: expiration.estimateExpiratinSinceNow]
            let path = getLocalFilePath(file.fileName)
            return fileManager.createFile(atPath: path,
                                   contents: file.value,
                                   attributes: fileAttribute)
        }
        
        func getFile(forFileName fileName: String) throws -> Data? {
            let path = getLocalFilePath(fileName)
            guard fileManager.fileExists(atPath: path) else {return nil}
            
            let data: Data
            do {
                data = try Data(contentsOf: URL(fileURLWithPath: path))
            } catch let error {
                throw FakeFisherError.cacheError(reason: .cannotInitializeDataFromPath(path: path, error: error))
            }
            
            return data
        }
        
        func removeFile(_ fileName: String) throws{
            let path = getLocalFilePath(fileName)
            do {
                try fileManager.removeItem(atPath: path)
            } catch let error {
                throw FakeFisherError.cacheError(reason: .cannotRemoveFileFromDisk(path: path, error: error))
            }
        }
        
        func removeExpiredFile() throws{
            let filesPath: [String]
            do {
                filesPath = try fileManager.contentsOfDirectory(atPath: directoryPath)
            } catch let error {
                throw FakeFisherError.cacheError(reason: .cannotOpenDirectory(path: directoryPath, error: error))
            }
            
            let now = Date()
            for path in filesPath {
                let filePath = (directoryPath as NSString).appendingPathComponent(path)
                let attributes: [FileAttributeKey: Any]
                do {
                    attributes = try fileManager.attributesOfItem(atPath: filePath)
                } catch let error {
                    throw FakeFisherError.cacheError(reason: .cannotOpenFile(path: filePath, error:error))
                }
                
                if now.timeIntervalSince(attributes[.modificationDate] as! Date) > 0 {
                    try fileManager.removeItem(atPath: filePath)
                }
            }
        }
        
        func getLocalFilePath(_ fileName: String) -> String{
            return (directoryPath as NSString).appendingPathComponent(fileName.ff.md5)
        }
    }
}


extension DiskStorage{
    public struct Config{
        let expiration: StorageExpiration
        let directoryPath: String?
        let name: String
        
        public init(directoryPath: String? = nil, name: String, expiration: StorageExpiration = .days(7)) {
            self.directoryPath = directoryPath
            self.expiration = expiration
            self.name = name
        }
    }
}

extension DiskStorage{
    public struct FileData{
        let value: Data
        var expiration: StorageExpiration?
        let fileName: String
    }
}
