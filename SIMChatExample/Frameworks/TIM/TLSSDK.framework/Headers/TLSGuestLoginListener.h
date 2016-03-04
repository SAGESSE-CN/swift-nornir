//
//  TLSGuestLoginListener.h
//  TLSSDK
//
//  Created by okhowang on 15/8/18.
//
//

#ifndef TLSSDK_TLSGuestLoginListener_h
#define TLSSDK_TLSGuestLoginListener_h

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

/// 匿名登录回调接口
@protocol TLSGuestLoginListener <NSObject>

/**
 *  登录成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnGuestLoginSuccess:(TLSUserInfo *)userInfo;

/**
 *  登录失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnGuestLoginFail:(TLSErrInfo *) errInfo;

/**
 *  登录超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnGuestLoginTimeout:(TLSErrInfo *) errInfo;
@end

#endif
