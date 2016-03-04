//
//  TLSTokenInfo.h
//  TLSSDK
//
//  Created by okhowang on 15/11/16.
//
//
#ifndef TLSSDK_TLSTLSTokenInfo_h
#define TLSSDK_TLSTLSTokenInfo_h
#import <Foundation/Foundation.h>

@interface TLSTokenInfo : NSObject
@property NSString* openid;
@property NSString* accessToken;
@property NSString* refreshToken;
@property NSString* scope;
@property NSString* unionid;
@property NSDate* expireTime;
@end
#endif
