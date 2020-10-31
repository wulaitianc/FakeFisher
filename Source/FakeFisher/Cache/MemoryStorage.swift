//
//  MemoryStorage.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/19.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum MemoryStorage{
    public class Backend<T>{
        let cache = NSCache<NSString, StorageObject<T>>()
        var keys = Set<NSString>()
        let config: Config
        
        private let lock = NSRecursiveLock()
        private var cleanTimer: Timer? = nil
        
        init(config: Config) {
            self.config = config
            cache.totalCostLimit = config.totalCostLimit
            cache.countLimit = config.countLimit
            
            cleanTimer = .scheduledTimer(withTimeInterval: config.cleanInterval,
                                    repeats: true){[weak self] _ in
                                        guard let self = self else { return }
                                        self.removeExpired()
            }
        }
        
        func store(_ value:T, key: NSString, expiration: StorageExpiration?) {
            lock.lock()
            defer {
                lock.unlock()
            }
            
            let expiration = expiration ?? config.expiration
            
            let object = StorageObject(value: value, key: key, expiration: expiration)
            cache.setObject(object, forKey: object.key)
            keys.insert(key)
        }
        
        func value(_ forKey: NSString) -> T? {
            guard let object = cache.object(forKey: forKey) else { return nil }
            return object.value
        }
        
        func remove(_ forKey:NSString) {
            lock.lock()
            defer{lock.unlock()}
            
            keys.remove(forKey)
            cache.removeObject(forKey: forKey)
        }
        
        func isCached(_ key: NSString) -> Bool{
            guard let _ = value(key) else { return false }
            return true
        }
        
        func removeExpired(){
            lock.lock()
            defer {lock.unlock()}
            
            for key in keys {
                guard let object = cache.object(forKey: key) else {
                    keys.remove(key)
                    continue
                }
                
                if object.expired {
                    keys.remove(key)
                    cache.removeObject(forKey: key)
                }
            }
        }
    }
}


extension MemoryStorage{
    public struct Config{
        public var totalCostLimit: Int
        public var countLimit: Int = .max
        public var expiration: StorageExpiration = .seconds(300)
        public let cleanInterval: TimeInterval

        public init(totalCostLimit: Int, cleanInterval: TimeInterval = 120) {
            self.totalCostLimit = totalCostLimit
            self.cleanInterval = cleanInterval
        }
    }
}

extension MemoryStorage{
    public class StorageObject<T> {
        let value:T
        let key: NSString
        let expiration: StorageExpiration
        
        private(set) var estimatedExpirationDate: Date
        
        init(value:T, key: NSString, expiration: StorageExpiration = .seconds(300)) {
            self.value = value
            self.key = key
            self.expiration = expiration
            
            self.estimatedExpirationDate = expiration.estimateExpiratinSinceNow
        }
        
        var expired: Bool {
            return estimatedExpirationDate.isPast
        }
    }
}
