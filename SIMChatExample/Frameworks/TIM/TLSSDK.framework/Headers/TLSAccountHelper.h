//
//  TLSAccountHelper.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-18.
//
//
#ifndef TLSSDK_TLSAccountHelper_h
#define TLSSDK_TLSAccountHelper_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSPwdRegListener.h"
#import "TLSPwdResetListener.h"
#import "TLSSmsRegListener.h"
#import "TLSStrAccountRegListener.h"
#import "TLSOpenBindListener.h"
#import "TLSOpenQueryListener.h"

/// 国家类别
enum _TLS_COUNTRY_DEFINE
{
    TLS_COUNTRY_CHINA = 86,           ///中国
    TLS_COUNTRY_TAIWAN = 186,         ///台湾
    TLS_COUNTRY_HONGKANG = 152,       ///香港
    TLS_COUNTRY_USA = 174,            ///美国
};

/// 语言类别
enum _TLS_LANG_DEFINE
{
    TLS_LANG_ENGLISH = 1033,          ///英语
    TLS_LANG_SIMPLIFIED = 2052,       ///简体中文，目前只支持简体中文
    TLS_LANG_TRADITIONAL = 1028,      ///繁体中文
    TLS_LANG_JAPANESE = 1041,         ///日语
    TLS_LANG_FRANCE = 1036,           ///法语
};

/// 帐号类 (包括 手机帐号+密码注册、手机帐号重置密码、手机帐号无密码注册 等接口)
DEPRECATED_ATTRIBUTE
@interface TLSAccountHelper : NSObject 

/**
 *  @brief 获取TLSAccountHelper 实例
 *
 *  @return 返回TLSAccountHelper 实例
 */
+(TLSAccountHelper *) getInstance;

/**
 *  @brief 初始化TLSAccountHelper 实例
 *
 *  @param sdkAppid - 用于TLS SDK的appid
 *  @param accountType - 账号类型
 *  @param appVer - app 版本号，业务自定义
 *
 *  @return 返回TLSAccountHelper 实例
 */
-(TLSAccountHelper *) init:(int)sdkAppid
            andAccountType:(int)accountType
                 andAppVer:(NSString *)appVer;

/**
 *  @brief 设置请求超时时间，默认为10000毫秒。
 *  sdk与后台交互时，如果超时，会重试5次，所以不应设置太大的值
 *
 *  @param timeout - 超时时间（单位毫秒）
 */
-(void) setTimeOut:(int)timeout;

/**
 * @brief 设置语言类型（支持国际化）
 * 目前有以下类型供选择：
 * 2052：简体中文;1028：繁体中文;1033：英文; 1041: 日语; 1036: 法语
 *
 *  @param localid - 语言类型
 */
-(void) setLocalId:(int)localid;

/**
 * 设置国家区号（支持国际化）
 *
 *  @param country - 国家区号
 */
-(void) setCountry:(int)country;

/**
 * 获取TLS SDK的版本信息
 *
 *  @return SDK的版本信息
 */
-(NSString *) getSDKVersion;
#pragma mark - 手机号密码注册
/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegAskCode:(NSString *)mobile andTLSPwdRegListener:(id)listener;

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
-(int) TLSPwdRegAskCode:(NSString *)mobile andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSPwdRegListener:(id)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 * 注意：一定是TLSPwdRegAskCode调用成功了，但是没有收到验证码，才可以调用此接口，否则可能会报错
 *
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegVerifyCode:(NSString *)code andTLSPwdRegListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdRegCommit:(NSString *)password andTLSPwdRegListener:(id)listener;
#pragma mark - 手机号重置密码
/**
 * 提交用于验证的手机号码
 *
 *  @param mobile - 手机号码 (国家码-手机号码)
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetAskCode:(NSString *)mobile andTLSPwdResetListener:(id)listener;

/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetVerifyCode:(NSString *)code andTLSPwdResetListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param password - 用户密码
 *  @param listener - TLSPwdResetListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSPwdResetCommit:(NSString *)password andTLSPwdResetListener:(id)listener;
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
-(int) TLSSmsRegAskCode:(NSString *)mobile andTLSSmsRegListener:(id)listener;
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
-(int) TLSSmsRegAskCode:(NSString *)mobile andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSSmsRegListener:(id)listener;
/**
 * 当使用下行短信验证手机号码时，用于请求重新发送下行短信
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegReaskCode:(id)listener;

/**
 * 用于提交收到的短信验证码
 *
 *  @param code - 短信验证码
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegVerifyCode:(NSString *)code andTLSSmsRegListener:(id)listener;

/**
 * 注册成功获取账号
 *
 *  @param listener - TLSSmsRegListener 回调对象
 *
 *  @return 0表示调用成功；其它表示调用失败
 */
-(int) TLSSmsRegCommit:(id)listener;
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
-(int) TLSStrAccountReg:(NSString *)account andPassword:(NSString *)password andTLSStrAccountRegListener:(id)listener;
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
-(int) TLSStrAccountReg:(NSString *)account andPassword:(NSString *)password andAccType:(uint32_t)accType andOpenAppid:(NSString*)openAppid andOpenId:(NSString*)openid andAccessToken:(NSString*)accessToken andTLSStrAccountRegListener:(id)listener;
@end
#endif
