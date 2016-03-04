//
//  TLSSmsRegListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-18.
//
//
#ifndef TLSSDK_TLSSmsRegListener_h
#define TLSSDK_TLSSmsRegListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"

/// 短信注册回调接口
@protocol TLSSmsRegListener <NSObject>

/**
 *  请求短信验证码成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnSmsRegAskCodeSuccess:(int)reaskDuration andExpireDuration:(int) expireDuration;

/**
 *  刷新短信验证码请求成功
 *
 *  @param reaskDuration 下次请求间隔
 *  @param expireDuration 验证码有效期
 */
-(void)	OnSmsRegReaskCodeSuccess:(int)reaskDuration andExpireDuration:(int)expireDuration;

/**
 *  验证短信验证码成功
 */
-(void)	OnSmsRegVerifyCodeSuccess;

/**
 *  提交注册成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnSmsRegCommitSuccess:(TLSUserInfo *)userInfo;

/**
 *  短信注册失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnSmsRegFail:(TLSErrInfo *) errInfo;

/**
 *  短信注册超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnSmsRegTimeout:(TLSErrInfo *) errInfo;

@end
#endif
