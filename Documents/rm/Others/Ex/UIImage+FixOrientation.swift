//
//  UIImage+FixOrientation.swift
//  SIMChat
//
//  Created by sagesse on 9/20/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//extension UIImage {
//    
//    func fixOrientation() -> UIImage? {
//        
//        // No-op if the orientation is already correct
//        if self.imageOrientation == .up {
//            return self
//        }
//        
//        // We need to calculate the proper transformation to make the image upright.
//        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
//        var transform = CGAffineTransform.identity
//        
//        switch self.imageOrientation {
//        case .down, .downMirrored:
//            transform = transform.translateBy(x: self.size.width, y: self.size.height)
//            transform = transform.rotate(CGFloat(M_PI))
//            
//        case .left, .leftMirrored:
//            transform = transform.translateBy(x: self.size.width, y: 0)
//            transform = transform.rotate(CGFloat(M_PI_2))
//        case .right, .rightMirrored:
//            transform = transform.translateBy(x: 0, y: self.size.height)
//            transform = transform.rotate(CGFloat(-M_PI_2))
//            
//        default:
//            break
//        }
//        
//        switch self.imageOrientation {
//        case .upMirrored, .downMirrored:
//            transform = transform.translateBy(x: self.size.width, y: 0)
//            transform = transform.scaleBy(x: -1, y: 1)
//            
//        case .leftMirrored, .rightMirrored:
//            transform = transform.translateBy(x: self.size.height, y: 0)
//            transform = transform.scaleBy(x: -1, y: 1)
//            
//        default:
//            break
//        }
//        
//        // Now we draw the underlying CGImage into a new context, applying the transform
//        // calculated above.
//        let image = self.cgImage!
//        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: image.bitsPerComponent, bytesPerRow: 0, space: image.colorSpace!, bitmapInfo: image.bitmapInfo.rawValue)!
//        
//        ctx.concatCTM(transform)
//        
//        switch self.imageOrientation {
//        case .left, .leftMirrored, .right, .rightMirrored:
//            // Grr...
//            ctx.draw(in: CGRect(x: 0,y: 0,width: self.size.height,height: self.size.width), image: image)
//            
//        default:
//            ctx.draw(in: CGRect(x: 0,y: 0,width: self.size.width,height: self.size.height), image: image)
//        }
//        
//        // And now we just create a new UIImage from the drawing context
//        return UIImage(cgImage: ctx.makeImage()!)
//    }
//}
