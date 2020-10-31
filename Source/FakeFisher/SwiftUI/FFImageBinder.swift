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
import FakeFisher

@available(iOS 13.0, *)
public class FFImageBinder: ObservableObject{
    @Published var image: UIImage?
    
    private var downloadTask: URLSessionDataTask?
    private var imageUrl: String
    
    init(_ url: String) {
        imageUrl = url
    }
    
    func start() {
        downloadTask = ImageDownloader.default.downloadImage(imageUrl, completionHandler: { (result) in
            switch result{
            case .success(let data):
                if let image = UIImage(data: data) {
                    DispatchQueue.main.safeAsync {
                        self.image = image
                    }
                }
            case .failure(let error):
                print(error)
            }
        })
    }
    
    func cancel() {
        downloadTask?.cancel()
    }
}
