//
//  ImageCache.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/21.
//  Copyright © 2019 Bill. All rights reserved.
//

import UIKit

public class ImageCache{
    private let memoryCache: MemoryStorage.Backend<UIImage>
    private let diskCache: DiskStorage.Backend
    private let dispatchQueue: DispatchQueue
    public static let `default` = try! ImageCache("default")
    
    init(_ urlString: String) throws{
        if urlString.isEmpty {
            fatalError("cannot initialize with empty name")
        }
        
        dispatchQueue = DispatchQueue(label: "Image_Cache_\(urlString)")
        
        let memory = ProcessInfo.processInfo.physicalMemory
        let memoryConfig = MemoryStorage.Config(totalCostLimit: Int(memory / 4))
        memoryCache = MemoryStorage.Backend(config: memoryConfig)
        
        let diskConfig = DiskStorage.Config(name: "Disk_Cache_\(urlString)")
        diskCache = try DiskStorage.Backend(diskConfig)
    }
    
    func store(_ image: UIImage,
               urlString: String,
               expiration: StorageExpiration?,
               completionHandler: ((CacheResult)-> Void)?){
        memoryCache.store(image,
                          key: urlString as NSString,
                          expiration: expiration)
        
        guard let data = image.pngData() else {
            if let handler = completionHandler {
                let result = CacheResult(memoryCacheResult: .success(()), diskCacheResult: .failure(.cacheError(reason: .cannotConvertImageToData(path: urlString))))
                dispatchQueue.async {
                    handler(result)
                }
            }
            return  }
        let fileData = DiskStorage.FileData(value: data,
                                            expiration: nil,
                                            fileName: urlString)
        let isSuccess = diskCache.store(fileData)
        let result = isSuccess ? CacheResult(memoryCacheResult: .success(()), diskCacheResult: .success(())) : CacheResult(memoryCacheResult: .success(()), diskCacheResult: .failure(.cacheError(reason: .cannotSaveFileToDisk(path: urlString))))
        dispatchQueue.async {
            guard let handler = completionHandler else {return}
            handler(result)
        }
    }
    
    
    /// get image from cache
    /// - Parameter urlString: image url
    /// - Parameter completionHandler: Called when the image retrieved and set finished. This completion handler will be invoked
    /// - Returns: Bool value indicates whether needs to start downloading progress
    func retrive(_ urlString: String,
                 completionHandler: ((UIImage?)-> Void)) throws -> Bool{
        guard !urlString.isEmpty else {
            completionHandler(nil)
            return false
        }
        
        if let image = memoryCache.value(urlString as NSString){
            completionHandler(image)
            return false
        }
        
        if let data = try diskCache.getFile(forFileName: urlString){
            if let image = UIImage(data: data) {
                completionHandler(image)
                return false
            }
        }
        
        completionHandler(nil)
        return true
    }
}

public struct CacheResult{
    public let memoryCacheResult: Result<Void, Never>
    public let diskCacheResult: Result<Void, FakeFisherError>
}
