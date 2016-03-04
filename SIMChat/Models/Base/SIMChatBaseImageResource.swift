//
//  SIMChatBaseImageResource.swift
//  SIMChat
//
//  Created by sagesse on 3/4/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

///
/// 图片资源
///
public class SIMChatBaseImageResource: SIMChatBaseFileResource {
    ///
    /// 获取资源
    ///
    /// - parameter closure: 结果回调
    ///
    public override func resource(closure: SIMChatResult<AnyObject, NSError> -> Void) {
        switch value {
        case .URL(let URL):
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                if let data = NSData(contentsOfURL: URL) {
                    if let image = UIImage(data: data) {
                        closure(.Success(image))
                    } else {
                        closure(.Failure(NSError(domain: "LoadImage Failure", code: -1, userInfo: nil)))
                    }
                } else {
                    closure(.Failure(NSError(domain: "DownloadImage Failure", code: -1, userInfo: nil)))
                }
            }
        case .Path(let path):
            dispatch_async(dispatch_get_global_queue(0, 0)) {
                if let image = UIImage(contentsOfFile: path) {
                    closure(.Success(image))
                } else {
                    closure(.Failure(NSError(domain: "LoadImage Failure", code: -1, userInfo: nil)))
                }
            }
        case .Custom(let value):
            // 直接下一级
            closure(.Success(value))
        }
    }
}
