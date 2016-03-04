//
//  TLSOpenBindListener.h
//  TLSSDK
//
//  Created by okhowang on 15/10/19.
//
//

#ifndef TLSSDK_TLSOpenBindListener_h
#define TLSSDK_TLSOpenBindListener_h

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"

@protocol TLSOpenBindListener <NSObject>

/**
 * 绑定成功
 */
-(void)OnOpenBindSuccess;
/**
 * 绑定失败
 * @param errInfo 错误信息
 */
-(void)OnOpenBindFail:(TLSErrInfo*)errInfo;
/**
 * 绑定超时
 * @param errInfo 错误信息
 */
-(void)OnOpenBindTimeout:(TLSErrInfo*)errInfo;

@end

#endif /* TLSSDK_TLSOpenBindListener_h */
