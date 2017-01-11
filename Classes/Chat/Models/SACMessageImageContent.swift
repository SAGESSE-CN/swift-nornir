//
//  SACMessageImageContent.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageImageContent: NSObject, SACMessageContentType {

    open var layoutMargins: UIEdgeInsets = .zero
    
    open class var viewType: SACMessageContentViewType.Type {
        return SACMessageImageContentView.self
    }
    
    open var image: UIImage? = UIImage(named: "t1.jpg")
    
    open func sizeThatFits(_ size: CGSize) -> CGSize {
        let size = image?.size ?? .zero
        
        let scale = min(min(160, size.width) / size.width, min(160, size.height) / size.height)
        
        let w = size.width * scale
        let h = size.height * scale
        
        return .init(width: w, height: h)
    }
}
