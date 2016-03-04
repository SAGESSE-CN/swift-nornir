//
//  TLSUserInfo.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//
#ifndef TLSSDK_TLSUserInfo_h
#define TLSSDK_TLSUserInfo_h
#import <Foundation/Foundation.h>
#include <AvailabilityMacros.h>
/// 用户信息
@interface TLSUserInfo : NSObject
{
    /// 帐号类型
    uint32_t	accountType DEPRECATED_ATTRIBUTE;
    /// 用户id
    NSString*   identifier;
}

/// 帐号类型
@property (assign)  uint32_t    accountType;

/// 用户id
@property (copy)    NSString*   identifier;

@end
#endif
