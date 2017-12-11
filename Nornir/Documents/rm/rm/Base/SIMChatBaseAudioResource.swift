//
//  SIMChatBaseAudioResource.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

//public class SIMChatBaseAudioResource: SIMChatBaseFileResource {
//    ///
//    /// 获取资源
//    ///
//    /// - parameter closure: 结果回调
//    ///
//    public override func resource(_ closure: (SIMChatResult<AnyObject, NSError>) -> Void) {
//        switch value {
//        case .url(let URL):
//            closure(.success(URL))
//        case .path(let path):
//            closure(.success(URL(fileURLWithPath: path)))
//        case .custom(let value):
//            if let value = value as? Data {
//                closure(.success(value))
//            } else {
//                closure(.failure(NSError(domain: "Unsupport content", code: -1, userInfo: nil)))
//            }
//        }
//    }
//}
