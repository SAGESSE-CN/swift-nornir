//
//  SAIAudioSession.swift
//  SAC
//
//  Created by SAGESSE on 9/18/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

open class SAIAudioSession {
    
    open static func setCategory(_ category: String) throws {
        try AVAudioSession.sharedInstance().setCategory(category)
    }
    open static func setCategory(_ category: String, with options: AVAudioSessionCategoryOptions) throws {
        try AVAudioSession.sharedInstance().setCategory(category, with: options)
    }
    
    open static func setActive(_ active: Bool, context: AnyObject? = nil) throws {
        
        objc_sync_enter(SAIAudioSession.self)
        defer {
            objc_sync_exit(SAIAudioSession.self)
        }
        
        guard !active else {
            _task = NSUUID().uuidString
            _context = context
            try AVAudioSession.sharedInstance().setActive(active)
            return
        }
        deactive(delay: 1, context: context) {
            _ = try? AVAudioSession.sharedInstance().setActive(active)
        }
    }
    open static func setActive(_ active: Bool, with options: AVAudioSessionSetActiveOptions, context: AnyObject? = nil) throws {
        
        objc_sync_enter(SAIAudioSession.self)
        defer {
            objc_sync_exit(SAIAudioSession.self)
        }
        
        guard !active else {
            _task = NSUUID().uuidString
            _context = context
            try AVAudioSession.sharedInstance().setActive(active, with: options)
            return
        }
        deactive(delay: 1, context: context) {
            _ = try? AVAudioSession.sharedInstance().setActive(active, with: options)
        }
    }
    
    open static func deactive(delay: TimeInterval, context: AnyObject?, execute: @escaping (Void) -> Void) {
        
        objc_sync_enter(SAIAudioSession.self)
        defer {
            objc_sync_exit(SAIAudioSession.self)
        }
        
        guard _context === context else {
            return // 不匹配, 说明别人正在使用
        }
        let task = NSUUID().uuidString
        
        _task = task
        _context = context
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay * 1000))) {
            
            objc_sync_enter(SAIAudioSession.self)
            defer {
                objc_sync_exit(SAIAudioSession.self)
            }
            
            guard _task == task else {
                _logger.debug("can't deactive, the task is expire")
                return // 不匹配, 说明该任务己经过期了
            }
            guard _context === context else {
                _logger.debug("can't deactive, the other is use")
                return // 不匹配, 说明别人正在使用
            }
            execute()
            _context = nil
        }
    }
    
    private static var _logger: Logger = Logger(name: "SAIAudioSession")
    
    private static var _task: String?
    private static weak var _context: AnyObject?
}
