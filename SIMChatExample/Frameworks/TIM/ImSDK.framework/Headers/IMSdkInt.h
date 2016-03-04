//
//  IMSdkInt.h
//  ImSDK
//
//  Created by bodeng on 10/12/14.
//  Copyright (c) 2014 tencent. All rights reserved.
//

#ifndef ImSDK_IMSdkInt_h
#define ImSDK_IMSdkInt_h

#import <Foundation/Foundation.h>
#import "IMSdkComm.h"
#import "AVMultiInvitProtocols.h"
#import "TIMComm.h"


@class TIMAVTestSpeedResp_PKG;

/**
 *  音视频接口
 */
@interface IMSdkInt : NSObject

/**
 *  获取 IMSdkInt 全局对象
 *
 *  @return IMSdkInt 对象
 */
+(IMSdkInt*)sharedInstance;

/**
 *  获取当前登陆用户 TinyID
 *
 *  @return tinyid
 */
-(unsigned long long) getTinyId;

/**
 * 设置音视频版本号
 */
-(void) setAvSDKVersion : (NSString *) ver;

/**
 *  UserId 转 TinyId
 *
 *  @param userIdList userId列表，IMUserId 结构体
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
-(int)userIdToTinyId:(NSArray*)userIdList okBlock:(OMUserIdSucc)succ errBlock:(OMErr)err;

/**
 *  TinyId 转 UserId
 *
 *  @param tinyIdList tinyId列表，unsigned long long类型
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
-(int)tinyIdToUserId:(NSArray*)tinyIdList okBlock:(OMUserIdSucc)succ errBlock:(OMErr)err;


/**
 *  多人音视频请求
 *
 *  @param reqbody 请求二进制数据
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
-(int)requestMultiVideoApp:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;
-(int)requestMultiVideoInfo:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

/**
 *  音频测速请求
 *
 *  @param bussType 业务类型
 *  @param authType 鉴权类型
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
- (int)requestMeasureSpeedWith:(short)bussType authType:(short)authType succ:(OMCommandSucc)succ fail:(OMErr)fail;

/**
 *  音频测速结果上报
 *
 *  @param resp requestMeasureSpeedWith:authType:succ:fail 成功时返回的响应中序列化出来的对像
 *  @param bussType 鉴权类型(同requestMeasureSpeedWith:authType:succ:fail 中的 bussType)
 *  @param authType 鉴权类型(同requestMeasureSpeedWith:authType:succ:fail 中的 authtype)
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
- (int)reportMeasureSpeedResult:(TIMAVTestSpeedResp_PKG *)resp  bussType:(short)bussType authType:(short)authType  succ:(OMCommandSucc)succ fail:(OMErr)fail;



/**
 *  多人音视频发送请求
 *
 *  @param serviceCmd 命令字
 *  @param reqbody    发送包体
 *  @param succ       成功回调
 *  @param err        失败回调
 *
 *  @return 0 成功
 */
- (int)requestOpenImRelay:(NSString*)serviceCmd req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

/**
 *  设置超时时间
 *
 *  @param timeout 超时时间
 */
-(void)setReqTimeout:(int)timeout;


/**
 *  双人音视频请求
 *
 *  @param tinyid  接收方 tinyid
 *  @param reqbody 请求包体
 *  @param succ    成功回调
 *  @param err     失败回调
 *
 *  @return 0 成功
 */
-(int)requestSharpSvr:(unsigned long long)tinyid req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;

-(int)responseSharpSvr:(unsigned long long)tinyid req:(NSData*)reqbody okBlock:(OMCommandSucc)succ errBlock:(OMErr)err;


/**
 *  设置双人音视频监听回调
 *
 *  @param succ 成功回调，有在线消息时调用
 *  @param err  失败回调，在线消息解析失败或者包体错误码不为0时调用
 *
 *  @return 0 成功
 */
-(int)setSharpSvrPushListener:(OMCommandSucc)succ errBlock:(OMErr)err;
-(int)setSharpSvrRspListener:(OMCommandSucc)succ errBlock:(OMErr)err;


/**
 *  发送请求
 *
 *  @param cmd  命令字
 *  @param body 包体
 *  @param succ 成功回调，返回响应数据
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int) request:(NSString*)cmd body:(NSData*)body succ:(OMRequestSucc)succ fail:(OMRequsetFail)fail;

/**
 *  发送创建直播频道,开启推流的请求
 *
 *  @param roomInfo    房间信息
 *  @param streamInfo  推流参数
 *  @param succ        成功回调,返回频道ID
 *  @param fail        失败回调,返回错误码
 *
 *  @return 0 发包成功
 */
- (int)requestMultiVideoStreamerStart:(OMAVRoomInfo *)roomInfo streamInfo:(AVStreamInfo *)streamInfo okBlock:(OMMultiVideoStreamerStartSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送关闭直播频道,停止推流的请求
 *
 *  @param roomInfo    房间信息
 *  @param channelIDs  频道ID NSNumber*列表
 *  @param succ        成功回调
 *  @param fail        失败回调,返回错误码
 *
 *  @return 0 发包成功
 */
- (int)requestMultiVideoStreamerStop:(OMAVRoomInfo *)roomInfo channelIDs:(NSArray *)channelIDs okBlock:(OMMultiSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送开始录制请求
 *
 *  @param roomInfo    房间信息
 *  @param recordInfo  录制请求参数
 *  @param succ        成功回调
 *  @param fail        失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoRecorderStart:(OMAVRoomInfo *)roomInfo recordInfo:(AVRecordInfo *)recordInfo okBlock:(OMMultiSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送停止录制请求
 *
 *  @param roomInfo    房间信息
 *  @param succ        成功回调，返回文件ID
 *  @param fail        失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestMultiVideoRecorderStop:(OMAVRoomInfo *)roomInfo okBlock:(OMMultiVideoRecorderStopSucc)succ errBlock:(OMMultiFail)fail;

/**
 *  发送多人音视频邀请
 *
 *  @param bussType 业务类型
 *  @param authType 鉴权类型
 *  @param authid  鉴权ID
 *  @param requestType:
 *  1-----发起发发起音视频邀请
    2-----发起方取消音视频邀请
    3-----接收方接受音视频邀请
    4-----接收方拒绝音视频邀请
 *  @param receiversArray  向这些人发送邀请, NSString 数组
 *  @roomid 房间号
 *  @param byteBuf : 业务自定义buf
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
- (int)requestVideoInvitation:(int)bussType authType:(int)authType authid:(unsigned int)authid requestType:(int)requestType receivers:(NSArray *)receiversArray roomid:(long long)roomid bytesBuffer:(NSData *)byteBuf  okBlock:(OMCommandSucc)succ errBlock:(OMErr)fail;
- (int)requestVideoInvitation:(id<AVMultiInvitationReqAble>)invite okBlock:(OMCommandSucc)succ errBlock:(OMErr)fail;

/**
 *  发送质量上报请求
 *
 *  @param data  上报的数据
 *  @param type  上报数据类型
 *  @param succ  成功回调
 *  @param fail  失败回调，返回错误码
 *
 *  @return 0 发包成功
 */
-(int)requestQualityReport:(NSData *)data type:(unsigned int)type succ:(OMMultiSucc)succ fail:(OMMultiFail)fail;


-(void) doIMPush:(NSData*)body;


/**
 * Crash 日志
 *
 * @param   level    日志级别
 * @param   tag      日志模块分类
 * @param   content  日志内容
 */
-(void)logBugly:(TIMLogLevel)level tag:(NSString *) tag log:(NSString *)content;

@end

#endif
