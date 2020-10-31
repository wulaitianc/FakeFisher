//
//  FakeFisherError.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/20.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public enum FakeFisherError: Error{
    public enum FileCacheError{
        case cannotCreateDirectory(path: String, error: Error)
        case cannotInitializeDataFromPath(path: String, error: Error)
        case cannotRemoveFileFromDisk(path: String, error: Error)
        case cannotOpenDirectory(path: String, error: Error)
        case cannotOpenFile(path: String, error: Error)
        case cannotConvertImageToData(path: String)
        case cannotSaveFileToDisk(path: String)
    }
    
    public enum NetworkError{
        case cannotDownload(urlString: String, error: Error)
        case unknownError(urlString: String)
    }
    
    case cacheError(reason: FileCacheError)
    case networkError(reason: NetworkError)
}


extension FakeFisherError: LocalizedError{
    
}
