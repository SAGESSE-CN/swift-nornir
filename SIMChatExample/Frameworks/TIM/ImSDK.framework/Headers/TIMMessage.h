//
//  TIMMessage.h
//  ImSDK
//
//  Created by bodeng on 28/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMMessage_h
#define ImSDK_TIMMessage_h


#import <Foundation/Foundation.h>

#import "TIMComm.h"
#import "TIMCallback.h"


/**
 *  消息会话
 */
@class TIMConversation;

/**
 *  消息Elem基类
 */
@interface TIMElem : NSObject
@end

/**
 *  文本消息Elem
 */
@interface TIMTextElem : TIMElem
/**
 *  消息文本
 */
@property(nonatomic,retain) NSString * text;
@end


/**
 *  图片压缩选项
 */
typedef NS_ENUM(NSInteger, TIM_IMAGE_COMPRESS_TYPE){
    /**
     *  原图(不压缩）
     */
    TIM_IMAGE_COMPRESS_ORIGIN              = 0x00,
    /**
     *  高压缩率：图片较小，默认值
     */
    TIM_IMAGE_COMPRESS_HIGH                = 0x01,
    /**
     *  低压缩：高清图发送(图片较大)
     */
    TIM_IMAGE_COMPRESS_LOW                 = 0x02,
};

/**
 *  图片类型
 */
typedef NS_ENUM(NSInteger, TIM_IMAGE_TYPE){
    /**
     *  原图
     */
    TIM_IMAGE_TYPE_ORIGIN              = 0x01,
    /**
     *  缩略图
     */
    TIM_IMAGE_TYPE_THUMB               = 0x02,
    /**
     *  大图
     */
    TIM_IMAGE_TYPE_LARGE               = 0x04,
};

@interface TIMImage : NSObject
/**
 *  图片ID，内部标识，可用于外部缓存key
 */
@property(nonatomic,retain) NSString * uuid;
/**
 *  图片类型
 */
@property(nonatomic,assign) TIM_IMAGE_TYPE type;
/**
 *  图片大小
 */
@property(nonatomic,assign) int size;
/**
 *  图片宽度
 */
@property(nonatomic,assign) int width;
/**
 *  图片高度
 */
@property(nonatomic,assign) int height;
/**
 *  下载URL
 */
@property(nonatomic, retain) NSString * url;

/**
 *  获取图片
 *
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) getImage:(NSString*) path succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  获取图片
 *
 *  @param path 图片保存路径
 *  @param cb 图片获取回调
 */
- (void) getImage:(NSString*) path cb:(id<TIMCallback>)cb;

@end


/**
 *  图片消息Elem
 */
@interface TIMImageElem : TIMElem

/**
 *  要发送的图片路径
 */
@property(nonatomic,retain) NSString * path;

/**
 *  所有类型图片，只读
 */
@property(nonatomic,retain) NSArray * imageList;

/**
 * 上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;

/**
 *  图片压缩等级，详见 TIM_IMAGE_COMPRESS_TYPE
 */
@property(nonatomic,assign) TIM_IMAGE_COMPRESS_TYPE level;


/**
 *  查询上传进度
 */
- (uint32_t) getUploadingProgress;

@end

/**
 *  文件消息Elem
 */
@interface TIMFileElem : TIMElem
/**
 *  文件数据，发消息时设置，收到消息时不能读取，通过 getFileData 获取数据
 */
@property(nonatomic,retain) NSData * data;
/**
 *  文件内部ID
 */
@property(nonatomic,retain) NSString * uuid;
/**
 *  文件大小
 */
@property(nonatomic,assign) int fileSize;
/**
 *  文件显示名，发消息时设置
 */
@property(nonatomic,retain) NSString * filename;

/**
 *  获取文件
 *
 *  @param succ 成功回调，返回原始文件数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) getFileData:(TIMGetResourceSucc)succ fail:(TIMFail)fail;
@end

/**
 *  语音消息Elem
 */
@interface TIMSoundElem : TIMElem
/**
 *  存储语音数据
 */
@property(nonatomic,retain) NSData * data;
/**
 *  语音消息内部ID
 */
@property(nonatomic,retain) NSString * uuid;
/**
 *  语音数据大小
 */
@property(nonatomic,assign) int dataSize;
/**
 *  语音长度（秒），发送消息时设置
 */
@property(nonatomic,assign) int second;

/**
 *  获取语音数据
 *
 *  @param succ 成功回调，返回语音数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) getSound:(TIMGetResourceSucc)succ fail:(TIMFail)fail;

/**
 *  获取语音数据
 *
 *  @param cb 资源获取回调
 */
- (void) getSound:(id<TIMResourceCallback>)cb;

@end


/**
 *  群Tips类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_TIPS_TYPE){
    /**
     *  邀请加入群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_INVITE              = 0x01,
    /**
     *  退出群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_QUIT_GRP            = 0x02,
    /**
     *  踢出群 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_KICKED              = 0x03,
    /**
     *  设置管理员 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_SET_ADMIN           = 0x04,
    /**
     *  取消管理员 (opUser & groupName & userList)
     */
    TIM_GROUP_TIPS_TYPE_CANCEL_ADMIN        = 0x05,
    /**
     *  群资料变更 (opUser & groupName & introduction & notification & faceUrl & owner)
     */
    TIM_GROUP_TIPS_TYPE_INFO_CHANGE         = 0x06,
    /**
     *  群成员资料变更 (opUser & groupName & memberInfoList)
     */
    TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE         = 0x07,
};

/**
 *  群tips，成员变更信息
 */
@interface TIMGroupTipsElemMemberInfo : NSObject

/**
 *  变更用户
 */
@property(nonatomic,retain) NSString * identifier;
/**
 *  禁言时间（秒，表示还剩多少秒可以发言）
 */
@property(nonatomic,assign) uint32_t shutupTime;

@end


/**
 *  群Tips类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_INFO_CHANGE_TYPE){
    /**
     *  群名修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_NAME                    = 0x01,
    /**
     *  群简介修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_INTRODUCTION            = 0x02,
    /**
     *  群公告修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_NOTIFICATION            = 0x03,
    /**
     *  群头像修改
     */
    TIM_GROUP_INFO_CHANGE_GROUP_FACE                    = 0x04,
    /**
     *  群主变更
     */
    TIM_GROUP_INFO_CHANGE_GROUP_OWNER                   = 0x05,
};

/**
 *  群tips，群变更信息
 */
@interface TIMGroupTipsElemGroupInfo : NSObject

/**
 *  变更类型
 */
@property(nonatomic, assign) TIM_GROUP_INFO_CHANGE_TYPE type;

/**
 *  根据变更类型表示不同含义
 */
@property(nonatomic,retain) NSString * value;
@end

/**
 *  群Tips
 */
@interface TIMGroupTipsElem : TIMElem

/**
 *  群Tips类型
 */
@property(nonatomic,assign) TIM_GROUP_TIPS_TYPE type;

/**
 *  操作人用户名
 */
@property(nonatomic,retain) NSString * opUser;

/**
 *  被操作人列表 NSString* 数组
 */
@property(nonatomic,retain) NSArray * userList;

/**
 *  在群名变更时表示变更后的群名，否则为 nil
 */
@property(nonatomic,retain) NSString * groupName;

/**
 *  群信息变更： TIM_GROUP_TIPS_TYPE_INFO_CHANGE 时有效，为 TIMGroupTipsElemGroupInfo 结构体列表
 */
@property(nonatomic,retain) NSArray * groupChangeList;

/**
 *  成员变更： TIM_GROUP_TIPS_TYPE_MEMBER_INFO_CHANGE 时有效，为 TIMGroupTipsElemMemberInfo 结构体列表
 */
@property(nonatomic,retain) NSArray * memberChangeList;

@end

/**
 *  地理位置Elem
 */
@interface TIMLocationElem : TIMElem
/**
 *  地理位置描述信息，发送消息时设置
 */
@property(nonatomic,retain) NSString * desc;
/**
 *  纬度，发送消息时设置
 */
@property(nonatomic,assign) double latitude;
/**
 *  精度，发送消息时设置
 */
@property(nonatomic,assign) double longitude;
@end


/**
 *  自定义消息类型
 */
@interface TIMCustomElem : TIMElem

/**
 *  自定义消息二进制数据
 */
@property(nonatomic,retain) NSData * data;
/**
 *  自定义消息描述信息，做离线Push时文本展示
 */
@property(nonatomic,retain) NSString * desc;
/**
 *  离线Push时扩展字段信息
 */
@property(nonatomic,retain) NSString * ext;
@end

/**
 *  表情消息类型
 */
@interface TIMFaceElem : TIMElem

/**
 *  表情索引，用户自定义
 */
@property(nonatomic, assign) int index;
/**
 *  额外数据，用户自定义
 */
@property(nonatomic,retain) NSData * data;
@end


/**
 *  群系统消息类型
 */
typedef NS_ENUM(NSInteger, TIM_GROUP_SYSTEM_TYPE){
    /**
     *  申请加群请求（只有管理员会收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_REQUEST_TYPE              = 0x01,
    /**
     *  申请加群被同意（只有申请人能够收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_ACCEPT_TYPE               = 0x02,
    /**
     *  申请加群被拒绝（只有申请人能够收到）
     */
    TIM_GROUP_SYSTEM_ADD_GROUP_REFUSE_TYPE               = 0x03,
    /**
     *  被管理员踢出群（只有被踢的人能够收到）
     */
    TIM_GROUP_SYSTEM_KICK_OFF_FROM_GROUP_TYPE            = 0x04,
    /**
     *  群被解散（全员能够收到）
     */
    TIM_GROUP_SYSTEM_DELETE_GROUP_TYPE                   = 0x05,
    /**
     *  创建群消息（创建者能够收到）
     */
    TIM_GROUP_SYSTEM_CREATE_GROUP_TYPE                   = 0x06,
    /**
     *  邀请入群通知(被邀请者能够收到)
     */
    TIM_GROUP_SYSTEM_INVITED_TO_GROUP_TYPE               = 0x07,
    /**
     *  主动退群（主动退群者能够收到）
     */
    TIM_GROUP_SYSTEM_QUIT_GROUP_TYPE                     = 0x08,
    /**
     *  设置管理员(被设置者接收)
     */
    TIM_GROUP_SYSTEM_GRANT_ADMIN_TYPE                    = 0x09,
    /**
     *  取消管理员(被取消者接收)
     */
    TIM_GROUP_SYSTEM_CANCEL_ADMIN_TYPE                   = 0x0a,
    /**
     *  群已被回收(全员接收)
     */
    TIM_GROUP_SYSTEM_REVOKE_GROUP_TYPE                   = 0x0b,
    /**
     *  邀请入群请求(被邀请者接收)
     */
    TIM_GROUP_SYSTEM_INVITE_TO_GROUP_REQUEST_TYPE        = 0x0c,
    /**
     *  用户自定义通知(默认全员接收)
     */
    TIM_GROUP_SYSTEM_CUSTOM_INFO                         = 0xff,
};

/**
 *  群系统消息
 */
@interface TIMGroupSystemElem : TIMElem

/**
 * 操作类型
 */
@property(nonatomic,assign) TIM_GROUP_SYSTEM_TYPE type;

/**
 * 群组Id
 */
@property(nonatomic,retain) NSString * group;

/**
 * 操作人
 */
@property(nonatomic,retain) NSString * user;

/**
 * 操作理由
 */
@property(nonatomic,retain) NSString * msg;


/**
 *  消息标识，客户端无需关心
 */
@property(nonatomic,assign) uint64_t msgKey;

/**
 *  消息标识，客户端无需关心
 */
@property(nonatomic,retain) NSData * authKey;

/**
 *  用户自定义透传消息体（type＝TIM_GROUP_SYSTEM_CUSTOM_INFO时有效）
 */
@property(nonatomic,retain) NSData * userData;

/**
 *  同意申请，目前只对申请加群和被邀请入群消息生效
 *
 *  @param msg  同意理由，选填
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) accept:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

/**
 *  拒绝申请，目前只对申请加群和被邀请入群消息生效
 *
 *  @param msg  拒绝理由，选填
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) refuse:(NSString*)msg succ:(TIMSucc)succ fail:(TIMFail)fail;

@end


typedef NS_ENUM(NSInteger, TIM_SNS_SYSTEM_TYPE){
    /**
     *  增加好友消息
     */
    TIM_SNS_SYSTEM_ADD_FRIEND                           = 0x01,
    /**
     *  删除好友消息
     */
    TIM_SNS_SYSTEM_DEL_FRIEND                           = 0x02,
    /**
     *  增加好友申请
     */
    TIM_SNS_SYSTEM_ADD_FRIEND_REQ                       = 0x03,
    /**
     *  删除未决申请
     */
    TIM_SNS_SYSTEM_DEL_FRIEND_REQ                       = 0x04,
    /**
     *  黑名单添加
     */
    TIM_SNS_SYSTEM_ADD_BLACKLIST                        = 0x05,
    /**
     *  黑名单删除
     */
    TIM_SNS_SYSTEM_DEL_BLACKLIST                        = 0x06,
    /**
     *  未决已读上报
     */
    TIM_SNS_SYSTEM_PENDENCY_REPORT                      = 0x07,
    /**
     *  关系链资料变更
     */
    TIM_SNS_SYSTEM_SNS_PROFILE_CHANGE                   = 0x08,
    /**
     *  推荐数据增加
     */
    TIM_SNS_SYSTEM_ADD_RECOMMEND                        = 0x09,
    /**
     *  推荐数据删除
     */
    TIM_SNS_SYSTEM_DEL_RECOMMEND                        = 0x0a,
    /**
     *  已决增加
     */
    TIM_SNS_SYSTEM_ADD_DECIDE                           = 0x0b,
    /**
     *  已决删除
     */
    TIM_SNS_SYSTEM_DEL_DECIDE                           = 0x0c,
    /**
     *  推荐已读上报
     */
    TIM_SNS_SYSTEM_RECOMMEND_REPORT                     = 0x0d,
    /**
     *  已决已读上报
     */
    TIM_SNS_SYSTEM_DECIDE_REPORT                        = 0x0e,


};


/**
 *  关系链变更详细信息
 */
@interface TIMSNSChangeInfo : NSObject

/**
 *  用户 identifier
 */
@property(nonatomic,retain) NSString * identifier;

/**
 *  申请添加时有效，添加理由
 */
@property(nonatomic,retain) NSString * wording;

/**
 *  申请时填写，添加来源
 */
@property(nonatomic,retain) NSString * source;


/**
 *  备注 type=TIM_SNS_SYSTEM_SNS_PROFILE_CHANGE 有效
 */
@property(nonatomic,retain) NSString * remark;

@end

/**
 *  关系链变更消息
 */
@interface TIMSNSSystemElem : TIMElem

/**
 * 操作类型
 */
@property(nonatomic,assign) TIM_SNS_SYSTEM_TYPE type;

/**
 * 被操作用户列表：TIMSNSChangeInfo 列表
 */
@property(nonatomic,retain) NSArray * users;

/**
 * 未决已读上报时间戳 type=TIM_SNS_SYSTEM_PENDENCY_REPORT 有效
 */
@property(nonatomic,assign) uint64_t pendencyReportTimestamp;

/**
 * 推荐已读上报时间戳 type=TIM_SNS_SYSTEM_RECOMMEND_REPORT 有效
 */
@property(nonatomic,assign) uint64_t recommendReportTimestamp;

/**
 * 已决已读上报时间戳 type=TIM_SNS_SYSTEM_DECIDE_REPORT 有效
 */
@property(nonatomic,assign) uint64_t decideReportTimestamp;

@end

/**
 *  资料变更
 */
typedef NS_ENUM(NSInteger, TIM_PROFILE_SYSTEM_TYPE){
    /**
     好友资料变更
     */
    TIM_PROFILE_SYSTEM_FRIEND_PROFILE_CHANGE        = 0x01,
};


/**
 *  资料变更系统消息
 */
@interface TIMProfileSystemElem : TIMElem

/**
 *  变更类型
 */
@property(nonatomic,assign) TIM_PROFILE_SYSTEM_TYPE type;

/**
 *  资料变更的用户
 */
@property(nonatomic,retain) NSString * fromUser;

/**
 *  资料变更的昵称（如果昵称没有变更，该值为nil）
 */
@property(nonatomic,retain) NSString * nickName;

@end


@interface TIMVideo : NSObject
/**
 *  视频ID，SDK内部用于获取视频URL
 */
@property(nonatomic,retain) NSString * uuid;
/**
 *  视频文件类型，发送消息时设置
 */
@property(nonatomic,retain) NSString * type;
/**
 *  视频大小，不用设置
 */
@property(nonatomic,assign) int size;
/**
 *  视频时长，发送消息时设置
 */
@property(nonatomic,assign) int duration;

/**
 *  获取视频
 *
 *  @param path 视频保存路径
 *  @param succ 成功回调
 *  @param fail 失败回调，返回错误码和错误描述
 */
-(void) getVideo:(NSString*)path succ:(TIMSucc)succ fail:(TIMFail)fail;

@end


@interface TIMSnapshot : NSObject
/**
 *  图片ID，SDK内部用于获取截图URL
 */
@property(nonatomic,retain) NSString * uuid;
/**
 *  截图文件类型，发送消息时设置
 */
@property(nonatomic,retain) NSString * type;
/**
 *  图片大小，不用设置
 */
@property(nonatomic,assign) int size;
/**
 *  图片宽度，发送消息时设置
 */
@property(nonatomic,assign) int width;
/**
 *  图片高度，发送消息时设置
 */
@property(nonatomic,assign) int height;

/**
 *  获取图片
 *
 *  @param path 图片保存路径
 *  @param succ 成功回调，返回图片数据
 *  @param fail 失败回调，返回错误码和错误描述
 */
- (void) getImage:(NSString*) path succ:(TIMSucc)succ fail:(TIMFail)fail;

@end

/**
 *  微视频消息
 */
@interface TIMVideoElem : TIMElem

/**
 *  上传时任务Id，可用来查询上传进度
 */
@property(nonatomic,assign) uint32_t taskId;

/**
 *  视频文件路径，发送消息时设置
 */
@property(nonatomic,retain) NSString * videoPath;

/**
 *  视频信息，发送消息时设置
 */
@property(nonatomic,retain) TIMVideo * video;

/**
 *  截图文件路径，发送消息时设置
 */
@property(nonatomic,retain) NSString * snapshotPath;

/**
 *  视频截图，发送消息时设置
 */
@property(nonatomic,retain) TIMSnapshot * snapshot;

/**
 *  查询上传进度
 */
- (uint32_t) getUploadingProgress;

@end


/**
 *  消息
 */
@interface TIMMessage : NSObject {
}

/**
 *  增加Elem
 *
 *  @param elem elem结构
 *
 *  @return 0       表示成功
 *          1       禁止添加Elem（文件或语音多于两个Elem）
 *          2       未知Elem
 */
-(int) addElem:(TIMElem*)elem;

/**
 *  获取对应索引的Elem
 *
 *  @param index 对应索引
 *
 *  @return 返回对应Elem
 */
-(TIMElem*) getElem:(int)index;

/**
 *  获取Elem数量
 *
 *  @return elem数量
 */
-(int) elemCount;

/**
 *  获取会话
 *
 *  @return 该消息所对应会话
 */
-(TIMConversation*) getConversation;

/**
 *  是否已读
 *
 *  @return TRUE 已读  FALSE 未读
 */
-(BOOL) isReaded;

/**
 *  消息状态
 *
 *  @return TIMMessageStatus 消息状态
 */
-(TIMMessageStatus) status;

/**
 *  是否发送方
 *
 *  @return TRUE 表示是发送消息    FALSE 表示是接收消息
 */
-(BOOL) isSelf;

/**
 *  获取发送方
 *
 *  @return 发送方标识
 */
-(NSString *) sender;

/**
 *  删除消息：注意这里仅修改状态
 *
 *  @return TRUE 成功
 */
-(BOOL) remove;

/**
 *  消息Id
 */
-(NSString *) msgId;

/**
 *  消息有断层，OnNewMessage回调收到消息，如果有断层，需要重新GetMessage补全（有C2C漫游的情况下使用）
 *
 *  @return TRUE 有断层
 *          FALSE  无断层
 */
-(BOOL) hasGap;

/**
 *  当前消息的时间戳
 *
 *  @return 时间戳
 */
-(NSDate*) timestamp;

@end

#endif
