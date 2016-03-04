//
//  TIMGroupManager.h
//  ImSDK
//
//  Created by bodeng on 17/3/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMGroupManager_h
#define ImSDK_TIMGroupManager_h

#import "TIMComm.h"

#import "TIMCodingModel.h"

@class TIMMessage;

/**
 * 加群选项
 */
typedef NS_ENUM(NSInteger, TIMGroupAddOpt) {
    /**
     *  禁止加群
     */
    TIM_GROUP_ADD_FORBID                    = 0,
    
    /**
     *  需要管理员审批
     */
    TIM_GROUP_ADD_AUTH                      = 1,
    
    /**
     *  任何人可以加入
     */
    TIM_GROUP_ADD_ANY                       = 2,
};

/**
 * 群消息接受选项
 */
typedef NS_ENUM(NSInteger, TIMGroupReceiveMessageOpt) {
    /**
     *  接收消息
     */
    TIM_GROUP_RECEIVE_MESSAGE                       = 0,
    /**
     *  不接收消息，服务器不进行转发
     */
    TIM_GROUP_NOT_RECEIVE_MESSAGE                   = 1,
    /**
     *  接受消息，不进行iOS APNs 推送
     */
    TIM_GROUP_RECEIVE_NOT_NOTIFY_MESSAGE            = 2,
};

/**
 * 群成员角色
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberRole) {
    /**
     *  群成员
     */
    TIM_GROUP_MEMBER_ROLE_MEMBER              = 200,
    
    /**
     *  群管理员
     */
    TIM_GROUP_MEMBER_ROLE_ADMIN               = 300,
    
    /**
     *  群主
     */
    TIM_GROUP_MEMBER_ROLE_SUPER               = 400,
};

/**
 *  群成员角色过滤方式
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberFilter) {
    /**
     *  全部成员
     */
    TIM_GROUP_MEMBER_FILTER_ALL            = 0x00,
    /**
     *  群主
     */
    TIM_GROUP_MEMBER_FILTER_SUPER          = 0x01,
    /**
     *  管理员
     */
    TIM_GROUP_MEMBER_FILTER_ADMIN          = 0x02,
    /**
     *  普通成员
     */
    TIM_GROUP_MEMBER_FILTER_COMMON         = 0x04,
};

/**
 * 群成员获取资料标志
 */
typedef NS_ENUM(NSInteger, TIMGetGroupMemInfoFlag) {
    
    /**
     * 入群时间
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_JOIN_TIME                    = 0x01,
    /**
     * 消息标志
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_MSG_FLAG                     = 0x01 << 1,
    /**
     * 角色
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_ROLE_INFO                    = 0x01 << 3,
    /**
     * 禁言时间
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_SHUTUP_TIME                  = 0x01 << 4,
    /**
     * 群名片
     */
    TIM_GET_GROUP_MEM_INFO_FLAG_NAME_CARD                    = 0x01 << 5,
};

/**
 * 群基本获取资料标志
 */
typedef NS_ENUM(NSInteger, TIMGetGroupBaseInfoFlag) {
    
    TIM_GET_GROUP_BASE_INFO_FLAG_NONE                           = 0x00,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_NAME                           = 0x01,

    TIM_GET_GROUP_BASE_INFO_FLAG_CREATE_TIME                    = 0x01 << 1,

    TIM_GET_GROUP_BASE_INFO_FLAG_OWNER_UIN                      = 0x01 << 2,

    TIM_GET_GROUP_BASE_INFO_FLAG_SEQ                            = 0x01 << 3,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_TIME                           = 0x01 << 4,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_NEXT_MSG_SEQ                   = 0x01 << 5,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG_TIME                  = 0x01 << 6,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_APP_ID                         = 0x01 << 7,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_MEMBER_NUM                     = 0x01 << 8,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_MAX_MEMBER_NUM                 = 0x01 << 9,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_NOTIFICATION                   = 0x01 << 10,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_INTRODUCTION                   = 0x01 << 11,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_FACE_URL                       = 0x01 << 12,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_ADD_OPTION                     = 0x01 << 13,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_GROUP_TYPE                     = 0x01 << 14,
    
    TIM_GET_GROUP_BASE_INFO_FLAG_LAST_MSG                       = 0x01 << 15,
};

/**
 *  群搜索回调
 *
 *  @param totalNum 搜索结果的总数
 *  @param NSArray  请求的群列表片段
 */
typedef void (^TIMGroupSearchSucc)(uint64_t totalNum, NSArray *);

/**
 *  群接受消息选项回调
 *
 *  @param TIMGroupReceiveMessageOpt 群接受消息选项
 */
typedef void (^TIMGroupReciveMessageOptSucc)(TIMGroupReceiveMessageOpt);

@interface TIMGroupManager : NSObject

/**
 *  获取群管理器实例
 *
 *  @return 管理器实例
 */
+(TIMGroupManager*)sharedInstance;

/**
 *  创建私有群
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
-(int) CreatePrivateGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建公有群
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
-(int) CreatePublicGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建聊天室
 *
 *  @param members   群成员，NSString* 数组
 *  @param groupName 群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
-(int) CreateChatRoomGroup:(NSArray*)members groupName:(NSString*)groupName succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;

/**
 *  创建群组
 *
 *  @param type       群类型,Private,Public,ChatRoom
 *  @param members    待加入群组的成员列表
 *  @param groupName  群组名称
 *  @param groupId    自定义群组id
 *  @param succ       成功回调
 *  @param fail       失败回调
 *
 *  @return 0 成功
 */
-(int) CreateGroup:(NSString*)type members:(NSArray*)members groupName:(NSString*)groupName groupId:(NSString*)groupId succ:(TIMCreateGroupSucc)succ fail:(TIMFail)fail;


/**
 *  解散群组
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
-(int) DeleteGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  邀请好友入群
 *
 *  @param group   群组Id
 *  @param members 要加入的成员列表（NSString* 类型数组）
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
-(int) InviteGroupMember:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  删除群成员
 *
 *  @param group   群组Id
 *  @param members 要删除的成员列表
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
-(int) DeleteGroupMember:(NSString*)group members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  删除群成员
 *
 *  @param group   群组Id
 *  @param reason  删除原因
 *  @param members 要删除的成员列表
 *  @param succ    成功回调
 *  @param fail    失败回调
 *
 *  @return 0 成功
 */
-(int) DeleteGroupMemberWithReason:(NSString*)group reason:(NSString*)reason members:(NSArray*)members succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  申请加群
 *
 *  @param group 申请加入的群组Id
 *  @param msg   申请消息
 *  @param succ  成功回调（申请成功等待审批）
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
-(int) JoinGroup:(NSString*)group msg:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  主动退出群组
 *
 *  @param group 群组Id
 *  @param succ  成功回调
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
-(int) QuitGroup:(NSString*)group succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取群列表
 *
 *  @param succ 成功回调，NSArray列表为 TIMGroupInfo，结构体只包含 group\groupName\groupType\faceUrl 信息
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
-(int) GetGroupList:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群信息
 *
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
-(int) GetGroupInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  修改群名
 *
 *  @param group     群组Id
 *  @param groupName 新群名
 *  @param succ      成功回调
 *  @param fail      失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupName:(NSString*)group groupName:(NSString*)groupName succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群简介
 *
 *  @param group            群组Id
 *  @param introduction     群简介（最长120字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupIntroduction:(NSString*)group introduction:(NSString*)introduction succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群公告
 *
 *  @param group            群组Id
 *  @param notification     群公告（最长150字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupNotification:(NSString*)group notification:(NSString*)notification succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群头像
 *
 *  @param group            群组Id
 *  @param url              群头像地址（最长100字节）
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupFaceUrl:(NSString*)group url:(NSString*)url succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改加群选项
 *
 *  @param group            群组Id
 *  @param opt              加群选项，详见 TIMGroupAddOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupAddOpt:(NSString*)group opt:(TIMGroupAddOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取接受消息选项
 *
 *  @param group            群组Id
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) GetReciveMessageOpt:(NSString*)group succ:(TIMGroupReciveMessageOptSucc)succ fail:(TIMFail)fail;

/**
 *  修改接受消息选项
 *
 *  @param group            群组Id
 *  @param opt              接受消息选项，详见 TIMGroupReceiveMessageOpt
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyReciveMessageOpt:(NSString*)group opt:(TIMGroupReceiveMessageOpt)opt succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群成员角色
 *
 *  @param group            群组Id
 *  @param identifier       被修改角色的用户identifier
 *  @param opt              角色（注意：不能修改为群主），详见 TIMGroupMemberRole
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupMemberInfoSetRole:(NSString*)group user:(NSString*)identifier role:(TIMGroupMemberRole)role succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  禁言用户（只有管理员或群主能够调用）
 *
 *  @param group            群组Id
 *  @param identifier       被禁言的用户identifier
 *  @param stime            禁言时间
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupMemberInfoSetSilence:(NSString*)group user:(NSString*)identifier stime:(uint32_t)stime succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  修改群名片（只有本人、管理员或群主能够调用）
 *
 *  @param group            群组Id
 *  @param identifier       被操作用户identifier
 *  @param nameCard         群名片
 *  @param succ             成功回调
 *  @param fail             失败回调
 *
 *  @return 0 成功
 */
-(int) ModifyGroupMemberInfoSetNameCard:(NSString*)group user:(NSString*)identifier nameCard:(NSString*)nameCard succ:(TIMSucc)succ fail:(TIMFail)fail;


/**
 *  获取群成员列表
 *
 *  @param group 群组Id
 *  @param succ  成功回调(TIMGroupMemberInfo列表)
 *  @param fail  失败回调
 *
 *  @return 0 成功
 */
-(int) GetGroupMembers:(NSString*)group succ:(TIMGroupMemberSucc)succ fail:(TIMFail)fail;

/**
 *  获取群公开信息
 *  @param groups 群组Id
 *  @param succ 成功回调
 *  @param fail 失败回调
 *
 *  @return 0 成功
 */
-(int) GetGroupPublicInfo:(NSArray*)groups succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  获取群成员列表（支持按字段拉取，分页）
 *
 *  @param group    群组Id
 *  @param flags    拉取资料标志
 *  @param custom   要获取的自定义key列表，暂不支持，传nil
 *  @param nextSeq  分页拉取标志，第一次拉取填0，回调成功如果不为零，需要分页，传入再次拉取，直至为0
 *  @param succ     成功回调
 *  @param fail     失败回调
 *
 *  @return 0 成功
 */
-(int) GetGroupMembersV2:(NSString*)group flags:(TIMGetGroupMemInfoFlag)flags custom:(NSArray*)custom nextSeq:(uint64_t)nextSeq succ:(TIMGroupMemberSuccV2)succ fail:(TIMFail)fail;

/**
 *  获取指定类型的成员列表（支持按字段拉取，分页）
 *
 *  @param group      群组Id：（NSString*) 列表
 *  @param filter     群成员角色过滤方式
 *  @param flags      拉取资料标志
 *  @param custom     要获取的自定义key（NSString*）列表
 *  @param nextSeq    分页拉取标志，第一次拉取填0，回调成功如果不为零，需要分页，传入再次拉取，直至为0
 *  @param succ       成功回调
 *  @param fail       失败回调
 */
-(int) GetGroupMembers:(NSString*)group ByFilter:(TIMGroupMemberFilter)filter flags:(TIMGetGroupMemInfoFlag)flags custom:(NSArray*)custom nextSeq:(uint64_t)nextSeq succ:(TIMGroupMemberSuccV2)succ fail:(TIMFail)fail;

/**
 *  获取群公开资料（可指定字段拉取）
 *
 *  @param group    群组Id：（NSString*) 列表
 *  @param flags    拉取资料标志
 *  @param custom   要获取的自定义key（NSString*）列表
 *  @param succ     成功回调
 *  @param fail     失败回调
 */
-(int) GetGroupPublicInfoV2:(NSArray*)groups flags:(TIMGetGroupBaseInfoFlag)flags custom:(NSArray*)custom succ:(TIMGroupListSucc)succ fail:(TIMFail)fail;

/**
 *  通过名称信息获取群资料（可指定字段拉取）
 *
 *  @param groupName      群组名称
 *  @param flags          拉取资料标志
 *  @param custom         要获取的自定义key（NSString*）列表
 *  @param pageIndex      分页号
 *  @param pageSize       每页群组数目
 *  @param succ           成功回调
 *  @param fail           失败回调
 */
-(int) SearchGroup:(NSString*)groupName flags:(TIMGetGroupBaseInfoFlag)flags custom:(NSArray*)custom pageIndex:(uint32_t)pageIndex pageSize:(uint32_t)pageSize succ:(TIMGroupSearchSucc)succ fail:(TIMFail)fail;

@end

/**
 *  群资料信息
 */
@interface TIMGroupInfo : TIMCodingModel {
    NSString*       group;          // 群组Id
    NSString*       groupName;      // 群名
    NSString*       groupType;      // 群组类型
    NSString*       owner;          // 创建人
    uint32_t        createTime;     // 群创建时间
    uint32_t        lastInfoTime;   // 最近一次修改资料时间
    uint32_t        lastMsgTime;    // 最近一次发消息时间
    uint32_t        memberNum;      // 群成员数量
    
    NSString*       notification;      // 群公告
    NSString*       introduction;      // 群简介
    
    NSString*       faceURL;            // 群头像
    
    TIMMessage *     lastMsg;           // 最后一条消息
    
    NSDictionary *   customInfo;        // 自定义字段集合
}

/**
 *  群组Id
 */
@property(nonatomic,retain) NSString* group;
/**
 *  群名
 */
@property(nonatomic,retain) NSString* groupName;
/**
 *  群创建人/管理员
 */
@property(nonatomic,retain) NSString * owner;
/**
 *  群类型：Private,Public,Chatroom
 */
@property(nonatomic,retain) NSString* groupType;
/**
 *  群创建时间
 */
@property(nonatomic,assign) uint32_t createTime;
/**
 *  最近一次群资料修改时间
 */
@property(nonatomic,assign) uint32_t lastInfoTime;
/**
 *  最近一次发消息时间
 */
@property(nonatomic,assign) uint32_t lastMsgTime;
/**
 *  群成员数量
 */
@property(nonatomic,assign) uint32_t memberNum;

/**
 *  群公告
 */
@property(nonatomic,retain) NSString* notification;

/**
 *  群简介
 */
@property(nonatomic,retain) NSString* introduction;

/**
 *  群头像
 */
@property(nonatomic,retain) NSString* faceURL;

/**
 *  最后一条消息
 */
@property(nonatomic,retain) TIMMessage* lastMsg;

/**
 *  自定义字段集合,key是NSString*类型,value是NSData*类型
 */
@property(nonatomic,retain) NSDictionary* customInfo;

@end


/**
 *  群组操作结果
 */
typedef NS_ENUM(NSInteger, TIMGroupMemberStatus) {
    /**
     *  操作失败
     */
    TIM_GROUP_MEMBER_STATUS_FAIL              = 0,
    
    /**
     *  操作成功
     */
    TIM_GROUP_MEMBER_STATUS_SUCC              = 1,
    
    /**
     *  无效操作，加群时已经是群成员，移除群组时不在群内
     */
    TIM_GROUP_MEMBER_STATUS_INVALID           = 2,
};

/**
 *  成员操作返回值
 */
@interface TIMGroupMemberResult : NSObject

/**
 *  被操作成员
 */
@property(nonatomic,retain) NSString* member;
/**
 *  返回状态
 */
@property(nonatomic,assign) TIMGroupMemberStatus status;

@end


/**
 *  成员操作返回值
 */
@interface TIMGroupMemberInfo : TIMCodingModel

/**
 *  被操作成员
 */
@property(nonatomic,retain) NSString* member;

/**
 *  群名片
 */
@property(nonatomic,retain) NSString* nameCard;

/**
 *  加入群组时间
 */
@property(nonatomic,assign) time_t joinTime;

/**
 *  成员类型
 */
@property(nonatomic,assign) TIMGroupMemberRole role;

/**
 *  禁言时间（剩余秒数）
 */
@property(nonatomic, assign) uint32_t silentUntil;

@end

#endif
