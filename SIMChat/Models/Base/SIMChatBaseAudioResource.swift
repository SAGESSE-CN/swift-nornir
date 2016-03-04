//
//  SIMChatBaseAudioResource.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

public class SIMChatBaseAudioResource: SIMChatBaseFileResource {
    ///
    /// 获取资源
    ///
    /// - parameter closure: 结果回调
    ///
    public override func resource(closure: SIMChatResult<AnyObject, NSError> -> Void) {
        switch value {
        case .URL(let URL):
            closure(.Success(URL))
        case .Path(let path):
            closure(.Success(NSURL(fileURLWithPath: path)))
        case .Custom(let value):
            if let value = value as? NSData {
                closure(.Success(value))
            } else {
                closure(.Failure(NSError(domain: "Unsupport content", code: -1, userInfo: nil)))
            }
        }
    }
}
