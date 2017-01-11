//
//  AppDelegate.swift
//  Browser
//
//  Created by sagesse on 11/13/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit
import AVFoundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
//        UIView.self.perform(Selector(String("_enableToolsDebugColorViewBounds:")), with: true)
        
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

