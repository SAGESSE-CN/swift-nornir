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
public enum SIMChatResult<ValueType, ErrorType: Error> {
    case success(ValueType)
    case failure(ErrorType)

    /// Returns `true` if the result is a success, `false` otherwise.
    public var isSuccess: Bool {
        switch self {
        case .success:
            return true
        case .failure:
            return false
        }
    }

    /// Returns `true` if the result is a failure, `false` otherwise.
    public var isFailure: Bool {
        return !isSuccess
    }

    /// Returns the associated value if the result is a success, `nil` otherwise.
    public var value: ValueType? {
        switch self {
        case .success(let value):
            return value
        case .failure:
            return nil
        }
    }

    /// Returns the associated error value if the result is a failure, `nil` otherwise.
    public var error: ErrorType? {
        switch self {
        case .success:
            return nil
        case .failure(let error):
            return error
        }
    }
}
