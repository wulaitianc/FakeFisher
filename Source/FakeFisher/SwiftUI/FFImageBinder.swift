//
//  FFImageBinder.swift
//  FakeFisher-SwiftUI
//
//  Created by NAVER on 2020/10/31.
//  Copyright © 2020 Bill. All rights reserved.
//

#if canImport(SwiftUI) && canImport(Combine)
import SwiftUI
import Combine
#endif

@available(iOS 13.0, *)
public class FFImageBinder: ObservableObject{
    @Published var image: UIImage?
    
    private var downloadTask: URLSessionDataTask?
    private var imageUrl: String
    private var loaded = false
    
    init(_ url: String) {
        imageUrl = url
    }
    
    func start() {
        guard loaded == false else{return}
        loaded = true
        ImageCache.default.retrive(imageUrl) { [weak self] (image, needDownload) in
            guard let self = self else {return}
            if let image = image{
                DispatchQueue.main.safeAsync {
                    self.image = image
                }
            }
            if needDownload{
                self.downloadTask = ImageDownloader.default.downloadImage(self.imageUrl, completionHandler: {[weak self] (result) in
                    guard let self = self else {return}
                    self.downloadTask = nil
                    switch result{
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.safeAsync {
                                self.image = image
                            }
                            ImageCache.default.store(image, urlString: self.imageUrl, expiration: nil) { (result) in
                                
                            }
                        }
                    case .failure(let error):
                        self.loaded = false
                        print(error)
                    }
                })
            }
        }
    }
    
    func cancel() {
        downloadTask?.cancel()
    }
}
