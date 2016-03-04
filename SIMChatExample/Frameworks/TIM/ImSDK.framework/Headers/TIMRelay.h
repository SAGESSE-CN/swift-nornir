//
//  TIMRelay.h
//  ImSDK
//
//  Created by tomzhu on 15/12/22.
//  Copyright © 2015年 tencent. All rights reserved.
//

#ifndef TIMRelay_h
#define TIMRelay_h

#import "TIMComm.h"

typedef void (^TIMRelaySucc)(NSData * data);

/**
 *  数据透传
 */
@interface TIMRelay : NSObject

/**
 *  获取数据透传对象实例
 *
 *  @return 数据透传对象
 */
+(TIMRelay*) sharedInstance;

/**
 *  加密方式转发数据到服务器，仅登录状态可用
 *
 *  @param data 业务数据
 *  @param succ 成功时回调
 *  @param fail 失败时回调
 *
 *  @return 0 表示成功
 */
-(int) SendDataWithEncryption:(NSData*)data succ:(TIMRelaySucc)succ fail:(TIMFail)fail;

/**
 *  加密方式转发数据到服务器，仅登录状态可用
 *
 *  @param data 业务数据
 *  @param timeout 回包超时时间（单位:秒）
 *  @param succ 成功时回调
 *  @param fail 失败时回调
 *
 *  @return 0 表示成功
 */
-(int) SendDataWithEncryption:(NSData*)data timeout:(int)timeout succ:(TIMRelaySucc)succ fail:(TIMFail)fail;

/**
 *  透传方式转发数据到服务器，可在未登录状态使用
 *
 *  @param data 业务数据
 *  @param succ 成功时回调
 *  @param fail 失败时回调
 *
 *  @return 0 表示成功
 */
-(int) SendDataWithoutEncryption:(NSData*)data succ:(TIMRelaySucc)succ fail:(TIMFail)fail;

/**
 *  透传方式转发数据到服务器，可在未登录状态使用
 *
 *  @param data 业务数据
 *  @param timeout 回包超时时间（单位:秒）
 *  @param succ 成功时回调
 *  @param fail 失败时回调
 *
 *  @return 0 表示成功
 */
-(int) SendDataWithoutEncryption:(NSData*)data timeout:(int)timeout succ:(TIMRelaySucc)succ fail:(TIMFail)fail;

@end

#endif
