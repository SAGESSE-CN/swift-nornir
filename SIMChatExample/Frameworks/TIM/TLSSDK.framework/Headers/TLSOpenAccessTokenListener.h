//
//  TLSOpenAccessTokenListener.h
//  TLSSDK
//
//  Created by okhowang on 15/11/16.
//
//
#ifndef TLSSDK_TLSOpenAccessTokenListener_h
#define TLSSDK_TLSOpenAccessTokenListener_h
#import <Foundation/Foundation.h>
#import "TLSErrInfo.h"
#import "TLSTokenInfo.h"
@protocol TLSOpenAccessTokenListener <NSObject>
@required
-(void)OnOpenAccessTokenSuccess:(TLSTokenInfo*)tokenInfo;
-(void)OnOpenAccessTokenTimeout:(TLSErrInfo*)errInfo;
-(void)OnOpenAccessTokenFail:(TLSErrInfo*)errInfo;
@end
#endif
