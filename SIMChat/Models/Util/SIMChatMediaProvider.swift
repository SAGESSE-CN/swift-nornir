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
    
    private func _reusePlayer(url: NSURL) -> SIMChatMediaPlayerProtocol? {
        _recorder?.stop()
        if let player = _player {
            // 一样的.
            if player.url === url {
                return player
            }
            player.stop()
        }
        return nil
    }
    private func _reuseRecorder(url: NSURL) -> SIMChatMediaRecorderProtocol? {
        _recorder?.stop()
        if let recorder = _recorder {
            // 一样的.
            if recorder.url === url {
                return recorder
            }
            recorder.stop()
        }
        return nil
    }
    
    public func audioPlayer(url: NSURL) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(url) ?? {
            let player = SIMChatMediaAudioPlayer(url: url)
            _player = player
            return player
        }()
    }
    public func audioRecorder(url: NSURL) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(url) ?? {
            let recorder = SIMChatMediaAudioRecorder(url: url)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func videoPlayer(url: NSURL) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(url) ?? {
            let player = SIMChatMediaAudioPlayer(url: url)
            _player = player
            return player
        }()
    }
    public func videoRecorder(url: NSURL) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(url) ?? {
            let recorder = SIMChatMediaAudioRecorder(url: url)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func stop() {
        _player?.stop()
        _recorder?.stop()
    }
}

