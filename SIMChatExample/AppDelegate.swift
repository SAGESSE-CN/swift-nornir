//
//  AppDelegate.swift
//  SIMChatExample
//
//  Created by sagesse on 2/2/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import SIMChat

//- (UIDevicePlatform) devicePlatformType
//    {
//        NSString *platform = [self devicePlatform];
//        
//        // The ever mysterious iFPGA
//        if ([platform isEqualToString:@"iFPGA"])        return UIDeviceIFPGA;
//        
//        // iPhone
//        if ([platform isEqualToString:@"iPhone1,1"])    return UIDevice1GiPhone;
//        if ([platform isEqualToString:@"iPhone1,2"])    return UIDevice3GiPhone;
//        if ([platform hasPrefix:@"iPhone2"])            return UIDevice3GSiPhone;
//        if ([platform hasPrefix:@"iPhone3"])            return UIDevice4iPhone;
//        if ([platform hasPrefix:@"iPhone4"])            return UIDevice4SiPhone;
//        
//        if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
//            return UIDevice5iPhone;
//        }
//        if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
//            return UIDevice5CiPhone;
//        }
//        if ([platform hasPrefix:@"iPhone6"]) {
//            return UIDevice5SiPhone;
//        }
//        
//        if ([platform isEqualToString:@"iPhone7,1"]) {
//            return UIDevice6PiPhone;
//        }
//        if ([platform isEqualToString:@"iPhone7,2"]) {
//            return UIDevice6iPhone;
//        }
//        if ([platform isEqualToString:@"iPhone8,1"]) {
//            return UIDevice6SiPhone;
//        }
//        if ([platform isEqualToString:@"iPhone8,2"]) {
//            return UIDevice6SPiPhone;
//        }
//        
//        // iPod
//        if ([platform hasPrefix:@"iPod1"])              return UIDevice1GiPod;
//        if ([platform hasPrefix:@"iPod2"])              return UIDevice2GiPod;
//        if ([platform hasPrefix:@"iPod3"])              return UIDevice3GiPod;
//        if ([platform hasPrefix:@"iPod4"])              return UIDevice4GiPod;
//        if ([platform hasPrefix:@"iPod5"])              return UIDevice5GiPod;
//        if ([platform hasPrefix:@"iPod7,1"])            return UIDeviceTouch6GiPod;
//        
//        // iPad
//        if ([platform hasPrefix:@"iPad1"])              return UIDevice1GiPad;
//        if ([platform isEqualToString:@"iPad2,1"] || [platform isEqualToString:@"iPad2,2"] || [platform isEqualToString:@"iPad2,3"] || [platform isEqualToString:@"iPad2,4"]) {
//            return UIDevice2GiPad;
//        }
//        //iPad Mini
//        if ([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"]) {
//            return UIDeviceMiniiPad;
//        }
//        if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"]) {
//            return UIDevice3GiPad;
//        }
//        if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"]) {
//            return UIDevice4GiPad;
//        }
//        //iPad Air
//        if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"]) {
//            return UIDeviceAiriPad;
//        }
//        //iPad Mini2
//        if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"] || [platform isEqualToString:@"iPad4,6"]) {
//            return UIDeviceMini2iPad;
//        }
//        //iPad Mini3
//        if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] || [platform isEqualToString:@"iPad4,9"]) {
//            return UIDeviceMini3iPad;
//        }
//        //iPad Mini4
//        if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"]) {
//            return UIDeviceMini4iPad;
//        }
//        //iPad Air2
//        if ([platform hasPrefix:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"]) {
//            return UIDeviceAir2iPad;
//        }
//        
//        // Apple TV
//        if ([platform hasPrefix:@"AppleTV2"])           return UIDeviceAppleTV2;
//        if ([platform hasPrefix:@"AppleTV3"])           return UIDeviceAppleTV3;
//        
//        if ([platform hasPrefix:@"iPhone"])             return UIDeviceUnknowniPhone;
//        if ([platform hasPrefix:@"iPod"])               return UIDeviceUnknowniPod;
//        if ([platform hasPrefix:@"iPad"])               return UIDeviceUnknowniPad;
//        if ([platform hasPrefix:@"AppleTV"])            return UIDeviceUnknownAppleTV;
//        
//        // Simulator thanks Jordan Breeding
//        if ([platform hasSuffix:@"86"] || [platform isEqual:@"x86_64"])
//        {
//            BOOL smallerScreen = [[UIScreen mainScreen] bounds].size.width < 768;
//            return smallerScreen ? UIDeviceSimulatoriPhone : UIDeviceSimulatoriPad;
//        }
//        
//        return UIDeviceUnknown;
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        dispatch_async(dispatch_get_main_queue()) {
            if let window = self.window {
                let label = SIMChatFPSLabel(frame: CGRectMake(window.bounds.width - 55 - 8, 20, 55, 20))
                label.autoresizingMask = [.FlexibleLeftMargin, .FlexibleBottomMargin]
                window.addSubview(label)
            }
        }
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

