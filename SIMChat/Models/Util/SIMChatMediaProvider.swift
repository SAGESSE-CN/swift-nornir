//
//  SIMChatMediaProvider.swift
//  SIMChat
//
//  Created by sagesse on 1/21/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import Foundation

public class SIMChatMediaProvider {
    
    private weak var _player: SIMChatMediaPlayerProtocol?
    private weak var _recorder: SIMChatMediaRecorderProtocol?
    
    private func _reusePlayer(resource: SIMChatResourceProtocol) -> SIMChatMediaPlayerProtocol? {
        _recorder?.stop()
        if let player = _player {
            // 一样的.
            if player.resource == resource {
                return player
            }
            player.stop()
        }
        return nil
    }
    private func _reuseRecorder(resource: SIMChatResourceProtocol) -> SIMChatMediaRecorderProtocol? {
        _recorder?.stop()
        if let recorder = _recorder {
            // 一样的.
            if recorder.resource == resource {
                return recorder
            }
            recorder.stop()
        }
        return nil
    }
    
    public func imageBrowser() -> SIMChatMediaBrowserProtocol {
        return SIMChatMediaPhotoBrowser()
    }
    
    public func currentPlayer() -> SIMChatMediaPlayerProtocol? {
        return _player
    }
    public func currentRecorder() -> SIMChatMediaRecorderProtocol? {
        return _recorder
    }
    
    public func audioPlayer(resource: SIMChatResourceProtocol) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(resource) ?? {
            let player = SIMChatMediaAudioPlayer(resource)
            _player = player
            return player
        }()
    }
    public func audioRecorder(resource: SIMChatResourceProtocol) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(resource) ?? {
            let recorder = SIMChatMediaAudioRecorder(resource)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func videoPlayer(resource: SIMChatResourceProtocol) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(resource) ?? {
            let player = SIMChatMediaAudioPlayer(resource)
            _player = player
            return player
        }()
    }
    public func videoRecorder(resource: SIMChatResourceProtocol) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(resource) ?? {
            let recorder = SIMChatMediaAudioRecorder(resource)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func stop() {
        _player?.stop()
        _recorder?.stop()
    }
}

