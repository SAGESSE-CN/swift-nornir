//
//  TLSPwdRegListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-18.
//
//
#ifndef TLSSDK_TLSPwdRegListener_h
#define TLSSDK_TLSPwdRegListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

/// 密码注册回调接口
@protocol TLSPwdRegListener <NSObject>

/**
 *  请求短信验证码成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnPwdRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int) expireDuration;

/**
 *  刷新短信验证码请求成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnPwdRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;

/**
 *  验证短信验证码成功
 */
-(void)	OnPwdRegVerifyCodeSuccess;

/**
 *  提交注册成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnPwdRegCommitSuccess:(TLSUserInfo *)userInfo;

/**
 *  短信注册失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdRegFail:(TLSErrInfo *) errInfo;

/**
 *  短信注册超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdRegTimeout:(TLSErrInfo *) errInfo;

@end
#endif
