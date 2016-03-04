//
//  MsfDelegate.h
//  QalSDK
//
//  Created by wtlogin on 15/8/7.
//  Copyright (c) 2015年 tencent. All rights reserved.
//
#ifndef MSF_DELEGATE_H
#define MSF_DELEGATE_H
#import <Foundation/Foundation.h>
#import <MsfSDK/MsfSDKCallbackProtocol.h>
#import "QalSDKCallbackProtocol.h"
#import "QQLockDictionary.h"
#ifdef QALSDK_FOR_TLS
#import <TLSSDK/TLSRefreshTicketListener.h>
#endif



#ifdef QALSDK_FOR_TLS
@interface MsfDelegate : NSObject<MsfSDKCallbackProtocol,TLSRefreshTicketListener>
#else
@interface MsfDelegate : NSObject<MsfSDKCallbackProtocol>
#endif

@property (nonatomic,strong) QQLockDictionary*   _pushcbDic;
@property (nonatomic,strong) QQLockDictionary* _reqDic;
@property (nonatomic,strong) id<QalConnListenerProtocol> _Conncb;
@property (nonatomic,strong) id<QalLogListenerProtocol> _Logcb;
@property (nonatomic,strong) id<QalUserStatusListenerProtocol> _UserStatuscb;
@property (nonatomic,strong) id<QalReqCallbackProtocol> _Reqcb;
@property BOOL isReconnect;

- (NSString*)getReqKey:(NSString*)cmd seq:(int)seqId;


@end
#endif