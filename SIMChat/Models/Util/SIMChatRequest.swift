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
    public typealias Operator = (success: (R -> Void), failure: (NSError -> Void))
    
    ///
    /// 发出请求.
    ///
    public static func request(clouser: (Operator -> Void)) -> Self {
        let request = self.init()
        request.execute(clouser)
        return request
    }
    ///
    /// 响应
    ///
    public func response(clouser: (Result -> Void)) -> Self {
        responseClouser = clouser
        return self
    }
    
    public func progress(clouser: (Float -> Void)) -> Self {
        return self
    }
    
    /// 延迟执行
    private func execute(clouser: (Operator -> Void)) {
        let runLoop = CFRunLoopGetCurrent()
        let runLoopMode = kCFRunLoopCommonModes//kCFRunLoopDefaultMode
        let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.BeforeWaiting.rawValue, false, 0) { observer, _ in
            CFRunLoopRemoveObserver(runLoop, observer, runLoopMode)
            
            clouser(Operator(success: { self.responseClouser?(.Success($0)) },
                             failure: { self.responseClouser?(.Failure($0)) }))
        }
        
        CFRunLoopAddObserver(runLoop, observer, runLoopMode)
    }
    
    private var responseClouser: (Result -> Void)?
}

