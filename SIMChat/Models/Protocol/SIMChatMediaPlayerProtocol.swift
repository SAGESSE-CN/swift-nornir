//
//  SIMChatMediaPlayerProtocol.swift
//  SIMChat
//
//  Created by sagesse on 2/23/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import Foundation

public protocol SIMChatMediaPlayerDelegate: class {
    
    func playerShouldPrepare(player: SIMChatMediaPlayerProtocol) -> Bool
    func playerDidPrepare(player: SIMChatMediaPlayerProtocol)
    
    func playerShouldPlay(player: SIMChatMediaPlayerProtocol) -> Bool
    func playerDidPlay(player: SIMChatMediaPlayerProtocol)
    
    func playerDidStop(player: SIMChatMediaPlayerProtocol)
    
    func playerDidFinish(player: SIMChatMediaPlayerProtocol)
    func playerDidErrorOccur(player: SIMChatMediaPlayerProtocol, error: NSError)
}

public protocol SIMChatMediaPlayerProtocol: class {
    
    var resource: SIMChatResourceProtocol { get }
    
    var playing: Bool { get }
    var duration: NSTimeInterval { get }
    var currentTime: NSTimeInterval { get }
    
    weak var delegate: SIMChatMediaPlayerDelegate? { set get }
    
    func prepare()
    func play()
    func stop()
    
    func meter(channel: Int) -> Float
}

public let SIMChatMediaPlayerWillPrepare = "SIMChatMediaPlayerWillPrepare"
public let SIMChatMediaPlayerDidPrepare = "SIMChatMediaPlayerDidPrepare"
public let SIMChatMediaPlayerWillPlay = "SIMChatMediaPlayerWillPlay"
public let SIMChatMediaPlayerDidPlay = "SIMChatMediaPlayerDidPlay"
public let SIMChatMediaPlayerDidStop = "SIMChatMediaPlayerDidStop"
public let SIMChatMediaPlayerDidFinsh = "SIMChatMediaPlayerDidFinsh"
public let SIMChatMediaPlayerDidErrorOccur = "SIMChatMediaPlayerDidErrorOccur"
