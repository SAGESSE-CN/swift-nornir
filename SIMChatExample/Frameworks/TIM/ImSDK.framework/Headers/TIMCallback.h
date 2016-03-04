//
//  TIMCallback.h
//  ImSDK
//
//  Created by bodeng on 30/3/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMCallback_h
#define ImSDK_TIMCallback_h

#import "TIMComm.h"

/**
 *  回调
 */
@protocol TIMCallback <NSObject>

/**
 *  成功
 */
- (void) onSucc;

/**
 *  消息发送失败
 *
 *  @param errCode 失败错误码
 *  @param errMsg  失败错误描述
 */
- (void)onErr:(int)errCode errMsg:(NSString*)errMsg;
@end

/**
 *  消息读取回调
 */
@protocol TIMGetMessageCallback <NSObject>

/**
 *  消息读取成功
 *
 *  @param msgs 消息列表，TIMMessage 数组
 */
- (void) onSucc:(NSArray *) msgs;

/**
 *  消息发送失败
 *
 *  @param errCode 失败错误码
 *  @param errMsg  失败错误描述
 */
- (void)onErr:(int)errCode errMsg:(NSString*)errMsg;

@end


/**
 *  资源(图片/声音等)回调
 */
@protocol TIMResourceCallback <NSObject>

/**
 *  资源二进制信息
 *
 *  @param data 二进制
 */
- (void) onSucc:(NSData *) data;

/**
 *  消息发送失败
 *
 *  @param errCode 失败错误码
 *  @param errMsg  失败错误描述
 */
- (void)onErr:(int)errCode errMsg:(NSString*)errMsg;

@end


/**
 *  日志监听回调
 */
@protocol TIMLogListener <NSObject>

/**
 *  回调日志接口
 *
 *  @param lvl 日志级别
 *  @param content 日志内容
 */
- (void) log:(TIMLogLevel)lvl content:(NSString*)content;

@end

#endif
