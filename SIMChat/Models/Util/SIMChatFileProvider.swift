//
//  SIMChatFileProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

/// 来源
public enum SIMChatFileProviderSource {
    case Raw(contentType: String, identifier: String)    // 原始数据
    case Local(contentType: String, path: String)  // 本地文件
    case Network(contentType: String, address: NSURL) // 网络文件
    
    // 从URL识别
    public init?(URL: NSURL) {
        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
            return nil // 错误
        }
        guard components.scheme == "simchat" else {
            return nil // 未知
        }
        guard let source = components.path, type = components.host, parameter = components.query else {
            return nil // 参数错误
        }
        switch source {
        case "/sa.raw":      self = .Raw(contentType: type, identifier: parameter)
        case "/sa.local":    self = .Local(contentType: type, path: parameter)
        case "/sa.network":  self = .Network(contentType: type, address: NSURL(string: parameter)!)
        default:            return nil
        }
    }
    // 转为URL
    public var URL: NSURL {
        let components = NSURLComponents()
        components.scheme = "simchat"
        switch self {
        case .Raw(let contentType, let identifier):
            components.path = "/sa.raw"
            components.host = contentType
            components.query = identifier
        case .Local(let contentType, let path):
            components.path = "/sa.local"
            components.host = contentType
            components.query = path
        case .Network(let contentType, let address):
            components.path = "/sa.network"
            components.host = contentType
            components.query = address.relativeString
        }
        return components.URL!
    }
    public var contentType: String {
        switch self {
        case .Raw(let contentType, _): return contentType
        case .Local(let contentType, _): return contentType
        case .Network(let contentType, _): return contentType
        }
    }
}


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
            case "simchat":
                guard let source = SIMChatFileProviderSource(URL: url) else {
                    op.failure(NSError(domain: "Source Fail!", code: -1, userInfo: nil))
                    return
                }
                switch source {
                case .Raw(let contentType, let identifier):
                    SIMLog.debug("raw => \(contentType) => \(identifier)")
                    break // 转发
                case .Local(let contentType, let path):
                    SIMLog.debug("local => \(contentType) => \(path)")
                    let path = NSURL(fileURLWithPath: path)
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
                    break // 文件
                case .Network(let contentType, let address):
                    SIMLog.debug("network => \(contentType) => \(address)")
                    break // o
                }
            default:
                // 直接返回
                op.success(url)
                // 应该请求网络.
                //op.failure(NSError(domain: "Unknow scheme", code: -1, userInfo: nil))
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