//
//  TLSHelper.h
//  TLSSDK
//
//  Created by okhowang on 15/11/6.
//
//
#ifndef TLSSDK_TLSHelper_h
#define TLSSDK_TLSHelper_h
#import <Foundation/Foundation.h>
#include <AvailabilityMacros.h>
#import "TLSUserInfo.h"
#import "TLSSmsLoginListener.h"
#import "TLSSmsRegListener.h"
#import "TLSPwdLoginListener.h"
#import "TLSPwdRegListener.h"
#import "TLSPwdResetListener.h"
#import "TLSStrAccountRegListener.h"
#import "TLSRefreshTicketListener.h"
#import "TLSOpenLoginListener.h"
#import "TLSOpenBindListener.h"
#import "TLSOpenQueryListener.h"
#import "TLSExchangeTicketListener.h"
#import "TLSGuestLoginListener.h"
#import "TLSOpenAccessTokenListener.h"

@interface TLSHelper : NSObject
/**
 * 语言类型
 * 目前有以下类型供选择：
 * 2052：简体中文;1028：繁体中文;1033：英文; 1041: 日语; 1036: 法语
 */
@property uint32_t country;
/**
 *  国家区号
 *  例如：中国86
 */
@property uint32_t language;
/**
 *  @brief 获取TLSHelper 实例
 *
 *  @return 返回TLSHelper 实例
 */
+(TLSHelper *) getInstance;

/**
 *  @brief 初始化TLSLoginHelper 实例
 *
 *  @param sdkAppid - 用于TLS SDK的appid
 *  @param accountType - 账号类型
 *  @param appVer - app 版本号，格式为 x.x.x.x， 例如，客户端版本为1.1，传入参数为 @"1.1.0.0"
 *
 *  @return 返回TLSLoginHelper 实例
 */
-(TLSHelper *) init:(int)sdkAppid
          andAccountType:(int)accountType
               andAppVer:(NSString *)appVer DEPRECATED_ATTRIBUTE;
/**
 *  @brief 初始化TLSLoginHelper 实例
 *
 *  @param sdkAppid - 用于TLS SDK的appid
 *  @param appVer - app 版本号，格式为 x.x.x.x， 例如，客户端版本为1.1，传入参数为 @"1.1.0.0"
 *
 *  @return 返回TLSLoginHelper 实例
 */
-(TLSHelper*)init:(int)sdkAppid andAppVer:(NSString *)appVer;

/**
 *  设置请求超时时间，默认为10000毫秒。
 *  sdk与后台交互时，如果超时，会重试5次，所以不应设置太大的值
 *
 *  @param timeout - 超时时间（单位毫秒）
 */
-(void) setTimeOut:(int)timeout;

/**
 *  打印调试日志
 *
 *  @param show - 是否输出日志到logcat
 */
-(void) setLogcat:(BOOL)show;

/**
 * 获取TLS SDK的版本信息
 *
 *  @return SDK的版本信息
 */
-(NSString *) getSDKVersion;

/**
 * 获取guid
 *
 *  @return guid
 */
-(NSData *) getGUID;

/**
 *  获取登录过当前app的帐号列表
 *
 *  @return 账号列表信息 TLSUserInfo数组
 */
-(NSArray<TLSUserInfo *> *) getAllUserInfo;

/**
 *  获取最后一次登录记录
 *
 *  @return 账号信息
 */
-(TLSUserInfo *) getLastUserInfo;

/**
 *  清除用户登录数据
 *
 *  @param identifier - 用户手机号码
 *  @param deleteAccount - 是否将identifier从历史登录账号列表中删除 NO表示不删除 YES表示删除
 *
 *  @return ture
 */
-(BOOL) clearUserInfo:(NSString *)identifier withOption:(BOOL)deleteAccount;

/**
 *  判断是否需要用户登录（输入密码或者短信验证）
 *
 *  @param identifier - 用户帐号
 *
 *  @return true：需要用户登录；false：本地已有登录态，无需登录，可直接换票
 */
-(BOOL) needLogin:(NSString *)identifier;


/**
 *  获取本地保存TLS票据
 *
 *  @param identifier - 用户手机号码
 *
 *  @return json webtoken
 */
-(NSString*) getTLSUserSig:(NSString *)identifier;

/**
 *  换票，刷新票据
 *
 *  @param identifier - 用户账号
 *  @param listener - TLSRefreshTicketListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSRefreshTicket:(NSString *)identifier andTLSRefreshTicketListener:(id<TLSRefreshTicketListener>) listener;

#pragma mark - 密码登录

/**
 *  密码登录，获取票据
 *
 *  @param identifier - 用户账号
 *  @param password - 用户密码
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLogin:(NSString *)identifier andPassword:(NSString *)password andTLSPwdLoginListener:(id<TLSPwdLoginListener>)listener;

/**
 *  刷新图片验证码
 *
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLoginReaskImgCode:(id<TLSPwdLoginListener>)listener;

/**
 *  验证图片验证码，如果验证成功则登录成功，否则要重新验证
 *
 *  @param imgCode - 用户账号
 *  @param listener - TLSPwdLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdLoginVerifyImgCode:(NSString *)imgCode andTLSPwdLoginListener:(id<TLSPwdLoginListener>)listener;

#pragma mark - 短信登录

/**
 *  短信登录，手机号验证
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsAskCode:(NSString *)mobile andTLSSmsLoginListener:(id<TLSSmsLoginListener>)listener;

/**
 *  短信登录，刷新短信验证码
 *  注意：一定是TLSSmsAskCode调用成功了，但是没有收到验证码，才可以调用此接口，否则可能会报错
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsReaskCode:(NSString *)mobile andTLSSmsLoginListener:(id<TLSSmsLoginListener>)listener;

/**
 *  短信登录，验证短信验证码
 *
 *  @param mobile - 用户手机号码
 *  @param  code - 验证码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsVerifyCode:(NSString *)mobile andCode:(NSString *)code andTLSSmsLoginListener:(id<TLSSmsLoginListener>)listener;

/**
 *  短信登录，获取票据
 *
 *  @param mobile - 用户手机号码
 *  @param listener - TLSSmsLoginListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsLogin:(NSString *)mobile andTLSSmsLoginListener:(id<TLSSmsLoginListener>)listener;

#pragma mark - 匿名登录 游客模式
/**
 *  登录匿名账号，无需注册直接登录，在不清数据的情况下会登录上次登录的匿名账号
 *  @param listener    处理回调 需要实现TLSGuestLoginListener协议
 *  @return 0表示成功；其他表示调用失败
 */
-(int)TLSGuestLogin:(id<TLSGuestLoginListener>)listener;
/**
 *  获取本地匿名账号
 *  @return 匿名账号的userinfo，若没有则返回nil
 */
-(TLSUserInfo*)getGuestIdentifier;

#pragma mark - 手机号密码注册
/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegAskCode:(NSString *)mobile andTLSPwdRegListener:(id<TLSPwdRegListener>)listener;

/**
 *  用第三方帐号绑定注册新手机号
 *  提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param accType - 第三方帐号类型 1:QQ 2:微信
 *  @param openAppid - 第三方帐号appid
 *  @param openid - 第三方账号OpenID
 *  @param accessToken - 第三方帐号的access token
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegAskCode:(NSString *)mobile andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSPwdRegListener:(id<TLSPwdRegListener>)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 * 注意：一定是TLSPwdRegAskCode调用成功了，但是没有收到验证码，才可以调用此接口，否则可能会报错
 *
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegReaskCode:(id<TLSPwdRegListener>)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegVerifyCode:(NSString *)code andTLSPwdRegListener:(id<TLSPwdRegListener>)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegCommit:(NSString *)password andTLSPwdRegListener:(id<TLSPwdRegListener>)listener;
#pragma mark - 手机号重置密码
/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetAskCode:(NSString *)mobile andTLSPwdResetListener:(id<TLSPwdResetListener>)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetReaskCode:(id<TLSPwdResetListener>)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetVerifyCode:(NSString *)code andTLSPwdResetListener:(id<TLSPwdResetListener>)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetCommit:(NSString *)password andTLSPwdResetListener:(id<TLSPwdResetListener>)listener;
#pragma mark - 手机号短信注册
/**********************************************
 *              短信注册接口
 *********************************************/

/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegAskCode:(NSString *)mobile andTLSSmsRegListener:(id<TLSSmsRegListener>)listener;
/**
 * 带第三方帐号绑定注册手机号
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param accType - 第三方帐号类型 1:QQ 2:微信
 *  @param openAppid - 第三方帐号appid
 *  @param openid - 第三方账号OpenID
 *  @param accessToken - 第三方帐号的access token
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegAskCode:(NSString *)mobile andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSSmsRegListener:(id<TLSSmsRegListener>)listener;
/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegReaskCode:(id<TLSSmsRegListener>)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegVerifyCode:(NSString *)code andTLSSmsRegListener:(id<TLSSmsRegListener>)listener;

/**
 * 注册成功获取账号
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegCommit:(id<TLSSmsRegListener>)listener;
#pragma mark - 字符串帐号注册
/***********************************************
 *              字符串账号注册接口
 **********************************************/

/**
 *  字符串账号+密码注册接口
 *  @param account - 用户输入的账号名，最长不得超过24字节
 *  @param password - 用户输入的密码，密码最短8字节，最长16字节
 *  @param listener - 回调接口 需要实现TLSStrAccountRegProtocol协议
 *  @return 0表示调用成功；其他表示调用失败，返回码见：_TLS_RETURN_VALUES
 */
-(int) TLSStrAccountReg:(NSString *)account andPassword:(NSString *)password andTLSStrAccountRegListener:(id<TLSStrAccountRegListener>)listener;
/**
 *  带第三方帐号绑定注册
 *  字符串账号+密码注册接口
 *  @param account - 用户输入的账号名，最长不得超过24字节
 *  @param password - 用户输入的密码，密码最短8字节，最长16字节
 *  @param accType - 第三方帐号类型 1:QQ 2:微信
 *  @param openAppid - 第三方帐号appid
 *  @param openid - 第三方账号OpenID
 *  @param accessToken - 第三方帐号的access token
 *  @param listener - 回调接口 需要实现TLSStrAccountRegProtocol协议
 *  @return 0表示调用成功；其他表示调用失败，返回码见：_TLS_RETURN_VALUES
 */
-(int) TLSStrAccountReg:(NSString *)account andPassword:(NSString *)password andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSStrAccountRegListener:(id<TLSStrAccountRegListener>)listener;
#pragma mark - 第三方帐号绑定
/**
 * 绑定第三方账号和自有账号
 * @param account - 自有帐号，必须已登录
 * @param accType - 第三方帐号类型 1:QQ 2:微信
 * @param openAppid - 第三方帐号appid
 * @param openid - 第三方账号OpenID
 * @param accessToken - 第三方帐号的access token
 * @return 0表示调用成功
 */
-(int) TLSOpenBind:(NSString*)account andUserSig:(NSString*)userSig andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andListener:(id<TLSOpenBindListener>)listener;
/**
 * 查询第三方账号的绑定状态
 * @param accType - 第三方帐号类型 1:QQ 2:微信
 * @param openAppid - 第三方帐号appid
 * @param openid - 第三方账号OpenID
 * @param accessToken - 第三方帐号的access token
 * @return 0表示调用成功
 */
-(int) TLSOpenQuery:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andListener:(id<TLSOpenQueryListener>)listener;
/**
 *  用code换取access token
 *  目前只支持微信，需要在管理系统中配置微信的app secret
 *
 *  @param accountType 第三方帐号类型 2:微信
 *  @param code        从微信获取的临时code
 *  @param listener    回调
 *
 *  @return 0表示调用成功
 */
-(int) TLSOpenAccessToken:(uint32_t)accountType andCode:(NSString*)code andListener:(id<TLSOpenAccessTokenListener>)listener;

#pragma mark - 第三方帐号登录
/**
 *  使用openid+accesstoken登录
 *
 *  @param accountType 账号对应的accountType QQ:1 微信:2
 *  @param openid openid
 *  @param appid  第三方帐号的appid
 *  @param accessToken accessToken
 *  @param listener   处理回调 需要实现TLSExchangeTicketListener协议
 *  @return 0表示成功；其他表示调用失败
 */
-(int)TLSOpenLogin:(uint32_t)accountType andOpenId:(NSString *)openid andAppid:(NSString *)appid andAccessToken:(NSString *)accessToken andTLSOpenLoginListener:(id<TLSOpenLoginListener>)listener;

#pragma mark - 独立模式
/**
 *  独立模式下换票 usersig换取A2、D2等票据
 *
 *  @param sdkappid   业务在TLS申请账号集成时得到的appid
 *  @param accountType 账号对应的accountType
 *  @param identifier 帐号名
 *  @param appidAt3rd      第三方帐号的appid，可选参数，没有请传入nil
 *  @param userSig    业务后台生成的TLS用户票据
 *  @param listener   处理回调 需要实现TLSExchangeTicketListener协议
 *  在本接口的成功回调时通过getSSOTicket接口获取A2、D2等票据
 *  @return 0表示成功；其他表示调用失败
 */
-(int)TLSExchangeTicket:(uint32_t)sdkappid andAccountType:(uint32_t)accountType andIdentifier:(NSString *)identifier andAppidAt3rd:(NSString *)appidAt3rd andUserSig:(NSString *)userSig andTLSExchangeTicketListener:(id<TLSExchangeTicketListener>)listener DEPRECATED_ATTRIBUTE;
/**
 *  独立模式下换票 usersig换取A2、D2等票据
 *  在本接口的成功回调时通过getSSOTicket接口获取A2、D2等票据
 *
 *  @param identifier 帐号名
 *  @param userSig    业务后台生成的TLS用户票据
 *  @param listener   处理回调
 *
 *  @return 0表示成功；其他表示调用失败
 */
-(int)TLSExchangeTicket:(NSString *)identifier andUserSig:(NSString *)userSig andTLSExchangeTicketListener:(id<TLSExchangeTicketListener>)listener;
/**
 *  获取本地保存的SSO票据
 *
 *  @param identifier - 用户手机号码
 *
 *  @return {"A2": xxx, "A2Key": xxx, "D2": xxx, "D2Key": xxx, "tinyID":xxx}
 *  除了tinyID是NSString外，其他的都是NSData类型
 */
-(NSDictionary*) getSSOTicket:(NSString *)identifier;
/**
 *
 *  @param identifier 帐号
 *  @return 上次换票时间
 */
-(int64_t)getLastRefreshTime:(NSString*)identifier;

#pragma mark - 内部接口
-(void)setTest:(BOOL)test;
-(void)setTestHost:(NSString*)host;
@end
#endif
