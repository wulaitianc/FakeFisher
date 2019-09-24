//
//  ImageDownloader.swift
//  Moments
//
//  Created by NAVER on 2019/9/24.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation

public class ImageDownloader{
    public static let `default` = ImageDownloader("default")
    private var session: URLSession
    private var name: String
    
    init(_ name: String) {
        if name.isEmpty {
            fatalError("You need to specify a name for the download")
        }
        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 15
        self.session = URLSession(configuration: config)
        self.name = name
    }
    
    func downloadImage(_ urlString: String, completionHandler: @escaping ((Result<Data, FakeFisherError>) -> Void)) -> URLSessionDataTask {
        let task = session.dataTask(with: URL(string: urlString)!){data, response, error in
            DispatchQueue.main.async {
                if let data = data{
                    completionHandler(.success(data))
                }else{
                    if let error = error {
                        completionHandler(.failure(.networkError(reason: .cannotDownload(urlString: urlString, error: error))))
                    }else{
                        completionHandler(.failure(.networkError(reason: .unknownError(urlString: urlString))))
                    }
                }
            }
        }
        
        task.resume()
        return task
    }
}
