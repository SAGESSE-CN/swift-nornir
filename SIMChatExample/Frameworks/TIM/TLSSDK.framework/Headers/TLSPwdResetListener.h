//
//  TLSPwdResetListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-18.
//
//
#ifndef TLSSDK_TLSPwdResetListener_h
#define TLSSDK_TLSPwdResetListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"

/// 密码重置回调接口
@protocol TLSPwdResetListener <NSObject>

/**
 *  请求短信验证码成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnPwdResetAskCodeSuccess:(int)reaskDuration andExpireDuration:(int) expireDuration;

/**
 *  刷新短信验证码请求成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnPwdResetReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;

/**
 *  验证短信验证码成功
 */
-(void)	OnPwdResetVerifyCodeSuccess;

/**
 *  提交注册成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnPwdResetCommitSuccess:(TLSUserInfo *)userInfo;

/**
 *  短信注册失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdResetFail:(TLSErrInfo *) errInfo;

/**
 *  短信注册超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdResetTimeout:(TLSErrInfo *) errInfo;

@end
#endif
