//
//  UIImageView+FakeFisher.swift
//  FakeFisher
//
//  Created by NAVER on 2019/9/24.
//  Copyright © 2019 Bill. All rights reserved.
//

import Foundation
import UIKit

private var dataTaskKey: Void?
extension FakeFisherWrapper where T: UIImageView{
    
    public func setImage(urlString:String, placeholder: UIImage? = nil, completionHandler: ((Result<UIImage, FakeFisherError>) -> Void)? = nil) {

        ImageCache.default.retrive(urlString, completionHandler: {image, needsDownload in
            DispatchQueue.main.safeAsync {
                guard let image = image else {
                    self.base.image = placeholder
                    return
                }
                self.base.image = image
                completionHandler?(.success(image))
            }
            
            if needsDownload {
                let task = ImageDownloader.default.downloadImage(urlString){result in
                    switch result{
                    case .success(let data):
                        if let image = UIImage(data: data) {
                            
                            ImageCache.default.store(image, urlString: urlString, expiration: nil){result in
                                switch result.diskCacheResult{
                                case .success(): break
                                case .failure(let error): print(error);
                                }
                            }
                            DispatchQueue.main.safeAsync {
                                self.base.image = image
                            }
                            completionHandler?(.success(image))
                        }
                    case .failure(let error):
                        completionHandler?(.failure(error))
                        print(error.localizedDescription)
                    }
                    
                }
                objc_setAssociatedObject(self.base, &dataTaskKey, task, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
        })
        
    }
    
    public func cancelDownload(){
        if let dataTask = objc_getAssociatedObject(self.base, &dataTaskKey) as? URLSessionDataTask {
            dataTask.cancel()
        }
    }
}
