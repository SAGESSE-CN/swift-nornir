//
//  TLSErrInfo.h
//  WTLoginSDK64ForIOS
//
//  Created by givonchen on 15-5-25.
//
//
#ifndef TLSSDK_TLSErrorInfo_h
#define TLSSDK_TLSErrorInfo_h
#import <Foundation/Foundation.h>

/// 错误码定义
enum _TLS_RETURN_VALUES{
    /// 帐号类接口svr返回码 >0
    TLS_ACCOUNT_SUCCESS = 0,            ///成功
    TLS_ACCOUNT_NOT_EXIST = 1,          ///帐号未注册
    TLS_ACCOUNT_REGISTERED = 2,         ///重复注册
    TLS_ACCOUNT_FREQ_LIMIT = 3,         ///操作太频繁
    TLS_ACCOUNT_INVALID_MOBILE = 4,     ///手机号无效
    TLS_ACCOUNT_JUST_FAILED = 5,        ///当前失败,请稍后重试
    TLS_ACCOUNT_RESET_TOOMANY = 6,      ///达到最大重置密码次数
    TLS_ACCOUNT_INVALID_TOKEN = 7,      ///解析注册加密信息失败
    TLS_ACCOUNT_SMSCODE_NOTALLOW = 8,   ///安平不允许下发短信
    TLS_ACCOUNT_SESSION_NOTFOUND = 9,   ///找不到session
    TLS_ACCOUNT_REGISTER_TOOMANY = 10,  ///达到最大注册次数
    TLS_ACCOUNT_INVALID_APPID = 11,     ///appid  和 acctype 非法
    TLS_ACCOUNT_WRONG_OPERATION = 12,   ///错误的操作
    TLS_ACCOUNT_INVALID_OPERATION = 13, ///无效的操作
    TLS_ACCOUNT_SMSCODE_INVALID = 14,   ///短信验证码无效
    TLS_ACCOUNT_SMSCODE_EXPIRED = 15,   ///短信验证码过期
    TLS_ACCOUNT_OPERATE_TOOMANY = 16,   ///请重新提交手机号（有效期内操作次数达到上限）
    TLS_ACCOUNT_VERIFY_TOOMANY = 17,    ///请重新提交手机号（有效期内验证短信次数达到上限）
    
    /// 登录类接口svr返回码 >0
    TLS_LOGIN_SUCCESS = 0,              ///成功
    TLS_LOGIN_WRONG_PWD = 1,            ///密码错误
    TLS_LOGIN_NEED_IMGPIC = 2,          ///需要输入图片验证码
    TLS_LOGIN_WRONG_SMSCODE = 0xd8,     ///短信验证码错误
    TLS_LOGIN_NO_ACCOUNT = 0xe5,        ///帐号不存在
    
    /// 帐号类接口sdk本地返回码 <-2000起
    TLS_ACCOUNT_NETWORK_ERROR = -2000,   ///网络错误
    TLS_ACCOUNT_STATE_ERROR = -2001,     ///状态错误： 可能是上一个调用流程没有结束，需要等待返回
    TLS_ACCOUNT_ERROR_LOCAL = -2002,     ///SDK错误
    TLS_ACCOUNT_PARA_ERROR = -2003,      ///参数错误
    
    /// 登录类接口sdk本地返回码 <-2200起
    TLS_LOGIN_NETWORK_ERROR = -2200,    ///网络错误
    TLS_LOGIN_STATE_ERROR = -2201,      ///状态错误： 可能是上一个调用流程没有结束，需要等待返回
    TLS_LOGIN_REJECTED_TIP = -2202,     ///登录错误，展示错误提示
    TLS_LOGIN_ERROR_LOCAL = -2203,      ///登录错误，SDK错误   ＃＃上报返回码，业务无需关心
    TLS_LOGIN_RESET_USER = -2204,       ///前端reset登录流程    ＃＃上报返回码，业务无需关心
    TLS_LOGIN_PWD_SIG_ERROR = -2205,    ///记住密码签名错误，需要用户输入密码登录
} ;

/// 出错信息
@interface TLSErrInfo : NSObject
{
    int32_t    dwErrorCode;          ///错误码
    NSString*   sErrorTitle;        ///标题
    NSString*   sErrorMsg;          ///提示语
    NSString*   sExtraMsg;          ///附加信息
}

/// 错误码
@property (assign)  int32_t    dwErrorCode;
/// 标题
@property (copy)    NSString*   sErrorTitle;
/// 提示语
@property (copy)    NSString*   sErrorMsg;
/// 附加信息
@property (copy)    NSString*   sExtraMsg;

@end
#endif
