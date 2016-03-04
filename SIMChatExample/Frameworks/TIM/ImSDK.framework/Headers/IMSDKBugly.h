//
//  IMSDKBugly.h
//
//  Created by mqq on 14/12/4.
//  Copyright (c) 2015年 tencent.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark -
#pragma mark - IMSDKBuglyDelegate

@protocol IMSDKBuglyDelegate <NSObject>
@optional
/**
 *    @brief  Bugly 捕获崩溃后的回调
 *
 *    @param exception Bugly 捕获到的崩溃信息
 *    @return 自定义附件文本 (最大长度10kb)
 */
- (nullable NSString *)attachmentWithSdkCaughtException:(nonnull NSException *)exception;

@end

#pragma mark -
#pragma mark - IMSDKBuglyConfig

@interface IMSDKBuglyConfig : NSObject

/**
 *    @brief  delegate
 */
@property (nonatomic, assign, nullable) id<IMSDKBuglyDelegate> delegate;

/**
 *    @brief  是否打印SDK调试信息，默认为NO
 */
@property (nonatomic, assign) BOOL debug;

/**
 *    @brief  应用版本是否包含CFBundleShortVersionString字段，默认为YES，版本包含此字段
 */
@property (nonatomic, assign) BOOL useDefaultVersionField;

/**
 *    @brief  应用版本是否包含CFBundleVersion字段，默认为YES，版本包含此字段
 */
@property (nonatomic, assign) BOOL useDefaultBuildField;

/**
 *    @brief  设置应用版本信息，默认版本为CFBundleShortVersionString(CFBundleVersion)
 */
@property (nonatomic, copy, nullable)  NSString * version ;

/**
 *    @brief  设置渠道名， 默认Unknown
 */
@property (nonatomic, copy, nullable) NSString *channel;

/**
 *    @brief  设置默认用户标识，默认Unknown
 */
@property (nonatomic, copy, nullable) NSString *userIdentifier;

/**
 *    @brief  设置设备的唯一标识， 默认采用SDK定义的设备唯一标识
 */
@property (nonatomic, copy, nullable) NSString *deviceIdentifier;
/**
 *    @brief  设置应用的标识，默认读取.plist对应字段
 */
@property (nonatomic, copy, nullable) NSString *bundleIdentifier;

/**
 *    @brief  是否开启卡顿监控上报，默认NO，开启卡顿场景监控上报
 */
@property (nonatomic, assign) BOOL enableBlockMonitor;

/**
 *    @brief  设置卡顿监控的RunLoop超时判断阀值，默认值 3 sec.
 */
@property (nonatomic, assign) NSUInteger blockMonitorJudgementLoopTimeout;

/**
 *    @brief  设置是否启用进程内符号化，默认为YES，开启进程内符号化，请修改Xcode配置Strip Style为Debugging Symbols
 */
@property (nonatomic, assign) BOOL enableSymbolicateInProcess;

/**
 *    @brief  设置是否启用 App Transport Security,默认为YES
 */
@property (nonatomic, assign) BOOL enableATS;
/**
 *    @brief  默认配置实例
 *
 *    @return
 */
+ (nonnull instancetype)defaultConfig;

@end

#pragma mark -

// Log level for Bugly Logger
typedef NS_ENUM(NSUInteger, IMBLYLogLevel) {
    IMBLYLogLevelSilent  = 0,
    IMBLYLogLevelError   = 1 << 0, // 00001
    IMBLYLogLevelWarn    = 1 << 1, // 00010
    IMBLYLogLevelInfo    = 1 << 2, // 00100
    IMBLYLogLevelDebug   = 1 << 3, // 01000
    IMBLYLogLevelVerbose = 1 << 4, // 10000
};

#pragma mark - IMSDKBugly

@interface IMSDKBugly : NSObject


/**
 *    @brief  初始化日志模块
 *
 *    @param level 设置默认日志级别，默认BLYLogLevelInfo
 *
 *    @param printConsole 是否打印到控制台，默认NO
 */
+ (void)initLogger:(IMBLYLogLevel) level consolePrint:(BOOL) printConsole;

/**
 *    @brief  获取默认的日志级别
 *
 *    @return BLYLogLevel
 */
+ (IMBLYLogLevel)logLevel;

/**
 *    @brief 打印BLYLogLevelInfo日志
 *
 *    @param format 日志内容
 */
+ (void)log:(nonnull NSString *)format, ...;

/**
 *    @brief  打印日志
 *
 *    @param level 日志级别
 *    @param fmt   日志内容
 */
+ (void)level:(IMBLYLogLevel) level logs:(nonnull NSString *)message;

/**
 *    @brief  打印日志
 *
 *    @param level 日志级别
 *    @param fmt   日志内容
 */
+ (void)level:(IMBLYLogLevel) level log:(nonnull NSString *)format, ...;

/**
 *    @brief  打印日志
 *
 *    @param level  日志级别
 *    @param tag    日志模块分类
 *    @param format 日志内容
 */
+ (void)level:(IMBLYLogLevel)level tag:(nonnull NSString *) tag log:(nonnull NSString *)format, ...;

/**
 *    @brief  初始化IMSDKBugly崩溃上报，在application:didFinishLaunchingWithOptions:方法中调用
 *
 *    @param appId 应用的唯一标识，在Bugly网站注册应用后获取
 */
+ (void)startWithAppId:(nonnull NSString *)appId;

/**
 *    @brief 初始化IMSDKBugly，并设置默认配置，默认配置内容可以查看IMSDKBuglyConfig了解
 *
 *    @param appId 应用的唯一标识，在Bugly网站注册应用后获取
 *    @param defaultConfig 默认配置
 */
+ (void)startWithAppId:(nonnull NSString *)appId
                config:(nullable IMSDKBuglyConfig *)config;

/**
 *    @brief 初始化IMSDKBugly，并设置AppGroups标识(如果需要支持App Extension异常上报，请调用此接口初始化)
 *
 *    @param appId 应用的唯一标识，在Bugly网站注册应用后获取
 *    @param defaultConfig 默认配置
 *    @param appGroupIdentifier AppGroups 标识
 */
+ (void)startWithAppId:(nonnull NSString *)appId
                config:(nullable IMSDKBuglyConfig *)config
applicationGroupIdentifier:(nonnull NSString *)appGroupIdentifier;

/**
 *    @brief  设置用户唯一标识，在初始化方法之后调用
 *
 *    @param userId 用户唯一标识
 */
+ (void)setUserIdentifier:(nonnull NSString *)userId;

/**
 *    @brief  设置场景标签, 如支付、后台等
 *
 *    @param tagid 自定义的场景标签Id, 需先在Bugly平台页面进行配置
 */

+ (void)setTagId:(NSUInteger)tagid;

/**
 *    @brief 设置自定义数据，最多保存20条记录
 *
 *    @param value
 *    @param key
 */
+ (void)setSceneValue:(nonnull NSString *)value
               forKey:(nonnull NSString *)key;

/**
 *    @brief 获取指定key自定义数据
 *
 *    @param key
 */
+ (nullable NSString *)secenValueForKey:(nonnull NSString *)key;

/**
 *    @brief 获取所有自定义数据
 */
// + (nullable NSDictionary<NSString *, NSString *> *)allSceneValues;

/**
 *    @brief 删除指定key自定义数据
 *
 *    @param key
 */
+ (void)removeSceneValueForKey:(nonnull NSString *)key;

/**
 *    @brief 删除所有自定义数据
 */
+ (void)removeAllSceneValues;

/**
 *    @brief  上报NSException
 *
 *    @param exception  自定义异常
 *    @param reason 异常原因
 *    @param dict   附带数据
 */
+ (void)reportException:(nonnull NSException *)exception
                 reason:(nullable NSString *)reason
               extraInfo:(nullable NSDictionary *)dict;

/**
 *    @brief  上报NSError
 *
 *    @param error  自定义Error
 *    @param reason 错误原因
 *    @param dict   附带数据
 */
+ (void)reportError:(nonnull NSError *)error
             reason:(nullable NSString *)reason
           extraInfo:(nullable NSDictionary *)dict;

/**
 *    @brief 上报自定义异常信息
 *
 *    @param category   自定义异常类型, C# ＝ 4、JS ＝ 5、Lua ＝ 6
 *    @param name   异常名称
 *    @param reason 异常原因
 *    @param stack  异常堆栈
 *    @param dict   附加数据
 *    @param terminate  是否中止应用
 */
/*
+ (void)reportExceptionCategory:(NSUInteger)category
                           name:(nonnull NSString *)name
                         reason:(nullable NSString *)reason
                     stackTrace:(nullable NSString *)stack
                       extraInfo:(nullable NSDictionary<NSString *,NSString *> *)dict
                   terminateApp:(BOOL)terminate;
*/
/**
 *    @brief  处理WatchKit的回调
 *
 *    @param userInfo   传递参数
 *    @param replyToExtension   应答Block
 */
/*
+ (void)handleWatchKitExtensionRequest:(nullable NSDictionary *)userInfo
                                 reply:(void (^ _Nonnull)(NSDictionary * _Nullable))replyToExtension;
*/
+ (void)setSdkConfig:(nonnull NSString *) value forKey:(nonnull NSString *) key;
@end
