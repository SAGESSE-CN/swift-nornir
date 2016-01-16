//
//  SIMChatResult.swift
//  SIMChat
//
//  Created by sagesse on 1/15/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

///
/// 结果
///
public enum SIMChatResult<Value, Error: ErrorType> {
    case Success(Value)
    case Failure(Error)

    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .Success:
            return true
        case .Failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: Value? {
        switch self {
        case .Success(let value):
            return value
        case .Failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: Error? {
        switch self {
        case .Success:
            return nil
        case .Failure(let error):
            return error
        }
    }
}
