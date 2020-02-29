//
//  SAMAudioSession.swift
//  SAMedia
//
//  Created by SAGESSE on 27/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation


public extension AVAudioSession {
    
    func sm_setActive(_ active: Bool, context: AnyObject? = nil) throws {
        try _AVAudioSessionPerformTask(active, context: context) {
            try AVAudioSession.sharedInstance().setActive(active)
        }
    }
    func sm_setActive(_ active: Bool, with options: AVAudioSession.SetActiveOptions, context: AnyObject? = nil) throws {
        try _AVAudioSessionPerformTask(active, context: context) {
            try AVAudioSession.sharedInstance().setActive(active, options: options)
        }
    }
}

private func _AVAudioSessionPerformTask(_ newValue: Bool, context: AnyObject?, task body: @escaping () throws -> Void) rethrows {
    
    let newTaskId = UUID().uuidString
    let newContextHash = context?.hash
    
    objc_sync_enter(AVAudioSession.self)
    
    _AVAudioSessionTaskId = newTaskId
    //_AVAudioSessionTaskContext = newContext//context
    _AVAudioSessionTaskContextHash = newContextHash
    
    objc_sync_exit(AVAudioSession.self)
    
    
    guard !newValue else {
        // 这是激活操作
        return try body()
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(3 * 1000))) {
        // 这是取消操作
        
        // 读取
        objc_sync_enter(AVAudioSession.self)
        
        let taskId = _AVAudioSessionTaskId
        //let context = _AVAudioSessionTaskContext
        let contextHash = _AVAudioSessionTaskContextHash
        
        objc_sync_exit(AVAudioSession.self)
        
        // 检查任务是否有效
        guard taskId == newTaskId else {
            return
        }
        // 检查当前激活的context是否匹配
        guard contextHash == newContextHash else {
            return
        }
        
        // 清空
        objc_sync_enter(AVAudioSession.self)
        
        _AVAudioSessionTaskId = nil
        _AVAudioSessionTaskContext = nil
        _AVAudioSessionTaskContextHash = nil
        
        objc_sync_exit(AVAudioSession.self)
        
        // 应用
        _ = try? body()
    }
}

private var _AVAudioSessionTaskId: String? = nil
private var _AVAudioSessionTaskContextHash: Int? = nil

private weak var _AVAudioSessionTaskContext: AnyObject?
