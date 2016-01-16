//
//  SIMChatRequest.swift
//  SIMChat
//
//  Created by sagesse on 1/15/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

///
/// 请求.
///
public final class SIMChatRequest<R> {
    ///
    /// 操作返回结果
    ///
    public typealias Result = SIMChatResult<R, NSError>
    ///
    /// 发出请求.
    ///
    public static func request(clouser: ((success: (R -> Void), failure: (NSError -> Void)) -> Void)) -> Self {
        let request = self.init()
        dispatch_async(SIMChatRequestQueue) {
            clouser(success: { request.responseClouser?(.Success($0)) },
                    failure: { request.responseClouser?(.Failure($0)) })
        }
        return request
    }
    
    ///
    /// 响应
    ///
    public func response(clouser: (Result -> Void)) -> Self {
        responseClouser = clouser
        return self
    }
    
    private var responseClouser: (Result -> Void)?
}

public let SIMChatRequestQueue = dispatch_get_global_queue(0, 0)