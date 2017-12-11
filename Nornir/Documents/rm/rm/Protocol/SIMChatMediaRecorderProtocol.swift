//
//  SIMChatMediaRecorderProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaRecorderDelegate: class {
    
    func recorderShouldPrepare(_ recorder: SIMChatMediaRecorderProtocol) -> Bool
    func recorderDidPrepare(_ recorder: SIMChatMediaRecorderProtocol)
    
    func recorderShouldRecord(_ recorder: SIMChatMediaRecorderProtocol) -> Bool
    func recorderDidRecord(_ recorder: SIMChatMediaRecorderProtocol)
    
    func recorderDidStop(_ recorder: SIMChatMediaRecorderProtocol)
    func recorderDidCancel(_ recorder: SIMChatMediaRecorderProtocol)
    func recorderDidFinish(_ recorder: SIMChatMediaRecorderProtocol)
    func recorderDidErrorOccur(_ recorder: SIMChatMediaRecorderProtocol, error: NSError)
}

public protocol SIMChatMediaRecorderProtocol: class {
    
    var resource: SIMChatResourceProtocol { get }
    
    var recording: Bool { get }
    var currentTime: TimeInterval { get }
    
    weak var delegate: SIMChatMediaRecorderDelegate? { set get }
    
    func prepare()
    func record()
    func stop()
    func cancel()
    
    func meter(_ channel: Int) -> Float
}

public let SIMChatMediaRecorderWillPrepare = "SIMChatMediaRecorderWillPrepare"
public let SIMChatMediaRecorderDidPrepare = "SIMChatMediaRecorderDidPrepare"
public let SIMChatMediaRecorderWillRecord = "SIMChatMediaRecorderWillRecord"
public let SIMChatMediaRecorderDidRecord = "SIMChatMediaRecorderDidRecord"
public let SIMChatMediaRecorderDidStop = "SIMChatMediaRecorderDidStop"
public let SIMChatMediaRecorderDidFinsh = "SIMChatMediaRecorderDidFinsh"
public let SIMChatMediaRecorderDidCancel = "SIMChatMediaRecorderDidCancel"
public let SIMChatMediaRecorderDidErrorOccur = "SIMChatMediaRecorderDidErrorOccur"
