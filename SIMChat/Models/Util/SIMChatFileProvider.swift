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
    
    private static var _sharedInstance = SIMChatFileProvider()
    
    public static func sharedInstance() -> SIMChatFileProvider {
        return _sharedInstance
    }
    
    func cached(url: NSURL) -> Bool {
        return false
    }
    
    var c: UIImage?
    
    func download(url: NSURL) -> SIMChatRequest<AnyObject> {
        return SIMChatRequest.request { op in
            switch url.scheme {
            case "chat-image":
                if let image = self.c {
                    op.success(image)
                    return
                }
                let path = url.path!
                dispatch_async(dispatch_get_global_queue(0, 0)) {
                    SIMLog.debug("download: \(path)")
                    if let image = UIImage(contentsOfFile: path) {
                        // 缓存起来.
                        self.c = image
                        dispatch_async(dispatch_get_main_queue()) {
                            op.success(image)
                        }
                    } else {
                        op.failure(NSError(domain: "Load Image Fail", code: -1, userInfo: nil))
                    }
                }
            case "chat-audio":
                let path = NSURL(fileURLWithPath: url.path!)
                let needDownload = !NSFileManager().fileExistsAtPath(url.path!)
                if needDownload {
                    SIMChatNotificationCenter.postNotificationName(SIMChatFileProviderWillDownload, object: url)
                }
                dispatch_after_at_now(0.5, dispatch_get_main_queue()) {
                    if needDownload {
                        SIMChatNotificationCenter.postNotificationName(SIMChatFileProviderDidDownload, object: url)
                    }
                    op.success(path)
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


public let SIMChatFileProviderWillLoad = "SIMChatFileProviderWillLoad"
public let SIMChatFileProviderDidLoad = "SIMChatFileProviderDidLoad"
public let SIMChatFileProviderWillDownload = "SIMChatFileProviderWillDownload"
public let SIMChatFileProviderDidDownload = "SIMChatFileProviderDidDownload"