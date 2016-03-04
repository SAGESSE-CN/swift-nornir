//
//  TIMAVMeasureSpeeder.h
//
//  Created by AlexiChen on 15/7/29.
//  Copyright (c) 2015年 bodeng. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <UIKit/UIKit.h>
#endif

@class TIMAVMeasureSpeeder;

@protocol TIMAVMeasureSpeederDelegate <NSObject>


@optional

// 请求测速失败
- (void)onAVMeasureSpeedRequestFailed:(TIMAVMeasureSpeeder *)avts;

// 请求测速成功
- (void)onAVMeasureSpeedRequestSucc:(TIMAVMeasureSpeeder *)avts;

// UDP未成功创建
- (void)onAVMeasureSpeedPingFailed:(TIMAVMeasureSpeeder *)avts;

// 开始拼包
- (void)onAVMeasureSpeedStarted:(TIMAVMeasureSpeeder *)avts;

// 发包结束
// isByUser YES, 用户手动取消 NO : 收完所有包或内部超时自动返回
- (void)onAVMeasureSpeedPingCompleted:(TIMAVMeasureSpeeder *)avts byUser:(BOOL)isByUser;

// 提交测速结果
// succ : YES 提交成功  NO 失败
- (void)onAVMeasureCommited:(TIMAVMeasureSpeeder *)avts success:(BOOL)succ;

@end



@interface TIMAVMeasureSpeeder : NSObject

@property (nonatomic, weak) id<TIMAVMeasureSpeederDelegate> delegate;

// 超时时间
// 默认是60s，该时间内没完成，自动回调onAVSpeedTestThreadCompleted:NO
@property (nonatomic, assign) NSUInteger timeout;

// 请求测速
- (void)requestMeasureSpeedWith:(short)bussType authType:(short)authType;

// 取消本次测速，并且自动提交
- (void)cancelMeasureSpeed;

@end
