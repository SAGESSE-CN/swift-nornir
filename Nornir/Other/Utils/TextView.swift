//
//  TextLayout.swift
//  Nornir
//
//  Created by sagesse on 18/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
import CoreText

public class TextView: UIView {
    
}


public class TextStorage: NSObject {
    
    public static func compute(with x: String, in box: CGSize, view: UIView) {
        
        let t = """
https://baidu.com/abcdefghijklmnopqrstuvwxyz老司机认为，图文混排中使用到的CoreText只是CoreText庞大体系中一个对富文本的增强的一部分。
我个人想法啊，我读书少，理解的可能不到位，不过你咬我啊。
 
恩，我又逗逼了一波，说好的大师气质呢，下面开始严肃了啊。

严肃的就是iOS7新推出的类库Textkit，其实是在之前推出的CoreText上的封装，根据苹果的说法，他们开发了两年多才完成，而且他们在开发时候也将表情混排作为一个使用案例进行研究，所以要实现表情混排将会非常容易。

苹果引入TextKit的目的并非要取代已有的CoreText框架，虽然CoreText的主要作用也是用于文字的排版和渲染，但它是一种先进而又处于底层技术，如果我们需要将文本内容直接渲染到图形上下文(Graphics context)时，从性能和易用性来考虑，最佳方案就是使用CoreText。
原理的东西学一学总没有坏处。因此，还是有必要去学一学CoreText的。
那我们开始学习吧。
"""
        let attributedText = NSMutableAttributedString(string: t)
        
        attributedText.setAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 15)], range: NSMakeRange(0, attributedText.length))
        
        let attachment = TextAttachment()
        
    
        let nt = NSAttributedString(string: "\u{fffc}", attributes: [
            kCTRunDelegateAttributeName as String: attachment._delegate,
            "NNTextAttachment": attachment
            ])
        attributedText.insert(nt, at: 44)
        attributedText.addAttribute(NSUnderlineStyleAttributeName, value: NSUnderlineStyle.styleSingle.rawValue, range: NSMakeRange(0, 44))
        attributedText.addAttribute("NNTextLink", value: TextLink(), range: NSMakeRange(0, 44))

        
        let path = CGPath(rect: .init(origin: .zero, size: box), transform: nil)
        let setter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let frame = CTFramesetterCreateFrame(setter, CFRangeMake(0, attributedText.length), path, nil)
        
        
        var links: Array<(NSRange, TextLink)> = []
        var attachments: Array<(NSRange, TextAttachment)> = []
        
        var set = IndexSet()

        attributedText.enumerateAttributes(in: NSMakeRange(0, attributedText.length), options: .longestEffectiveRangeNotRequired) { attributes, range, _ in
            if let attachment = attributes["NNTextAttachment"] as? TextAttachment {
                attachments.append((range, attachment))
                set.insert(integersIn: range.location ..< range.location + range.length)
            }
            if let link = attributes["NNTextLink"] as? TextLink {
                links.append((range, link))
                set.insert(integersIn: range.location ..< range.location + range.length)
            }
        }
    
        let lines = CTFrameGetLines(frame) as? [CTLine] ?? []
//        //let origins = CTFrameGetLineOrigins(frame, CFRangeMake(0, lines.count))
//
        (0 ..< lines.count).forEach {

            let line = lines[$0]
            let range = CTLineGetStringRange(line)
            
            guard set.contains(range.location) else {
                return
            }
            
            print($0, range)
//            let runs = CTLineGetGlyphRuns(line) as? [CTRun] ?? []
//            attributedText.enumerateAttributes(in: NSMakeRange(range.location, range.length), options: .longestEffectiveRangeNotRequired) { attributes, range, _ in
//                print(range, attributes)
//            }
        }
//        CTLineGetTypographicBounds(<#T##line: CTLine##CTLine#>, <#T##ascent: UnsafeMutablePointer<CGFloat>?##UnsafeMutablePointer<CGFloat>?#>, <#T##descent: UnsafeMutablePointer<CGFloat>?##UnsafeMutablePointer<CGFloat>?#>, <#T##leading: UnsafeMutablePointer<CGFloat>?##UnsafeMutablePointer<CGFloat>?#>)
//        CTFrameGetLineOrigins(<#T##frame: CTFrame##CTFrame#>, <#T##range: CFRange##CFRange#>, <#T##origins: UnsafeMutablePointer<CGPoint>!##UnsafeMutablePointer<CGPoint>!#>)
        
//        CTLineGetOffsetForStringIndex(<#T##line: CTLine##CTLine#>, <#T##charIndex: CFIndex##CFIndex#>, <#T##secondaryOffset: UnsafeMutablePointer<CGFloat>?##UnsafeMutablePointer<CGFloat>?#>)
//        CTLineGetStringIndexForPosition(<#T##line: CTLine##CTLine#>, <#T##position: CGPoint##CGPoint#>)
        
        UIGraphicsBeginImageContextWithOptions(box, false, UIScreen.main.scale)
        
        UIGraphicsGetCurrentContext().map {
            //$0.textMatrix = .identity //CGAffineTransform(scaleX: 1, y: -1)
            $0.translateBy(x: 0, y: box.height)
            $0.scaleBy(x: 1, y: -1)
            CTFrameDraw(frame, $0)
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let imageView = UIImageView(image: image)
        imageView.sizeToFit()
        imageView.frame.origin = .init(x: 0, y: 64)
        view.addSubview(imageView)
    }

}

public class TextLink: NSObject {
}

public class TextAttachment: NSObject {
    
    var size: CGSize {
        return .init(width: 80, height: 80)
    }
    
    
    fileprivate var _delegate: CTRunDelegate {
        var callbacks = CTRunDelegateCallbacks(version: kCTRunDelegateVersion1,
                                               dealloc: _TextViewAttachmentDestory,
                                               getAscent: _TextViewAttachmentGetAscent,
                                               getDescent: _TextViewAttachmentGetDescent,
                                               getWidth: _TextViewAttachmentGetWidth)
        
        return CTRunDelegateCreate(&callbacks, _TextViewAttachmentCreate(self))!
    }
}

// Overload the `CTFrameGetLineOrigins`
internal func CTFrameGetLineOrigins(_ frame: CTFrame, _ range: CFRange) -> [CGPoint] {
    let ptr = UnsafeMutablePointer<CGPoint>.allocate(capacity: range.length)
    CTFrameGetLineOrigins(frame, range, ptr)
    return (0 ..< range.length).map {
        return ptr.advanced(by: $0).move()
    }
}

private func _TextViewAttachmentGetWidth(_ attachment: UnsafeMutableRawPointer) -> CGFloat {
    return _TextViewAttachmentGet(attachment).size.width
}
private func _TextViewAttachmentGetAscent(_ attachment: UnsafeMutableRawPointer) -> CGFloat {
    return _TextViewAttachmentGet(attachment).size.height
}
private func _TextViewAttachmentGetDescent(_ attachment: UnsafeMutableRawPointer) -> CGFloat {
    return 0
}

private func _TextViewAttachmentDestory(_ attachment: UnsafeMutableRawPointer) {
    let _ = Unmanaged<TextAttachment>.fromOpaque(attachment).takeRetainedValue()
}
private func _TextViewAttachmentCreate(_ attachment: TextAttachment) -> UnsafeMutableRawPointer {
    return Unmanaged<TextAttachment>.passRetained(attachment).toOpaque()
}
private func _TextViewAttachmentGet(_ attachment: UnsafeMutableRawPointer) -> TextAttachment {
    return Unmanaged<TextAttachment>.fromOpaque(attachment).takeUnretainedValue()
}


