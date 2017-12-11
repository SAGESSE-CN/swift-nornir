//
//  UIViewController+ForwardOfStatusBar.h
//  MMProgressHUD
//
//  Created by sagesse on 12/4/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (ForwardOfStatusBar)

///
/// @brief 需要转发的控制器
///
@property (nonatomic, unsafe_unretained) UIViewController* forwardViewController;

@end
