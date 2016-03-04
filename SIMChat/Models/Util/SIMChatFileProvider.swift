//
//  SIMChatFileProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

///// 来源
//public enum SIMChatFileProviderSource {
//    case Raw(identifier: String)    // 原始数据
//    case Local(path: String)  // 本地文件
//    case Network(address: NSURL) // 网络文件
//    
//    // 从URL识别
//    public init?(URL: NSURL) {
//        guard let components = NSURLComponents(URL: URL, resolvingAgainstBaseURL: false) else {
//            return nil // 错误
//        }
//        guard components.scheme == "simchat" else {
//            return nil // 未知
//        }
//        guard let source = components.host, parameter = components.query else {
//            return nil // 参数错误
//        }
//        switch source {
//        case "chat.raw.sa":      self = .Raw(identifier: parameter)
//        case "chat.local.sa":    self = .Local(path: parameter)
//        case "chat.network.sa":  self = .Network(address: NSURL(string: parameter)!)
//        default:            return nil
//        }
//    }
//    // 转为URL
//    public var URL: NSURL {
//        let components = NSURLComponents()
//        components.scheme = "simchat"
//        switch self {
//        case .Raw(let identifier):
//            components.host = "chat.raw.sa"
//            components.path = "/param"
//            components.query = identifier
//        case .Local(let path):
//            components.host = "chat.local.sa"
//            components.path = "/param"
//            components.query = path
//        case .Network(let address):
//            components.host = "chat.network.sa"
//            components.path = "/param"
//            components.query = address.relativeString
//        }
//        return components.URL!
//    }
//}
//
///
/// 文件请求
///
public class SIMChatFileRequest {
    ///
    /// 操作返回结果
    ///
    public typealias Result = SIMChatResult<AnyObject, NSError>
    
    /// 响应
    public func response(completionHandler: (Result -> Void)) -> Self {
        responseClouser = completionHandler
        return self
    }
    
    /// 响应图片
    public func responseImage(completionHandler: (SIMChatResult<UIImage?, NSError> -> Void)) -> Self {
        return response {
                do {
                    guard !self._isCancel else {
                        throw NSError(domain: "Use Cancel", code: -1, userInfo: nil)
                    }
                    guard let value = $0.value else {
                        throw $0.error ?? NSError(domain: "Unknow Error", code: -1, userInfo: nil)
                    }
                    let completion = { (img: UIImage?) in
                        dispatch_async(dispatch_get_main_queue()) {
                            completionHandler(.Success(img))
                        }
                    }
                    switch value {
                    case let path as String:
                        dispatch_async(dispatch_get_global_queue(0, 0)) {
                            let img = UIImage(contentsOfFile: path)
                            completion(img)
                        }
                    case let URL as NSURL:
                        dispatch_async(dispatch_get_global_queue(0, 0)) {
                            if let path = URL.path where URL.scheme == "file" {
                                let img = UIImage(contentsOfFile: path)
                                completion(img)
                            } else {
                                let data = NSData(contentsOfURL: URL)
                                let img = UIImage(data: data!)
                                completion(img)
                            }
                        }
                    default:
                            completionHandler(.Success(nil))
                        throw NSError(domain: "unsupport type", code: -1, userInfo: nil)
                    }
                } catch let error as NSError {
                    completionHandler(.Failure(error))
                }
            // clear
            self.responseClouser = nil
        }
    }
    
    public func cancel() {
        SIMLog.trace()
        _isCancel = true
    }
    
    private var _isCancel: Bool = false
    
    private var responseClouser: (Result -> Void)?
}

///
/// 文件提供者. <br>
/// 提供关于url的一些操作
///
public class SIMChatFileProvider {
    public static func sharedInstance() -> SIMChatFileProvider {
        return _sharedInstance
    }
    
    ///
    /// 注册解释器
    ///
//    public func register(parser: SIMChatParserProtocol) {
//        SIMLog.debug("\(parser.identifier) => \(parser.dynamicType)")
//        _parsers[parser.identifier] = parser
//    }
    
    /// 解释URL
    private func _parseURL(URL: NSURL, success: (AnyObject -> Void)?, fail: (NSError -> Void)?) {
//        // 读取
//        let parser: SIMChatParserProtocol = {
//            let p = SIMChatBaseFileParser.sharedInstance()
//            guard let key = URL.user where URL.scheme == "simchat" else {
//                return p
//            }
//            return _parsers[key] ?? p
//        }()
//        // 解释
//        parser.decode(URL, success: success, fail: fail)
        
    }
    
    func cached(url: NSURL) -> Bool {
        return false
    }
    
    var c: UIImage?
    
    /// 加载资源
    public func loadResource(resource: SIMChatResourceProtocol, canCache: Bool = true, closure: SIMChatResult<AnyObject, NSError> -> Void) {
        let identifier = resource.identifier
        // 读取缓存
        if let value = _cache.objectForKey(identifier) {
            SIMLog.debug("\(identifier) hit cache")
            // 直接完成
            closure(.Success(value))
        } else {
            SIMLog.debug("\(identifier) load resouce")
            // 真实的加载
            resource.resource { [weak self] result in
                // 只缓存成功
                if let value = result.value where canCache {
                    self?._cache.setObject(value, forKey: identifier)
                }
                guard !NSThread.isMainThread() else {
                    closure(result)
                    return
                }
                dispatch_async(dispatch_get_main_queue()) {
                    closure(result)
                }
            }
        }
    }
    
    /// 缓存.
    private let _cache = NSCache()
    
    func download(URL: NSURL) -> SIMChatFileRequest {
        let request = SIMChatFileRequest()
        SIMChatRequest<Void>.request { op in
            
            
////            self._parseURL(URL,
////                success: { v in
////                    if let path = v as? String {
                        request.responseClouser?(.Success(URL))
////                    } else {
////                        request.responseClouser?(.Success(v))
////                    }
////                },
////                fail: {
////                    request.responseClouser?(.Failure($0))
////                })
        }
        return request
        
//        return SIMChatRequest.request { op in
//        }
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
    
//    private lazy var _parsers: Dictionary<String, SIMChatParserProtocol> = [:]
    
    private static var _sharedInstance = SIMChatFileProvider()
}



public let SIMChatFileProviderWillLoad = "SIMChatFileProviderWillLoad"
public let SIMChatFileProviderDidLoad = "SIMChatFileProviderDidLoad"
public let SIMChatFileProviderWillDownload = "SIMChatFileProviderWillDownload"
public let SIMChatFileProviderDidDownload = "SIMChatFileProviderDidDownload"