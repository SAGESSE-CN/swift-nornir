//
//  TIMManager.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMManager_h
#define ImSDK_TIMManager_h

#import "TIMComm.h"
#import "TIMMessage.h"
#import "TIMConversation.h"
#import "TIMCallback.h"
#import "AVMultiInvitProtocols.h"

/////////////////////////////////////////////////////////
///  Tencent 开放 SDK API
/////////////////////////////////////////////////////////


/////////////////////////////////////////////////////////
///  回调协议
/////////////////////////////////////////////////////////

/**
 *  消息回调
 */
@protocol TIMMessageListener <NSObject>
@optional

/**
 *  新消息通知
 *
 *  @param msgs 新消息列表，TIMMessage 类型数组
 */
- (void)onNewMessage:(NSArray*) msgs;
@end

/**
 *  消息修改回调
 */
@protocol TIMMessageUpdateListener <NSObject>
@optional

/**
 *  消息修改通知
 *
 *  @param msgs 修改的消息列表，TIMMessage 类型数组
 */
- (void)onMessageUpdate:(NSArray*) msgs;
@end

/**
 *  图片上传进度回调
 */
@protocol TIMUploadProgressListener <NSObject>
@optional

/**
 *  消息修改通知
 *
 *  @param msgs 修改的消息列表，TIMMessage 类型数组
 */
- (void) onUploadProgressCallback:(TIMMessage *)msg elemidx:(uint32_t)elemidx taskid:(uint32_t)taskid progress:(uint32_t)progress;
@end


// 音视频邀请消息回调
@protocol TIMAVInvitationListener <NSObject>

@optional

/**
 *  收到音视频邀请消息
 *  @params req 相应的请求
 */
- (void)onReceiveInvitation:(id<AVMultiInvitationReqAble>)req;

@end


/*
@protocol TIMConversationRefreshListener <NSObject>
@optional
- (void) onRefreshConversation;
@end
*/

/**
 *  连接通知回调
 */
@protocol TIMConnListener <NSObject>
@optional

/**
 *  网络连接成功
 */
- (void)onConnSucc;

/**
 *  网络连接失败
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onConnFailed:(int)code err:(NSString*)err;

/**
 *  网络连接断开
 *
 *  @param code 错误码
 *  @param err  错误描述
 */
- (void)onDisconnect:(int)code err:(NSString*)err;


/**
 *  连接中
 */
- (void)onConnecting;

@end


/**
 *  用户在线状态通知
 */
@protocol TIMUserStatusListener <NSObject>
@optional
/**
 *  踢下线通知
 */
- (void)onForceOffline;

/**
 *  断线重连失败
 */
- (void)onReConnFailed:(int)code err:(NSString*)err;
@end

/**
 *  群组成员变更通知
 */
@protocol TIMGroupMemberListener <NSObject>
@optional
/**
 *  群成员数量变更通知回调
 *  @param group   群组Id
 *  @param tipType 提示类型
 *  @param members 变更的成员列表
 */
- (void)onMemberUpdate:(NSString*)group tipType:(TIMGroupTipsType)tipType members:(NSArray*)members;

/**
 *  群成员资料变更通知回调
 *  @param groupId     群组Id
 *  @param memberInfos 成员资料变更列表,TIMGroupTipsElemMemberInfo类型数组
 */
- (void)onMemberInfoUpdate:(NSString*)group  memberInfos:(NSArray*)memberInfos;
@end

/**
 *  页面刷新接口（如有需要未读计数刷新，会话列表刷新等）
 */
@protocol TIMRefreshListener <NSObject>
@optional
- (void) onRefresh;
@end

@interface TIMAPNSConfig : NSObject
/**
 *  是否开启推送：0-不进行设置 1-开启推送 2-关闭推送
 */
@property(nonatomic,assign) uint32_t openPush;



/**
 *  C2C消息声音,不设置传入nil
 */
@property(nonatomic,retain) NSString * c2cSound;

/**
 *  Group消息声音,不设置传入nil
 */
@property(nonatomic,retain) NSString * groupSound;

/**
 *  Video声音,不设置传入nil
 */
@property(nonatomic,retain) NSString * videoSound;

@end

typedef void (^TIMAPNSConfigSucc)(TIMAPNSConfig*);



/**
 *  通讯管理
 */
@interface TIMManager : NSObject


/**
 *  获取管理器实例
 *
 *  @return 管理器实例
 */
+(TIMManager*)sharedInstance;

/*
 * 初始化灯塔SDK,注册监控服务,将会向服务器查询策略,并初始化各个模块的默认数据上传器,设置log级别
 *
 * @param appKey 设置appKey（灯塔事件）
 * @param userId 为用户qua，参数gateWayIP为当前网络网关IP，
 * @param getwayIp 不填则默认使用服务器下发的IP
 * @param level 1 fetal 2 error 3 warn 4 info   in debug version: 5 debug 10 all
 */

+ (void)initAnalytics:(NSString *)appKey userid:(NSString *)userid gatewayIP:(NSString *)getwayIp logLevel:(int)level;

/**
 *  （已经废弃）初始化SDK,第三方托管账号不能使用该接口初始化
 *
 *  @return 0 成功
 */
-(int) initSdk  DEPRECATED_ATTRIBUTE;

/**
 *  初始化SDK
 *
 * @param sdkAppId    用户标识接入SDK的应用ID
 *
 *  @return 0 成功
 */
-(int) initSdk:(int)sdkAppId;

/**
 *  初始化SDK
 *
 *  @param sdkAppId    用户标识接入SDK的应用ID
 * @param accountType 用户的账号类型
 *
 *  @return 0 成功
 */
-(int) initSdk:(int)sdkAppId accountType:(NSString *)accountType;

/**
 *  禁用Crash上报，由用户自己上报，如果需要，必须在initSdk之前调用
 */
-(void) disableCrashReport;

/**
 *  登陆
 *
 *  @param param 登陆参数
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
-(int) login: (TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  登陆托管账号（第三方账号不能使用该接口）
 *
 *  @param identifier   用户表示id
 *  @param accountType  登录账号类型
 *  @param userSig      用户userSig
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
-(int) login:(NSString*)identifier userSig:(NSString*)userSig succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  初始化存储，仅查看历史消息时使用，如果要收发消息等操作，如login成功，不需要调用此函数
 *
 *  @param param 登陆参数（userSig 不用填写）
 *  @param succ  成功回调，收到回调时，可以获取会话列表和消息
 *  @param fail  失败回调
 *
 *  @return 0 请求成功
 */
-(int) initStorage: (TIMLoginParam *)param succ:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  获取当前登陆的用户
 *
 *  @return 如果登陆返回用户的identifier，如果未登录返回nil
 */
-(NSString*) getLoginUser;

/**
 *  登陆
 *
 *  @param param 登陆参数
 *  @param cb    回调
 *
 *  @return 0 登陆请求发送成功，等待回调
 */
-(int) login: (TIMLoginParam *)param cb:(id<TIMCallback>)cb;

/**
 *  登出
 *
 *  @param succ 成功回调，登出成功
 *  @param fail 失败回调，返回错误吗和错误信息
 *
 *  @return 0 发送登出包成功，等待回调
 */
-(int) logout:(TIMLoginSucc)succ fail:(TIMFail)fail;

/**
 *  登出
 *
 *  @deprecated 使用logout:fail 替代.
 *
 *  @return 0 成功
 */
-(int) logout;


/**
 *  获取会话
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *  @param receiver C2C 为对方用户 identifier， GROUP 为群组Id
 *
 *  @return 会话对象
 */
-(TIMConversation*) getConversation: (TIMConversationType)type receiver:(NSString *)receiver;

/**
 *  删除会话
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *  @param receiver    用户identifier 或者 群组Id
 *
 *  @return TRUE:删除成功  FALSE:删除失败
 */
-(BOOL) deleteConversation:(TIMConversationType)type receiver:(NSString*)receiver;

/**
 *  删除会话和消息
 *
 *  @param type 会话类型，TIM_C2C 表示单聊 TIM_GROUP 表示群聊
 *  @param receiver    用户identifier 或者 群组Id
 *
 *  @return TRUE:删除成功  FALSE:删除失败
 */
-(BOOL) deleteConversationAndMessages:(TIMConversationType)type receiver:(NSString*)receiver;

/**
 *  设置消息回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setMessageListener: (id<TIMMessageListener>)listener;

/**
 *  设置消息修改回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setMessageUpdateListener: (id<TIMMessageUpdateListener>)listener;

/**
 *  设置连接通知回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setConnListener: (id<TIMConnListener>)listener;

/**
 *  设置群组成员变更通知回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setGroupMemberListener: (id<TIMGroupMemberListener>)listener;

/**
 *  设置邀请回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
- (void)setAVInviteListener:(id<TIMAVInvitationListener>)listener;

/**
 * 获取网络状态
 */
-(TIMNetworkStatus) networkStatus;

/**
 *  设置用户状态通知回调
 *
 *  @param listener 回调
 *
 *  @return 0 成功
 */
-(int) setUserStatusListener: (id<TIMUserStatusListener>)listener;

/**
 *  获取会话数量
 *
 *  @return 会话数量
 */
-(int) ConversationCount;

/**
 *  通过索引获取会话
 *
 *  @param index 索引
 *
 *  @return 返回对应的会话
 */
-(TIMConversation*) getConversationByIndex:(int)index;

/**
 *  设置Token
 *
 *  @param token token信息
 *
 *  @return 0 成功
 */
-(int) setToken: (TIMTokenParam *)token;

/**
 *  设置APNS配置
 *
 *  @param config APNS配置
 *  @param succ   成功回调
 *  @param fail   失败回调
 *
 *  @return 0 成功
 */
-(int) setAPNS:(TIMAPNSConfig*)config succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取APNS配置
 *
 *  @param succ 成功回调，返回配置信息
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
-(int) getAPNSConfig:(TIMAPNSConfigSucc)succ fail:(TIMFail)fail;

/**
 *  app 切后台时调用
 *
 *  @param param 上报参数
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
-(int) doBackground: (TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  切前台
 *
 *  @return 0 表示成功
 */
-(int) doForeground;


/**
 *  设置环境（在InitSdk之前调用）
 *
 *  @param env  0 正式环境（默认）
 *              1 测试环境
 *              2 beta 环境
 */
-(void)setEnv:(int)env;

/**
 *  获取环境类型
 *
 *  @return env 0 正式环境（默认）
 *              1 测试环境
 *              2 beta 环境
 */
-(int)getEnv;


/**
 *  发送消息
 *
 *  @param type    会话类型（C2C 或 群）
 *  @param receiver 会话标识
 *  @param msg     消息
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 表示成功
 */
// -(int) sendMessage:(TIMConversationType)type receiver:(NSString *)receiver msg:(TIMMessage*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  设置日志函数
 *
 *  @param cb 日志函数，SDK打印日志会通过此函数返给调用方，内部不进行打印
 */
-(void) setLogFunc:(TIMLogFunc)cb;

/**
 *  设置日志监听
 *
 *  @param cb 日志监听，SDK打印日志会通过此接口返给调用方，内部不进行打印
 */
-(void) setLogListener:(id<TIMLogListener>)cb;


/**
 *  获取版本号
 *
 *  @return 返回版本号，字符串表示，例如v1.1.1
 */
-(NSString*) GetVersion;

/**
 *  获取联网SDK的版本号
 *
 *  @return 返回版本号
 */
-(NSString*) GetQALVersion;

/**
 *  打印日志，通过ImSDK提供的日志功能打印日志
 *
 *  @param level 日志级别
 *  @param tag   模块tag
 *  @param msg   要输出的日志内容
 */
-(void) log:(TIMLogLevel)level tag:(NSString*)tag msg:(NSString*)msg;

/**
 * 设置日志级别，在initSDK之前调用
 *
 *  @param level 日志级别
 */
-(void) setLogLevel:(TIMLogLevel)level;

/**
 *  获取日志级别
 *
 *  @return 返回日志级别
 */
-(TIMLogLevel) getLogLevel;

/**
 *  app 切后台时调用
 *
 *  @deprecated 使用 doBackground 替代.
 *
 *  @param param 上报参数
 *  @param succ  成功时回调
 *  @param fail  失败时回调
 *
 *  @return 0 表示成功
 */
-(int) doBackgroud: (TIMBackgroundParam*)param succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  初始化日志设置，必须在initSdk之前调用，在initSdk之后设置无效
 *
 *  @param isEnableLogPrint 是否开启日志打印
 *  @param logPath  日志文件路径
 */
-(void) initLogSettings: (BOOL)isEnableLogPrint logPath:(NSString*) logPath;

/**
 * 获取日志文件路径
 */
-(NSString *) getLogPath;

/**
 * 是否开启sdk日志打印
 */
-(BOOL) getIsLogPrintEnabled;

/**
 * 上传日志文件
 * @param fileName 日志文件名
 * @param tag      日志文件标签
 */
-(void) uploadLogFile:(NSString*) fileName tag:(NSString*)tag;

/**
 * 禁用存储，在不需要消息存储的场景可以禁用存储，提升效率
 */
-(void) disableStorage;

/**
 *  设置会话刷新监听
 *
 *  @param listener 刷新监听（当有未读计数变更、会话变更时调用）
 *
 *  @return 0 设置成功
 */
-(int) setRefreshListener: (id<TIMRefreshListener>)listener;

@end



#endif
