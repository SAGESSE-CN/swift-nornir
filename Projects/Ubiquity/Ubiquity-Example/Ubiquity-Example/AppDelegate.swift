//
//  AppDelegate.swift
//  Ubiquity
//
//  Created by sagesse on 11/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

//+ (UIFont *)fontWithDescriptor:(UIFontDescriptor *)descriptor size:(CGFloat)pointSize NS_AVAILABLE_IOS(7_0);

//:size:

//extension UIFont {
//    
//    static func st() {
//        let m1 = class_getClassMethod(self, Selector(String("fontWithDescriptor:size:")))
//        let m2 = class_getClassMethod(self, Selector(String("my_fontWithDescriptor:size:")))
//        method_exchangeImplementations(m1, m2);
//    }
//    
//    class func my_fontWithDescriptor(_ descriptor: UIFontDescriptor, size: CGFloat) -> UIFont {
//        if descriptor.postscriptName == "AutoFontI375" {
//            return my_fontWithDescriptor(descriptor, size: size * 2)
//        }
//        return my_fontWithDescriptor(descriptor, size: size)
//    }
//}

//extension UIFont {
//    
//    static func st() {
//        let m1 = class_getInstanceMethod(self, Selector(String("initWithCoder:")))
//        let m2 = class_getInstanceMethod(self, #selector(my_init(coder:)))
//        method_exchangeImplementations(m1, m2)
//    }
//    
//    dynamic func my_init(coder: NSCoder) -> UIFont {
//        if (coder.decodeObject(forKey: "UIFontName") as? String) == "AutoI375" {
//            let m = class_getInstanceMethod(AIFont.self, #selector(getter: pointSize))
//            let imp = method_getImplementation(m)
//            class_addMethod(type(of: self), #selector(getter: pointSize), imp, method_getTypeEncoding(m))
//        }
//        let font = my_init(coder: coder)
//        return font
//    }
//}
//class AIFont: UIFont {
//    open override var pointSize: CGFloat {
//        return 32
//    }
//}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//class A: NSObject {
//    func xa () {
//    }
//}
//
//let a = A()
//a.xa()
//logger.error?.print("---")

//ProcessInfo().processName
//ProcessInfo().processIdentifier
//ProcessInfo().systemUptime
//print(info.system_time, info.user_time)


//task_t port = mach_thread_self();\
//struct task_thread_times_info startTime[TASK_INFO_MAX];\
//mach_msg_type_number_t count = TASK_INFO_MAX;\
//thread_info(port, TASK_THREAD_TIMES_INFO, (task_info_t)&startTime, &count);\
//time = ((double)(startTime->system_time.seconds+startTime->system_time.microseconds+startTime->user_time.seconds+startTime->user_time.microseconds))/MSEC_PER_SEC;\
        
//        DispatchQueue.main.async {
//            guard let window = self.window else {
//                return
//            }
//            
//            let l1 = UIView()
//            let l2 = UIView()
//            
//            l1.frame = CGRect(x: 0, y: 0, width: 0.5, height: window.frame.height)
//            l2.frame = CGRect(x: 0, y: 0, width: window.frame.width, height: 0.5)
//            l1.center = CGPoint(x: window.frame.width / 2, y: window.frame.height / 2)
//            l2.center = CGPoint(x: window.frame.width / 2, y: window.frame.height / 2)
//            l1.autoresizingMask = [.flexibleHeight, .flexibleLeftMargin, .flexibleRightMargin]
//            l2.autoresizingMask = [.flexibleWidth, .flexibleTopMargin, .flexibleBottomMargin]
//            l1.backgroundColor = .red
//            l2.backgroundColor = .red
//            l1.isUserInteractionEnabled = false
//            l2.isUserInteractionEnabled = false
//            
//            window.addSubview(l1)
//            window.addSubview(l2)
//        }
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

