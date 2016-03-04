//
//  TLSPwdLoginListener.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-20.
//
//
#ifndef TLSSDK_TLSPwdLoginListener_h
#define TLSSDK_TLSPwdLoginListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

/// 密码登录回调
@protocol TLSPwdLoginListener <NSObject>

/**
 *  密码登陆要求验证图片验证码
 *
 *  @param picData 图片验证码
 *  @param errInfo 错误信息
 */
-(void)	OnPwdLoginNeedImgcode:(NSData *)picData andErrInfo:(TLSErrInfo *)errInfo;

/**
 *  密码登陆请求图片验证成功
 *
 *  @param picData 图片验证码
 */
-(void)	OnPwdLoginReaskImgcodeSuccess:(NSData *)picData;

/**
 *  密码登陆成功
 *
 *  @param userInfo 用户信息
 */
-(void)	OnPwdLoginSuccess:(TLSUserInfo *)userInfo;

/**
 *  密码登陆失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdLoginFail:(TLSErrInfo *)errInfo;

/**
 *  秘密登陆超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnPwdLoginTimeout:(TLSErrInfo *)errInfo;

@end
#endif
