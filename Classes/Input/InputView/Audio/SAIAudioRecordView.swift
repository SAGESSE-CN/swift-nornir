//
//  SAIAudioRecordView.swift
//  SAC
//
//  Created by SAGESSE on 9/16/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAMedia

internal class SAIAudioRecordView: SAIAudioView {
    
    func updateStatus(_ status: SAIAudioStatus) {
        _logger.trace(status)
        
        _status = status
        _statusView.status = status
        
        switch status {
        case .none,
             .error(_): // 错误状态
            
            if !_status.isError {
                _statusView.text = "点击录音"
            }
            
            _clearResources()
            _showRecordMode()
            
            _recordButton.isSelected = false
            _recordButton.isUserInteractionEnabled = true
            
        case .waiting: // 等待状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            
        case .processing: // 处理状态
            
            _playButton.isUserInteractionEnabled = false
            _recordButton.isUserInteractionEnabled = false
            
        case .recording: // 录音状态
            
            _recordButton.isSelected = true
            _recordButton.isUserInteractionEnabled = true
            
        case .playing: // 播放状态
            
            _playButton.isSelected = true
            _playButton.isUserInteractionEnabled = true
            
        case .processed: // 试听状态
            
            let t = Int(_recordDuration)
            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
            
            _playButton.progress = 0
            _playButton.isSelected = false
            _playButton.isUserInteractionEnabled = true
            
            _showPlayMode()
        }
    }
    
    fileprivate func _showPlayMode() {
        guard _playButton.isHidden else {
            return
        }
        _playButton.isHidden = false
        _playButton.alpha = 0
        _playToolbar.isHidden = false
        _playToolbar.transform = CGAffineTransform(translationX: 0, y: _playToolbar.frame.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._playButton.alpha = 1
            self._playToolbar.transform = .identity
            self._recordButton.alpha = 0
        }, completion: { f in
            self._recordButton.alpha = 1
            self._recordButton.isHidden = true
        })
    }
    fileprivate func _showRecordMode() {
        guard _recordButton.isHidden else {
            return
        }
        
        _recordButton.alpha = 0
        _recordButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self._playButton.alpha = 0
            self._playToolbar.transform = CGAffineTransform(translationX: 0, y: self._playToolbar.frame.height)
            self._recordButton.alpha = 1
        }, completion: { f in
            self._playButton.alpha = 1
            self._playButton.isHidden = true
            self._playButton.isSelected = false
            self._playToolbar.transform = .identity
            self._playToolbar.isHidden = true
        })
    }
    
    fileprivate func _clearResources() {
        _recorder?.delegate = nil
        _recorder?.stop() 
        _recorder = nil
        _player?.delegate = nil
        _player?.stop()
        _player = nil
    }
    
    
    fileprivate func _updateTime() {
        if _status.isRecording {
            _recordDuration = _recorder?.currentTime ?? 0
            let t = Int(_recordDuration)
            _statusView.text = String(format: "%0d:%02d", t / 60, t % 60)
            _statusView.spectrumView.isHidden = false
            return
        }
        if _status.isPlaying {
            let d = TimeInterval(_recordDuration)
            let ct = TimeInterval(_player?.currentTime ?? 0)
            
            _playButton.setProgress(CGFloat(ct + 0.2) / CGFloat(d), animated: true)
            
            _statusView.text = String(format: "%0d:%02d", Int(ct) / 60, Int(ct) % 60)
            _statusView.spectrumView.isHidden = false
            return
        }
    }
    
    
    fileprivate func _makePlayer(_ url: URL) -> SAMAudioPlayer {
        let player = try! SAMAudioPlayer(contentsOf: _recordFileAtURL)
        player.delegate = self
        player.isMeteringEnabled = true
        return player
    }
    fileprivate func _makeRecorder(_ url: URL) -> SAMAudioRecorder {
        let recorder = try! SAMAudioRecorder(contentsOf: _recordFileAtURL)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        return recorder
    }
    
    private func _init() {
        _logger.trace()
        
        let hcolor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        _statusView.text = "点击录音"
        _statusView.delegate = self
        _statusView.translatesAutoresizingMaskIntoConstraints = false
        
        let playbg = UIImage.sai_init(named: "keyboard_audio_play_background")
        let recordbg = UIImage.sai_init(named: "keyboard_audio_record_background")
        
        _playButton.isHidden = true
        _playButton.progressColor = hcolor
        _playButton.progressLineWidth = 2
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.setBackgroundImage(playbg, for: .normal)
        _playButton.setBackgroundImage(playbg, for: .highlighted)
        _playButton.setBackgroundImage(playbg, for: [.selected, .normal])
        _playButton.setBackgroundImage(playbg, for: [.selected, .highlighted])
        _playButton.setImage(UIImage.sai_init(named: "keyboard_audio_play_start_nor"), for: .normal)
        _playButton.setImage(UIImage.sai_init(named: "keyboard_audio_play_start_press"), for: .highlighted)
        _playButton.setImage(UIImage.sai_init(named: "keyboard_audio_play_stop_nor"), for: [.selected, .normal])
        _playButton.setImage(UIImage.sai_init(named: "keyboard_audio_play_stop_press"), for: [.selected, .highlighted])
        _playButton.addTarget(self, action: #selector(onPlayAndStop(_:)), for: .touchUpInside)
        
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        _playToolbar.cancelButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.confirmButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        _recordButton.setImage(UIImage.sai_init(named: "keyboard_audio_record_start_nor"), for: .normal)
        _recordButton.setImage(UIImage.sai_init(named: "keyboard_audio_record_start_press"), for: .highlighted)
        _recordButton.setImage(UIImage.sai_init(named: "keyboard_audio_record_stop_nor"), for: [.selected, .normal])
        _recordButton.setImage(UIImage.sai_init(named: "keyboard_audio_record_stop_press"), for: [.selected, .highlighted])
        _recordButton.setBackgroundImage(recordbg, for: .normal)
        _recordButton.setBackgroundImage(recordbg, for: .highlighted)
        _recordButton.setBackgroundImage(recordbg, for: [.selected, .normal])
        _recordButton.setBackgroundImage(recordbg, for: [.selected, .highlighted])
        _recordButton.addTarget(self, action: #selector(onRecordAndStop(_:)), for: .touchUpInside)
        
        // add subview
        addSubview(_recordButton)
        addSubview(_playButton)
        addSubview(_playToolbar)
        addSubview(_statusView)
        
        addConstraint(_SAILayoutConstraintMake(_playButton, .centerX, .equal, _recordButton, .centerX))
        addConstraint(_SAILayoutConstraintMake(_playButton, .centerY, .equal, _recordButton, .centerY))
        
        addConstraint(_SAILayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SAILayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -8))
        
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_statusView, .top, .equal, self, .top, 8))
        addConstraint(_SAILayoutConstraintMake(_statusView, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SAILayoutConstraintMake(_statusView, .centerX, .equal, self, .centerX))
    }
    
    fileprivate lazy var _playButton: SAIAudioPlayButton = SAIAudioPlayButton()
    fileprivate lazy var _playToolbar: SAIAudioPlayToolbar = SAIAudioPlayToolbar()
    
    fileprivate lazy var _recordButton: SAIAudioRecordButton = SAIAudioRecordButton()
    
    fileprivate lazy var _status: SAIAudioStatus = .none
    fileprivate lazy var _statusView: SAIAudioStatusView = SAIAudioStatusView()
    
    fileprivate var _recordDuration: TimeInterval = 0
    fileprivate lazy var _recordFileAtURL: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("sai-audio-record.m3a"))
    
    fileprivate var _recorder: SAMAudioRecorder?
    fileprivate var _player: SAMAudioPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

// MARK: - Toucn Events

extension SAIAudioRecordView {
    
    @objc func onCancel(_ sender: Any) {
        _logger.trace()
        
        let duration = _recordDuration
        let url = _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didFailure: url, duration: duration)
    }
    @objc func onConfirm(_ sender: Any) {
        _logger.trace()
        
        let duration = _recordDuration
        let url = _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didComplete: url, duration: duration)
    }
    @objc func onRecordAndStop(_ sender: Any) {
        _logger.trace()
        
        if let recorder = _recorder {
            recorder.stop()
        } else {
            _recorder = _makeRecorder(_recordFileAtURL)
            _recorder?.record()
        }
    }
    @objc func onPlayAndStop(_ sender: Any) {
        _logger.trace()
        
        if _player?.isPlaying ?? false {
            _player?.stop()
        } else {
            _player = _player ?? _makePlayer(_recordFileAtURL)
            _player?.currentTime = 0
            _player?.play()
        }
    }
}


// MARK: - SAIAudioPlayerDelegate

extension SAIAudioRecordView: SAMAudioPlayerDelegate {
   
    public func audioPlayer(shouldPreparing audioPlayer: SAMedia.SAMAudioPlayer) -> Bool {
        _logger.trace()
        updateStatus(.waiting)
        return true
    }
    public func audioPlayer(didPreparing audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
    }

    public func audioPlayer(shouldPlaying audioPlayer: SAMedia.SAMAudioPlayer) -> Bool {
        _logger.trace()
        return true
    }
    public func audioPlayer(didPlaying audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
        updateStatus(.playing)
    }

    public func audioPlayer(didStop audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
        updateStatus(.processed)
    }

    public func audioPlayer(didInterruption audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
        updateStatus(.processed)
    }

    public func audioPlayer(didFinishPlaying audioPlayer: SAMedia.SAMAudioPlayer, successfully flag: Bool) {
        _logger.trace()
        updateStatus(.processed)
    }

    public func audioPlayer(didOccur audioPlayer: SAMedia.SAMAudioPlayer, error: Error?) {
        _logger.trace(error)
        
        updateStatus(.error(error?.localizedDescription ?? "Unknow error"))
    }
}

// MARK: - SAIAudioRecorderDelegate

extension SAIAudioRecordView: SAMAudioRecorderDelegate {
    
    public func audioRecorder(shouldPreparing audioRecorder: SAMedia.SAMAudioRecorder) -> Bool {
        _logger.trace()
        
        guard delegate?.audioView(self, shouldStartRecord: _recordFileAtURL) ?? true else {
            return false
        }
        updateStatus(.waiting)
        return true
    }
    public func audioRecorder(didPreparing audioRecorder: SAMedia.SAMAudioRecorder) {
        _logger.trace()
        // 异步一下让系统消息有机会处理
//        DispatchQueue.main.async {
//            guard self._recordButton.isHighlighted else {
//                // 不能直接调用onCancel, 因为没有启动就没有失败
//                return self.updateStatus(.none)
//            }
//            self._recorder?.record()
//        }
    }

    public func audioRecorder(shouldRecording audioRecorder: SAMedia.SAMAudioRecorder) -> Bool {
        _logger.trace()
        return true
    }
    public func audioRecorder(didRecording audioRecorder: SAMedia.SAMAudioRecorder) {
        _logger.trace()
        
        delegate?.audioView(self, didStartRecord: _recordFileAtURL)
        updateStatus(.recording)
    }

    public func audioRecorder(didStop audioRecorder: SAMedia.SAMAudioRecorder) {
        _logger.trace()
        updateStatus(.processing)
    }
    public func audioRecorder(didInterruption audioRecorder: SAMedia.SAMAudioRecorder) {
        _logger.trace()
        updateStatus(.processed)
    }

    public func audioRecorder(didFinishRecording audioRecorder: SAMedia.SAMAudioRecorder, successfully flag: Bool) {
        _logger.trace()
        updateStatus(.processed)
    }

    public func audioRecorder(didOccur audioRecorder: SAMedia.SAMAudioRecorder, error: Error?) {
        _logger.trace(error)
        updateStatus(.error(error?.localizedDescription ?? "Unknow error"))
    }
}

// MARK: - SAIAudioStatusViewDelegate

extension SAIAudioRecordView: SAIAudioStatusViewDelegate {
    
    func statusView(_ statusView: SAIAudioStatusView, spectrumViewWillUpdateMeters: SAIAudioSpectrumView) {
        _updateTime()
        if _status.isPlaying {
            _player?.updateMeters()
        } else {
            _recorder?.updateMeters()
        }
    }
    
    func statusView(_ statusView: SAIAudioStatusView, spectrumView: SAIAudioSpectrumView, peakPowerFor channel: Int) -> Float {
        if _status.isPlaying {
            return _player?.peakPower(forChannel: 0) ?? -160
        } else {
            return _recorder?.peakPower(forChannel: 0) ?? -160
        }
    }
    func statusView(_ statusView: SAIAudioStatusView, spectrumView: SAIAudioSpectrumView, averagePowerFor channel: Int) -> Float {
        if _status.isPlaying {
            return _player?.averagePower(forChannel: 0) ?? -160
        } else {
            return _recorder?.averagePower(forChannel: 0) ?? -160
        }
    }
}
