//
//  TLSExchangeTicketListener.h
//  TLSSDK
//
//  Created by yaoli on 15/8/6.
//
//

#ifndef TLSSDK_TLSExchangeTicketListener_h
#define TLSSDK_TLSExchangeTicketListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"


/// 独立模式换票回调 UserSig换A2
@protocol TLSExchangeTicketListener <NSObject>

/**
 *  刷新票据成功
 *  在此回调接口内，可以调用getSSOTicket获取A2等票据
 */
-(void)	OnExchangeTicketSuccess;

/**
 *  刷新票据失败
 *
 *  @param errInfo 错误信息
 */
-(void)	OnExchangeTicketFail:(TLSErrInfo *)errInfo;

/**
 *  刷新票据超时
 *
 *  @param errInfo 错误信息
 */
-(void)	OnExchangeTicketTimeout:(TLSErrInfo *)errInfo;
@end
#endif
