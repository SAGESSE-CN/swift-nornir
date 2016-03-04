//
//  SIMChatMediaRecorderProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaRecorderDelegate: class {
    
    func recorderShouldPrepare(recorder: SIMChatMediaRecorderProtocol) -> Bool
    func recorderDidPrepare(recorder: SIMChatMediaRecorderProtocol)
    
    func recorderShouldRecord(recorder: SIMChatMediaRecorderProtocol) -> Bool
    func recorderDidRecord(recorder: SIMChatMediaRecorderProtocol)
    
    func recorderDidStop(recorder: SIMChatMediaRecorderProtocol)
    func recorderDidCancel(recorder: SIMChatMediaRecorderProtocol)
    func recorderDidFinish(recorder: SIMChatMediaRecorderProtocol)
    func recorderDidErrorOccur(recorder: SIMChatMediaRecorderProtocol, error: NSError)
}

public protocol SIMChatMediaRecorderProtocol: class {
    
    var resource: SIMChatResourceProtocol { get }
    
    var recording: Bool { get }
    var currentTime: NSTimeInterval { get }
    
    weak var delegate: SIMChatMediaRecorderDelegate? { set get }
    
    func prepare()
    func record()
    func stop()
    func cancel()
    
    func meter(channel: Int) -> Float
}

public let SIMChatMediaRecorderWillPrepare = "SIMChatMediaRecorderWillPrepare"
public let SIMChatMediaRecorderDidPrepare = "SIMChatMediaRecorderDidPrepare"
public let SIMChatMediaRecorderWillRecord = "SIMChatMediaRecorderWillRecord"
public let SIMChatMediaRecorderDidRecord = "SIMChatMediaRecorderDidRecord"
public let SIMChatMediaRecorderDidStop = "SIMChatMediaRecorderDidStop"
public let SIMChatMediaRecorderDidFinsh = "SIMChatMediaRecorderDidFinsh"
public let SIMChatMediaRecorderDidCancel = "SIMChatMediaRecorderDidCancel"
public let SIMChatMediaRecorderDidErrorOccur = "SIMChatMediaRecorderDidErrorOccur"