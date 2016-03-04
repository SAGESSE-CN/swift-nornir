//
//  TLSOpenQueryListener.h
//  TLSSDK
//
//  Created by okhowang on 15/10/19.
//
//

#ifndef TLSSDK_TLSOpenQueryListener_h
#define TLSSDK_TLSOpenQueryListener_h

#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSUserInfo.h"

enum TLSOpenState{
    TLS_OPEN_STATE_UNUSED = 3, //未使用过的第三方帐号
    TLS_OPEN_STATE_USED = 2,   //使用过的第三方帐号
    TLS_OPEN_STATE_BINDED = 1, //已绑定自有帐号的第三方帐号
};
/// 查询第三方绑定关系回调接口
@protocol TLSOpenQueryListener <NSObject>

@required
/**
 *  查询成功
 */
-(void)	OnOpenQuerySuccess:(enum TLSOpenState)state;


/**
 *  查询失败
 *  @param errInfo 错误信息
 */
-(void)	OnOpenQueryFail:(TLSErrInfo *) errInfo;

/**
 *  查询超时
 *  @param errInfo 错误信息
 */
-(void)	OnOpenQueryTimeout:(TLSErrInfo *) errInfo;

@end

#endif /* TLSSDK_TLSOpenQueryListener_h */
