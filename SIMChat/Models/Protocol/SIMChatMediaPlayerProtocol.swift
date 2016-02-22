//
//  SIMChatMediaPlayerProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaPlayerProtocol: class {
    
    var url: NSURL { get }
    var playing: Bool { get }
    
    func prepare()
    func play()
    func stop()
}

public let SIMChatMediaPlayerWillPrepare = "SIMChatMediaPlayerWillPrepare"
public let SIMChatMediaPlayerDidPrepare = "SIMChatMediaPlayerDidPrepare"
public let SIMChatMediaPlayerWillPlay = "SIMChatMediaPlayerWillPlay"
public let SIMChatMediaPlayerDidPlay = "SIMChatMediaPlayerDidPlay"
public let SIMChatMediaPlayerDidStop = "SIMChatMediaPlayerDidStop"
public let SIMChatMediaPlayerDidFinsh = "SIMChatMediaPlayerDidFinsh"
public let SIMChatMediaPlayerDidErrorOccur = "SIMChatMediaPlayerDidErrorOccur"
