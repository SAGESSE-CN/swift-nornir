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
            if player.URL === url {
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
            if recorder.URL === url {
                return recorder
            }
            recorder.stop()
        }
        return nil
    }
    
    public func imageBrowser() -> SIMChatMediaBrowserProtocol {
        return SIMChatMediaPhotoBrowser()
    }
    
    public func audioPlayer(URL: NSURL) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(URL) ?? {
            let player = SIMChatMediaAudioPlayer(URL: URL)
            _player = player
            return player
        }()
    }
    public func audioRecorder(URL: NSURL) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(URL) ?? {
            let recorder = SIMChatMediaAudioRecorder(URL: URL)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func videoPlayer(URL: NSURL) -> SIMChatMediaPlayerProtocol {
        return _reusePlayer(URL) ?? {
            let player = SIMChatMediaAudioPlayer(URL: URL)
            _player = player
            return player
        }()
    }
    public func videoRecorder(URL: NSURL) -> SIMChatMediaRecorderProtocol {
        return _reuseRecorder(URL) ?? {
            let recorder = SIMChatMediaAudioRecorder(URL: URL)
            _recorder = recorder
            return recorder
        }()
    }
    
    public func stop() {
        _player?.stop()
        _recorder?.stop()
    }
}

