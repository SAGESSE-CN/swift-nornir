//
//  TIMComm.h
//  ImSDK
//
//  Created by bodeng on 29/1/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMComm_h
#define ImSDK_TIMComm_h

#import <Foundation/Foundation.h>

#define ERR_IMSDK_KICKED_BY_OTHERS      6208


/**
 * 网络连接状态
 */
typedef NS_ENUM(NSInteger, TIMNetworkStatus) {
    /**
     * 已连接
     */
    TIM_NETWORK_STATUS_CONNECTED             = 1,
    /**
     * 链接断开
     */
    TIM_NETWORK_STATUS_DISCONNECTED          = 2,
};


/**
 * 日志级别
 */
typedef NS_ENUM(NSInteger, TIMLogLevel) {
    TIM_LOG_NONE                = 0,
    TIM_LOG_ERROR               = 1,
    TIM_LOG_WARN                = 2,
    TIM_LOG_INFO                = 3,
    TIM_LOG_DEBUG               = 4,
};

/////////////////////////////////////////////////////////
///  回调Block
/////////////////////////////////////////////////////////

/**
 *  获取消息回调
 *
 *  @param NSArray 消息列表
 */
typedef void (^TIMGetMsgSucc)(NSArray *);

/**
 *  一般操作成功回调
 */
typedef void (^TIMSucc)();

/**
 *  一般操作失败回调
 *
 *  @param code     错误码
 *  @param NSString 错误描述
 */
typedef void (^TIMFail)(int code, NSString *);

/**
 *  登陆成功回调
 */
typedef void (^TIMLoginSucc)();

/**
 *  获取资源
 *
 *  @param NSData 资源二进制
 */
typedef void (^TIMGetResourceSucc)(NSData *);



/**
 *  群创建成功
 *
 *  @param NSString 群组Id
 */
typedef void (^TIMCreateGroupSucc)(NSString *);

/**
 *  群成员列表回调
 *
 *  @param NSArray 群成员列表
 */
typedef void (^TIMGroupMemberSucc)(NSArray *);

/**
 *  群成员列表回调（分页使用）
 *
 *  @param NSArray 群成员（TIMGroupMemberInfo*）列表
 */
typedef void (^TIMGroupMemberSuccV2)(uint64_t nextSeq, NSArray *);

/**
 *  群列表回调
 *
 *  @param NSArray 群列表
 */
typedef void (^TIMGroupListSucc)(NSArray *);


/**
 *  日志回调
 *
 *  @param lvl      输出的日志级别
 *  @param NSString 日志内容
 */
typedef void (^TIMLogFunc)(TIMLogLevel lvl, NSString *);


@class TIMImageElem;
/**
 *  上传图片成功回调
 *
 *  @param elem 上传图片成功后elem
 */
typedef void (^TIMUploadImageSucc)(TIMImageElem * elem);

/////////////////////////////////////////////////////////
///  基本类型
/////////////////////////////////////////////////////////

/**
 *  登陆信息
 */

@interface TIMLoginParam : NSObject{
    NSString*       accountType;        // 用户的账号类型
    NSString*       identifier;         // 用户名
    NSString*       userSig;            // 鉴权Token
    NSString*       appidAt3rd;          // App用户使用OAuth授权体系分配的Appid

    int             sdkAppId;           // 用户标识接入SDK的应用ID
}

/**
 *  用户的账号类型
 */
@property(nonatomic,retain) NSString* accountType;

/**
 * 用户名
 */
@property(nonatomic,retain) NSString* identifier;

/**
 *  鉴权Token
 */
@property(nonatomic,retain) NSString* userSig;

/**
 *  App用户使用OAuth授权体系分配的Appid
 */
@property(nonatomic,retain) NSString* appidAt3rd;


/**
 *  用户标识接入SDK的应用ID
 */
@property(nonatomic,assign) int sdkAppId;

@end



/**
 * 会话类型：
 *      C2C     双人聊天
 *      GROUP   群聊
 */
typedef NS_ENUM(NSInteger, TIMConversationType) {
    /**
     *  C2C 类型
     */
    TIM_C2C              = 1,
    
    /**
     *  群聊 类型
     */
    TIM_GROUP            = 2,
    
    /**
     *  系统消息
     */
    TIM_SYSTEM           = 3,
};



/**
 *  消息状态
 */
typedef NS_ENUM(NSInteger, TIMMessageStatus){
    /**
     *  消息发送中
     */
    TIM_MSG_STATUS_SENDING              = 1,
    /**
     *  消息发送成功
     */
    TIM_MSG_STATUS_SEND_SUCC            = 2,
    /**
     *  消息发送失败
     */
    TIM_MSG_STATUS_SEND_FAIL            = 3,
    /**
     *  消息被删除
     */
    TIM_MSG_STATUS_HAS_DELETED          = 4,
};

/**
 *  SetToken 参数
 */
@interface TIMTokenParam : NSObject
/**
 *  获取的客户端Token信息
 */
@property(nonatomic,retain) NSData* token;
/**
 *  业务ID，传递证书时分配，如果只有一个证书，可以填0
 */
@property(nonatomic,assign) uint32_t busiId;

@end


/**
 *  切后台参数
 */
@interface TIMBackgroundParam : NSObject {
    int c2cUnread;
    int groupUnread;
}

/**
 *  C2C 未读计数
 */
@property(nonatomic,assign) int c2cUnread;

/**
 *  群 未读计数
 */
@property(nonatomic,assign) int groupUnread;

@end

/**
 *  群组提示类型
 */
typedef NS_ENUM(NSInteger, TIMGroupTipsType){
    /**
     *  成员加入
     */
    TIM_GROUP_TIPS_JOIN              = 1,
    /**
     *  成员离开
     */
    TIM_GROUP_TIPS_QUIT              = 2,
    /**
     *  成员被踢
     */
    TIM_GROUP_TIPS_KICK              = 3,
    /**
     *  成员设置管理员
     */
    TIM_GROUP_TIPS_SET_ADMIN         = 4,
    /**
     *  成员取消管理员
     */
    TIM_GROUP_TIPS_CANCEL_ADMIN      = 5,
};

#endif
