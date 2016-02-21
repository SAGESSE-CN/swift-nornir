//
//  SIMChatFileProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///
/// 文件提供者. <br>
/// 提供关于url的一些操作
///
public class SIMChatFileProvider {
    
    func cached(url: NSURL) -> Bool {
        return false
    }
    
    func download(url: NSURL) -> SIMChatRequest<AnyObject> {
        return SIMChatRequest.request { op in
            switch url.scheme {
            case "chat-image":
                let path = url.path!
                dispatch_async(dispatch_get_global_queue(0, 0)) {
                    SIMLog.debug("download: \(path)")
                    if let image = UIImage(contentsOfFile: path) {
                        dispatch_async(dispatch_get_main_queue()) {
                            op.success(image)
                        }
                    } else {
                        op.failure(NSError(domain: "Load Image Fail", code: -1, userInfo: nil))
                    }
                }
            case "chat-audio":
                dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
                    op.success("test")
                }
            default:
                // 应该请求网络.
                op.failure(NSError(domain: "Unknow scheme", code: -1, userInfo: nil))
            }
        }
    }
   
//    func request(url: NSURL) -> SIMChatRequest<UIImage> {
//        return SIMChatRequest<UIImage>.request { v in
//            
//            let path = url.absoluteString.substringFromIndex(url.absoluteString.startIndex.advancedBy(7))
//                dispatch_async(dispatch_get_main_queue()) {
//                    v.success(image)
//                }
//            } else {
//                v.failure(NSError(domain: "Load Image Fail!", code: -1, userInfo: nil))
//            }
//        }
//    }
}