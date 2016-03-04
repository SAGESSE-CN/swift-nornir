//
//  TLSSmsLoginListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//
#ifndef TLSSDK_TLSSmsLoginListener_h
#define TLSSDK_TLSSmsLoginListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"

/// 短信登录回调
@protocol TLSSmsLoginListener <NSObject>
@required
/**
 *  请求短信验证码成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void) OnSmsLoginAskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;

/**
 *  刷新短信验证码请求成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnSmsLoginReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;

/**
 *  验证短信验证码成功
 */
-(void)	OnSmsLoginVerifyCodeSuccess;

/**
 *  短信登陆成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnSmsLoginSuccess:(TLSUserInfo *) userInfo;

/**
 *  短信登陆失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnSmsLoginFail:(TLSErrInfo *) errInfo;

/**
 *  短信登陆超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnSmsLoginTimeout:(TLSErrInfo *)errInfo;

@end
#endif
