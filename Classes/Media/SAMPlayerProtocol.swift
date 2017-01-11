//
//  SAMPlayerProtocol.swift
//  SAMedia
//
//  Created by SAGESSE on 28/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc public enum SAMVideoPlayerStatus: Int {
    
    // 准备状态
    case preparing
    case prepared
    
    // 播放状态
    case playing
    
    // 停止状态
    case stop
    case error
    
    // 中断状态
    case loading
    case pauseing
    case interruptioning
    
    
    public var isPrepared: Bool {
        switch self {
        case .preparing, .prepared,
             .pauseing, .loading, .interruptioning:
            return true
            
        default:
            return false
        }
    }
    public var isInterruptioned: Bool {
        switch self {
        case .loading, .pauseing, .interruptioning:
            return true
            
        default:
            return false
        }
    }
    public var isPlayed: Bool {
        switch self {
        case .playing:
            return true
            
        default:
            return false
        }
    }
    public var isStoped: Bool {
        switch self {
        case .stop, .error:
            return true
            
        default:
            return false
        }
    }
}


@objc public protocol SAMPlayerProtocol: NSObjectProtocol {
    
    // the player status
    var status: SAMVideoPlayerStatus { get }
    
    // the duration of the media.
    var duration: TimeInterval { get }
    
    // If the media is playing, currentTime is the offset into the media of the current playback position.
    // If the media is not playing, currentTime is the offset into the media where playing would start.
    var currentTime: TimeInterval { get }
   
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    var loadedTime: TimeInterval { get }
    
    // This property provides a collection of time ranges for which the download task has media data already downloaded and playable.
    // The ranges provided might be discontinuous.
    var loadedTimeRanges: Array<NSValue>? { get }
    
    // an delegate
    weak var delegate: SAMVideoPlayerDelegate? { set get }
    
    
    // MARK: - Transport Control
    
    
    // prepare media the resources needed and active audio session
    // methods that return BOOL return YES on success and NO on failure.
    @discardableResult func prepare() -> Bool
    
    // play a media, if it is not ready to complete, will be ready to complete the automatic playback.
    @discardableResult func play() -> Bool
    @discardableResult func play(at time: TimeInterval) -> Bool
    
    @discardableResult func seek(to time: TimeInterval) -> Bool
    
    // pause play
    func pause()
    
    func stop()
}


@objc public protocol SAMVideoPlayerDelegate {

    
    @objc optional func player(shouldPreparing player: SAMPlayerProtocol) -> Bool
    @objc optional func player(didPreparing player: SAMPlayerProtocol)
    
    @objc optional func player(shouldPlaying player: SAMPlayerProtocol) -> Bool
    @objc optional func player(didPlaying player: SAMPlayerProtocol)
    
    @objc optional func player(didPause player: SAMPlayerProtocol)
    @objc optional func player(didStalled player: SAMPlayerProtocol )
    @objc optional func player(didInterruption player: SAMPlayerProtocol)
    
    @objc optional func player(shouldRestorePlaying player: SAMPlayerProtocol) -> Bool
    @objc optional func player(didRestorePlaying player: SAMPlayerProtocol)
    
    @objc optional func player(didStop player: SAMPlayerProtocol)
    
    // playerDidFinishPlaying:successfully: is called when a video has finished playing. This method is NOT called if the player is stopped due to an interruption.
    @objc optional func player(didFinishPlaying player: SAMPlayerProtocol, successfully flag: Bool)
    
    // if an error occurs will be reported to the delegate.
    @objc optional func player(didOccur player: SAMPlayerProtocol, error: Error?)
    
    
    @objc optional func player(didChange player: SAMPlayerProtocol, currentTime time: TimeInterval)
    
    @objc optional func player(didChange player: SAMPlayerProtocol, loadedTime time: TimeInterval)
    @objc optional func player(didChange player: SAMPlayerProtocol, loadedTimeRanges ranges: Array<NSValue>)
}
