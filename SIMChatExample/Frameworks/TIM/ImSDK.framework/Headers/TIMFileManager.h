//
//  TIMFileManager.h
//  ImSDK
//
//  Created by bodeng on 5/4/15.
//  Copyright (c) 2015 tencent. All rights reserved.
//

#ifndef ImSDK_TIMFileManager_h
#define ImSDK_TIMFileManager_h

#import "TIMComm.h"
#import "TIMMessage.h"

/**
 *  图片上传接口
 */
@interface TIMImageUploader : NSObject

/**
 *  提交上传图片任务
 *
 *  @param path  图片路径
 *
 *  @return 返回任务Id
 */
+ (uint32_t) submitUploadTask:(NSString*) path level:(TIM_IMAGE_COMPRESS_TYPE)level succ:(TIMUploadImageSucc)succ fail:(TIMFail)fail;

/**
 *  取消图片上传
 *
 *  @param taskId  任务Id
 */
+ (void) cancelTask:(uint32_t) taskId;

/**
 *  查询上传进度
 *
 *  @param taskId  任务Id
 */
+ (uint32_t) getUploadingProgress:(uint32_t) taskId;

@end

#endif
