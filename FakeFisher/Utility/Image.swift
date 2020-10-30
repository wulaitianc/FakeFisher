//
//  Image.swift
//  FakeFisher
//
//  Created by NAVER on 2020/10/30.
//  Copyright © 2020 Bill. All rights reserved.
//

import UIKit

func decode(image: UIImage) -> UIImage {
    let size = image.size
    UIGraphicsBeginImageContextWithOptions(size, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else{return image}
    context.scaleBy(x: 1.0, y: -1.0)
    context.translateBy(x: 0, y: -size.height)
    
    defer {
        UIGraphicsEndImageContext()
    }
    
    let rect = CGRect(x: 0, y: 0, width: size.width, height: size.height)
    guard let cgImage = image.cgImage else { return image }
    context.draw(cgImage, in: rect)
    guard let decompressedImageRef = context.makeImage() else {return image}
    
    return UIImage(cgImage: decompressedImageRef)
}
