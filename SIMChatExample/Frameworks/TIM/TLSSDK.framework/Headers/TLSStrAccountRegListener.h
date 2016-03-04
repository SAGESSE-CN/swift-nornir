//
//  TLSStrAccountRegListener.h
//  TLSSDK
//
//  Created by yaoli on 15/7/27.
//
//
#ifndef TLSSDK_TLSStrAccountRegListener_h
#define TLSSDK_TLSStrAccountRegListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

/// 字符串账号+密码注册回调接口
@protocol TLSStrAccountRegListener <NSObject>

@required
/**
 *  注册成功
 */
-(void)	OnStrAccountRegSuccess:(TLSUserInfo*)userInfo;


/**
 *  注册失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnStrAccountRegFail:(TLSErrInfo *) errInfo;

/**
 *  注册超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnStrAccountRegTimeout:(TLSErrInfo *) errInfo;


@end
#endif
