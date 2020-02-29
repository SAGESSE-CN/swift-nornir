//
//  SAIEmoticon.swift
//  SAC
//
//  Created by SAGESSE on 9/15/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

open class SAIEmoticon: NSObject {
    
    open var isBackspace: Bool {
        return self === SAIEmoticon.backspace
    }
    
    /// 退格
    public static let backspace: SAIEmoticon = {
        let em = SAIEmoticon()
        em.contents = "⌫"
        return em
    }()
    
    open func draw(in rect: CGRect, in ctx: CGContext) {
        
        //ctx.setFillColor(UIColor.red.withAlphaComponent(0.2).cgColor)
        //ctx.fill(rect)
        
        switch contents {
        case let image as UIImage:
            var nrect = rect
            nrect.size = image.size
            nrect.origin.x = rect.minX + (rect.width - nrect.width) / 2
            nrect.origin.y = rect.minY + (rect.height - nrect.height) / 2
            image.draw(in: nrect)
            
        case let str as NSString:
            let cfg = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 32)]
            let size = str.size(withAttributes: cfg)
            let nrect = CGRect(x: rect.minX + (rect.width - size.width + 3) / 2,
                              y: rect.minY + (rect.height - size.height) / 2,
                              width: size.width,
                              height: size.height)
            str.draw(in: nrect, withAttributes: cfg)
            
        case let str as NSAttributedString:
            str.draw(in: rect)
            
        default: 
            break
        }
    }
    
    open func show(in view: UIView) {
        let imageView = view.subviews.first as? UIImageView ?? {
            let imageView = UIImageView()
            view.subviews.forEach{
                $0.removeFromSuperview()
            }
            view.addSubview(imageView)
            return imageView
        }()
        
        if let image = contents as? UIImage {
            imageView.bounds = CGRect(origin: .zero, size: image.size)
            imageView.center = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
            //imageView.frame =  view.bounds.inset(by: UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))
            imageView.image = contents as? UIImage
        }
    }
    
    // 目前只支持UIImage/NSString/NSAttributedString
    open var contents: Any?
}

internal protocol SAIEmoticonDelegate: class {
    
    func emoticon(shouldSelectFor emoticon: SAIEmoticon) -> Bool
    func emoticon(didSelectFor emoticon: SAIEmoticon)
    
    func emoticon(shouldPreviewFor emoticon: SAIEmoticon?) -> Bool
    func emoticon(didPreviewFor emoticon: SAIEmoticon?)
    
}
