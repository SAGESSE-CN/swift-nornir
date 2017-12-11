//
//  SIMChatMediaPlayerProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaPlayerDelegate: class {
    
    func playerShouldPrepare(_ player: SIMChatMediaPlayerProtocol) -> Bool
    func playerDidPrepare(_ player: SIMChatMediaPlayerProtocol)
    
    func playerShouldPlay(_ player: SIMChatMediaPlayerProtocol) -> Bool
    func playerDidPlay(_ player: SIMChatMediaPlayerProtocol)
    
    func playerDidStop(_ player: SIMChatMediaPlayerProtocol)
    
    func playerDidFinish(_ player: SIMChatMediaPlayerProtocol)
    func playerDidErrorOccur(_ player: SIMChatMediaPlayerProtocol, error: NSError)
}

public protocol SIMChatMediaPlayerProtocol: class {
    
    var resource: SIMChatResourceProtocol { get }
    
    var playing: Bool { get }
    var duration: TimeInterval { get }
    var currentTime: TimeInterval { get }
    
    weak var delegate: SIMChatMediaPlayerDelegate? { set get }
    
    func prepare()
    func play()
    func stop()
    
    func meter(_ channel: Int) -> Float
}

public let SIMChatMediaPlayerWillPrepare = "SIMChatMediaPlayerWillPrepare"
public let SIMChatMediaPlayerDidPrepare = "SIMChatMediaPlayerDidPrepare"
public let SIMChatMediaPlayerWillPlay = "SIMChatMediaPlayerWillPlay"
public let SIMChatMediaPlayerDidPlay = "SIMChatMediaPlayerDidPlay"
public let SIMChatMediaPlayerDidStop = "SIMChatMediaPlayerDidStop"
public let SIMChatMediaPlayerDidFinsh = "SIMChatMediaPlayerDidFinsh"
public let SIMChatMediaPlayerDidErrorOccur = "SIMChatMediaPlayerDidErrorOccur"
