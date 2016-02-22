//
//  SIMChatMediaRecorderProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaRecorderProtocol: class {
    
    var url: NSURL { get }
    var recording: Bool { get }
    
    func prepare()
    func record()
    func stop()
}

public let SIMChatMediaRecorderWillPrepare = "SIMChatMediaRecorderWillPrepare"
public let SIMChatMediaRecorderDidPrepare = "SIMChatMediaRecorderDidPrepare"
public let SIMChatMediaRecorderWillPlay = "SIMChatMediaRecorderWillPlay"
public let SIMChatMediaRecorderDidPlay = "SIMChatMediaRecorderDidPlay"
public let SIMChatMediaRecorderDidStop = "SIMChatMediaRecorderDidStop"
public let SIMChatMediaRecorderDidFinsh = "SIMChatMediaRecorderDidFinsh"
public let SIMChatMediaRecorderDidErrorOccur = "SIMChatMediaRecorderDidErrorOccur"