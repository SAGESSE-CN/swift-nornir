//
//  AVMultiInvitProtocols.h
//  ImSDKTest
//
//  Created by AlexiChen on 15/8/12.
//  Copyright (c) 2015年 bodeng. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(int, AVRequestType)
{
    EAVRequestType_SendStartInvitation = 1,     // 发起方发起邀请
    EAVRequestType_SendCancelInvitation,    // 发起方取消邀请
    EAVRequestType_RecvAgreeInvitation,     // 接收方接受邀请
    EAVRequestType_RecvRejectInvitation,    // 接收方拒绝邀请
};

// 业务中涉及的用户类型数据
@protocol AVInviteUserAbleItem <NSObject>

@property (nonatomic, copy) NSString *userAppId;        // app在开放平台ID
@property (nonatomic, copy) NSString *userOpenId;       // 用户在app上的帐号
@property (nonatomic, copy) NSString *userAcounttype;   // 用户类型

@end

// 多人邀请接口
@protocol AVMultiInvitationReqAble <NSObject>

@property (nonatomic, assign) int bussType;                     // 业务类型
@property (nonatomic, assign) int authType;                     // 鉴权类型
@property (nonatomic, assign) unsigned int authId;              // 鉴权ID
@property (nonatomic, assign) AVRequestType requestType;        // 请求类型
@property (nonatomic, assign) unsigned int sdkAppId;            // sdkAppId
@property (nonatomic, assign) long long roomId;              // 房间号
@property (nonatomic, strong) id<AVInviteUserAbleItem> sender;  // 发起者
@property (nonatomic, strong) NSMutableArray *receivers;        // 接收者 AVInviteUserAbleItem 数组
@property (nonatomic, strong) NSMutableData *reverseData;       // 用户自定义数据段

@end



@interface AVMultiInviteUser : NSObject <AVInviteUserAbleItem>

@property (nonatomic, copy) NSString *userAppId;        // app在开放平台ID
@property (nonatomic, copy) NSString *userOpenId;       // 用户在app上的帐号
@property (nonatomic, copy) NSString *userAcounttype;   // 用户类型

@end

@interface AVMultiInvitationReq : NSObject <AVMultiInvitationReqAble>

@property (nonatomic, assign) int bussType;                     // 业务类型
@property (nonatomic, assign) int authType;                     // 鉴权类型
@property (nonatomic, assign) unsigned int authId;              // 鉴权ID
@property (nonatomic, assign) AVRequestType requestType;        // 请求类型
@property (nonatomic, assign) unsigned int sdkAppId;            // sdkAppId
@property (nonatomic, assign) long long roomId;                 // 房间号
@property (nonatomic, strong) id<AVInviteUserAbleItem> sender;  // 发起者
@property (nonatomic, strong) NSMutableArray *receivers;        // 接收者 AVInviteUserAbleItem 数组
@property (nonatomic, strong) NSMutableData *reverseData;       // 用户自定义数据段


@end


@interface AVMultiInvitationReqProc : NSObject

@end