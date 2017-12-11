//
//  SIMChatBaseImageResource.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

/////
///// 图片资源
/////
//public class SIMChatBaseImageResource: SIMChatBaseFileResource {
//    ///
//    /// 获取资源
//    ///
//    /// - parameter closure: 结果回调
//    ///
//    public override func resource(_ closure: @escaping (SIMChatResult<AnyObject, NSError>) -> Void) {
//        switch value {
//        case .url(let URL):
//            DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(0))).async {
//                if let data = try? Data(contentsOf: URL) {
//                    if let image = UIImage(data: data) {
//                        closure(.success(image))
//                    } else {
//                        closure(.failure(NSError(domain: "LoadImage Failure", code: -1, userInfo: nil)))
//                    }
//                } else {
//                    closure(.failure(NSError(domain: "DownloadImage Failure", code: -1, userInfo: nil)))
//                }
//            }
//        case .path(let path):
//            DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(0))).async {
//                if let image = UIImage(contentsOfFile: path) {
//                    closure(.success(image))
//                } else {
//                    closure(.failure(NSError(domain: "LoadImage Failure", code: -1, userInfo: nil)))
//                }
//            }
//        case .custom(let value):
//            // 直接下一级
//            closure(.success(value))
//        }
//    }
//}
