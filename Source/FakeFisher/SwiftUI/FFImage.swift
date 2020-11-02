//
//  FFImage.swift
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
public struct FFImage: SwiftUI.View{
    @ObservedObject var imageBinder: FFImageBinder
    var placeholder: AnyView?
    
    public init(_ imageUrl: String, placeholder: AnyView? = nil) {
        self.placeholder = placeholder
        imageBinder = FFImageBinder(imageUrl)
    }
    
    public var body: some SwiftUI.View {
        Group{
            if imageBinder.image == nil{
                Group{
                    if placeholder != nil {
                        placeholder
                    }else{
                        Image(uiImage: .init())
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                .onDisappear {[weak binder = self.imageBinder] in
                    binder?.cancel()
                }
            }else{
                Image(uiImage: imageBinder.image!)
                    .resizable()
            }
        }
        .onAppear {[weak binder = self.imageBinder] in
            binder?.start()
        }
    }
    
}
