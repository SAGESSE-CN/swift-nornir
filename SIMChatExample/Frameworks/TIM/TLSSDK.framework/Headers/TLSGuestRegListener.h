//
//  TLSGuestRegListener.h
//  TLSSDK
//
//  Created by okhowang on 15/8/17.
//
//

#ifndef TLSSDK_TLSGuestRegListener_h
#define TLSSDK_TLSGuestRegListener_h

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

/// 匿名注册回调接口
@protocol TLSGuestRegListener <NSObject>

/**
 *  注册成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnGuestRegSuccess:(TLSUserInfo *)userInfo;

/**
 *  注册失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnGuestRegFail:(TLSErrInfo *) errInfo;

/**
 *  注册超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnGuestRegTimeout:(TLSErrInfo *) errInfo;
@end

#endif
