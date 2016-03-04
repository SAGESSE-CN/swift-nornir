//
//  TIMCodingModel.h
//  ImSDK
//
//  Copyright (c) 2014 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TIMCodingModel : NSObject <NSCoding>

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

@end
