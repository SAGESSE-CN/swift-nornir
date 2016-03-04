//
//  QalSDKProxy.h
//  QalSDK
//
//  Created by wtlogin on 15/8/7.
//  Copyright (c) 2015年 tencent. All rights reserved.
//
#ifndef QALSDK_PROXY_H
#define QALSDK_PROXY_H
#import <Foundation/Foundation.h>
#import "QalSDKCallbackProtocol.h"
#import "MsfDelegate.h"
#import <MsfSDK/MsfSDK.h>


#define SSOOPEN_REG @"sso_open_status.stat_reg"
#define SSOOPEN_HB  @"sso_open_status.stat_hello"

#define DEFAULT_LOG_SDK_PATH    @"/sdk.log"
#define DEFAULT_LOG_APP_PATH    @"/app.log"


@class QalStatusAdapter;
@class QalTokenDelegate;
@class QalBackgroundDelegate;
@class QalForegroundDelegate;
#ifdef QALSDK_FOR_TLS
@class TLSRefreshDelegate;

#endif
/**
 * 日志级别
 */
typedef NS_ENUM(NSInteger, LogLevel) {
    LOG_ERROR               = 1,
    LOG_WARN                = 2,
    LOG_INFO                = 3,
    LOG_DEBUG               = 4,
};

typedef enum _EQALBindFailReason
{
    EQALBindFail_Unknown = 0,   //未知错误
    EQALBindFail_NoSSOTicket,   //缺少sso票据
    EQALBindFail_NoNeedToUnbind,//已经unbind，不需要重复unbind
    EQALBindFail_TinyidNULL,//tiny为空
    EQALBindFail_GuidNULL,//guid为空
    EQALBindFail_UnpackRegPackFail,//解注册包失败
    EQALBindFail_RegTimeOut,//注册超时
    
    //>1000的错误码为状态svr返回
}EQALBindFailReason;

typedef enum _EQALPacketFailReason
{
    EQALPacketFail_Unknown = 0,
    EQALPacketFail_NoNetOnReq,
    EQALPacketFail_NoNetOnResp,
    EQALPacketFail_NoAuthOnReq,
    EQALPacketFail_SSOError,
    EQALPacketFail_TimeoutOnReq, //请求超时
    EQALPacketFail_TimeoutOnResp,//回包超时
    EQALPacketFail_NoResendOnReq,
    EQALPacketFail_NoResendOnResp,
    EQALPacketFail_FlowSaveFiltered,
    EQALPacketFail_OverLoadOnReq,
    EQALPacketFail_LogicError
}EQALPacketFailReason;




extern uint64_t g_tinyid;
extern uint32_t g_isready;









@interface QalSDKProxy : NSObject
{
    int env;
    int _sdkAppid;
    int _accType;
    id<QalConnListenerProtocol> _conncb;
    id<QalLogListenerProtocol> _logcb;
    id<QalUserStatusListenerProtocol> _statuscb;
    int shortConn;
}

@property uint64_t tinyid;
@property NSString* identy;
@property NSString* identy_temp;
@property (strong,nonatomic) MsfSDK* _msfsdk;
@property MsfDelegate* _delegate;
@property NSTimer* pushActTimer;
@property QalStatusAdapter* adapter;
@property NSString* guid;
@property NSString* user_identy;
@property NSString* anoy_identy;
@property (assign,nonatomic) uint64_t anony_tinyid;
@property uint64_t user_tinyid;
@property uint32_t guestmode;
@property id<QalBindCallbackProtocol> _logincb;
@property NSString* third_id;
@property uint32_t onlyconn;
@property (strong,nonatomic) id<QalTokenCallbackProtocol> _tokencb;
@property (strong,nonatomic) id<QalTokenCallbackProtocol> _backgroundcb;
@property (strong,nonatomic) id<QalTokenCallbackProtocol> _foregroundcb;
@property QalTokenDelegate* tokenadapter;
@property QalBackgroundDelegate* backadapter;
@property QalForegroundDelegate* foreadapter;
@property (strong,nonatomic) id<QalInitCallbackProtocol> _initcb;
#ifdef QALSDK_FOR_TLS
@property TLSRefreshDelegate* refreshdelegate;
#endif
@property (strong,nonatomic) QQLockDictionary*  _sendque;
@property uint32_t isready;
@property uint32_t isShortConn;
//@property (strong,nonatomic) NSLock* _lock;

/*
 获取QalSDK的实例
 */
+ (QalSDKProxy *)sharedInstance;

/*
 设置正式/测试环境
 @param value 0：正式环境，1：测试环境
 */
-(void)setEnv:(int) value;

/*
 初始化QalSDK
 @param sdkAppid sdkappid
 */

-(id)initQal:(int) sdkAppid;


/*
 初始化QalSDK
 @param appid msf appid
 @param sdkAppid sdkappid
 @pram accTye account type
 */

-(id)initWithAppid:(int) appid andSDKAppid:(int) sdkAppid andAccType:(int)accType;




/*
 增加push命令字回调
 @param cmd sso命令字
 @param cb push回调
*/

-(void)addInitListener:(id<QalInitCallbackProtocol>) cb;

-(void)addPushListener:(NSString*) cmd andQalPushListener:(id<QalPushListenerProtocol>) cb;

/*
 设置连接通知回调
 @param cb 连接通知回调
*/

-(void)setConnectionListener:(id<QalConnListenerProtocol>) cb;


/*
 设置日志回调
 @param cb 日志回调
 */
-(void)setLogListener:(id<QalLogListenerProtocol>) cb;
/*
 设置用户状态通知回调
 @param cb 用户状态通知回调
 */
-(void)setUserStatusListener:(id<QalUserStatusListenerProtocol>) cb;

/*
 发送消息
 @param cmd sso命令字
 @param reqbody 请求包（总包长+业务包体，总包长=业务包体长度+包头长度4字节）
 @param timout 回包超时时间（单位:秒）
 @param cb 收包回调
 */
-(void)sendMsg:(NSString*) cmd andReqbody:(NSData*) reqbody andTimeout:(int) timeout andQalReqCallback:(id<QalReqCallbackProtocol>) cb;
/*
 绑定账户
 @param user 用户名
 @param cb 绑定回调
 */
-(void)bindID:(NSString*) user andQalBindCallback:(id<QalBindCallbackProtocol>) cb;

/*解绑账户
 @param user 用户名
 @param cb 解绑回调
 */
-(void)unbindID:(NSString*) user andQalReqCallback:(id<QalBindCallbackProtocol>) cb;

-(void)regStatus:(id<QalBindCallbackProtocol>) cb;
-(void)unregStatus:(id<QalBindCallbackProtocol>) cb;

- (NSString*)getReqKey:(NSString*)cmd seq:(int)seqId;

- (BOOL)isConnected;

/*
 打印log
 @param level 日志级别
 @param tag 日志tag
 @param msg 日志内容
 */
 
-(void)log:(int)level andTag:(NSString*)tag andMsg:(NSString*)msg;

/*
 打印log
 @param level 日志级别
 @param tag 日志tag
 @param msg 日志内容
 */

-(void)applog:(int)level andTag:(NSString*)tag andMsg:(NSString*)msg;



- (void)setOpenAppid:(NSString *)aOpenAppid;

/*
 设置支持匿名模式
 该模式下会自动将上次登录的用户注册上线
 */
-(void)setSupportGuestMode;

-(void)setOnlyUseConn;

/*
 独立模式第三方登录接口
 @param identifier 第三方app identifier
 @param userSig 第三方app usersig
 @param appid3rd 第三方app appid
 @paran accType 第三方app 账号类型
 */

-(void)login:(NSString*)identifier andUserSig:(NSString*)userSig andAppid3rd:(NSString*)appid3rd andAccType:(uint32_t)accType andCallback:(id<QalBindCallbackProtocol>) cb;


/*
 设置apple push token，每次手动bind成功或onRegSucc回调后需要调用此接口
 @paramn token apple push token
 */
-(void)doSetToken:(NSData*)token andBusiId:(int)busiId andQalReqCallback:(id<QalTokenCallbackProtocol>) cb;

/*
 设置后台状态，退后台时调用
 */
-(void)doBackground:(id<QalTokenCallbackProtocol>) cb;

/*
 设置前台状态，切前台时调用
 */

-(void)doForeground:(id<QalTokenCallbackProtocol>) cb;

/*
 获取当前的id
 */
-(NSString*)getIdentifier;
/*
 设置短连接模式
 */
-(void)setShortConn;

/*
 断开连接
 */
-(void)disconnect;

/*
 清除收包回调
 */

-(void)clearCb:(int)seq;


void QQLogger_for_msf_sdk(int msfLogLevel, const char* actionName, const char* fileName, const char* funcName, int line, const char* logContent);

-(NSString*)getSDKVer;

@end
#endif