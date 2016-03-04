//
//  TLSOpenLoginListener.h
//  TLSSDK
//
//  Created by okhowang on 15/11/6.
//
//

#ifndef TLSSDK_TLSOpenLoginListener_h
#define TLSSDK_TLSOpenLoginListener_h

#include "TLSUserInfo.h"
#include "TLSErrInfo.h"

@protocol TLSOpenLoginListener <NSObject>
/**
 * 登录成功
 * @param userInfo 登录成功的帐号信息
 */
-(void)OnOpenLoginSuccess:(TLSUserInfo*)userInfo;
/**
 * 登录失败
 * @param errInfo 失败信息
 */
-(void)OnOpenLoginFail:(TLSErrInfo*)errInfo;
/**
 * 登录超时
 * @param errInfo 失败信息
 */
-(void)OnOpenLoginTimeout:(TLSErrInfo*)errInfo;

@end

#endif /* TLSSDK_TLSOpenLoginListener_h */
