//
//  SAIAudioSimulateView.swift
//  SAC
//
//  Created by SAGESSE on 9/16/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAMedia

internal class SAIAudioSimulateView: SAIAudioView {
    
    func updateStatus(_ status: SAIAudioStatus) {
        _logger.trace(status)
        
        _status = status
        _statusView.status = status
        
        switch status {
        case .none,
             .error(_): // 错误状态
            
            if !_status.isError {
                _statusView.text = "按住变声"
            }
            
            _clearResources()
            _showRecordMode()
            
            _statusView.isHidden = false
            _recordButton.isUserInteractionEnabled = true
            _activatedEffectView?.status = .none
            
        case .waiting: // 等待状态
            
            _recordButton.isUserInteractionEnabled = false
            
        case .processing: // 处理状态
            
            _recordButton.isUserInteractionEnabled = false
            
        case .recording: // 录音状态
            
            _recordButton.isUserInteractionEnabled = true
            
        case .playing: // 播放状态(并没有这个状态)
            break
            
        case .processed: // 试听状态
            
            _statusView.isHidden = true
            _showPlayMode()
            
            _activatedEffect = _supportEffects.first
            _activatedEffectView = nil
            _processedFileAtURL = nil
            _playToolbar.confirmButton.isEnabled = true
            
            _supportEffects.forEach {
                $0.clearCache()
            }
            
            _simulateView.reloadData()
        }
    }
    
    fileprivate func _showPlayMode() {
        guard _simulateView.isHidden else {
            return
        }
        _logger.trace()
        
        _simulateView.isHidden = false
        _simulateView.alpha = 0
        _playToolbar.isHidden = false
        _playToolbar.transform = CGAffineTransform(translationX: 0, y: _playToolbar.frame.height)
        
        UIView.animate(withDuration: 0.25, animations: {
            self._simulateView.alpha = 1
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
        _logger.trace()
        
        _recordButton.alpha = 0
        _recordButton.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: {
            self._simulateView.alpha = 0
            self._playToolbar.transform = CGAffineTransform(translationX: 0, y: self._playToolbar.frame.height)
            self._recordButton.alpha = 1
        }, completion: { f in
            self._simulateView.alpha = 1
            self._simulateView.isHidden = true
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
    }
    
    
    fileprivate func _makePlayer(_ url: URL) -> SAMAudioPlayer {
        let player = try! SAMAudioPlayer(contentsOf: url)
        player.delegate = self
        player.isMeteringEnabled = true
        return player
    }
    fileprivate func _makeRecorder(_ url: URL) -> SAMAudioRecorder {
        let recorder = try! SAMAudioRecorder(contentsOf: url)
        recorder.delegate = self
        recorder.isMeteringEnabled = true
        return recorder
    }
    
    private func _init() {
        _logger.trace()
        
        let hcolor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        _statusView.text = "按住变声"
        _statusView.delegate = self
        _statusView.translatesAutoresizingMaskIntoConstraints = false
        
        _simulateViewLayout.itemSize = CGSize(width: 80, height: 80)
        _simulateViewLayout.minimumLineSpacing = 12
        _simulateViewLayout.minimumInteritemSpacing = 12
        
        _simulateView.isHidden = true
        _simulateView.backgroundColor = .clear
        _simulateView.translatesAutoresizingMaskIntoConstraints = false
        _simulateView.delegate = self
        _simulateView.dataSource = self
        _simulateView.allowsSelection = false
        _simulateView.allowsMultipleSelection = false
        _simulateView.register(SAIAudioEffectView.self, forCellWithReuseIdentifier: "Item")
        _simulateView.showsVerticalScrollIndicator = false
        _simulateView.showsHorizontalScrollIndicator = false
        _simulateView.contentInset = UIEdgeInsetsMake(18, 10, 18 + 44, 10)
        
        _playToolbar.isHidden = true
        _playToolbar.translatesAutoresizingMaskIntoConstraints = false
        _playToolbar.cancelButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.confirmButton.setTitleColor(hcolor, for: .normal)
        _playToolbar.cancelButton.addTarget(self, action: #selector(onCancel(_:)), for: .touchUpInside)
        _playToolbar.confirmButton.addTarget(self, action: #selector(onConfirm(_:)), for: .touchUpInside)
        
        _recordButton.translatesAutoresizingMaskIntoConstraints = false
        _recordButton.setBackgroundImage(UIImage.sai_init(named: "keyboard_audio_simulate_icon"), for: .normal)
        _recordButton.addTarget(self, action: #selector(onTouchStart(_:)), for: .touchDown)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragInside)
        _recordButton.addTarget(self, action: #selector(onTouchDrag(_:withEvent:)), for: .touchDragOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpInside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchUpOutside)
        _recordButton.addTarget(self, action: #selector(onTouchStop(_:)), for: .touchCancel)
        
        // add subview
        addSubview(_recordButton)
        addSubview(_statusView)
        addSubview(_simulateView)
        addSubview(_playToolbar)
        
        addConstraint(_SAILayoutConstraintMake(_recordButton, .centerX, .equal, self, .centerX))
        addConstraint(_SAILayoutConstraintMake(_recordButton, .centerY, .equal, self, .centerY, -8))
        
        addConstraint(_SAILayoutConstraintMake(_simulateView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_simulateView, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_simulateView, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_simulateView, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_playToolbar, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_statusView, .top, .equal, self, .top, 8))
        addConstraint(_SAILayoutConstraintMake(_statusView, .bottom, .equal, _recordButton, .top, -8))
        addConstraint(_SAILayoutConstraintMake(_statusView, .centerX, .equal, self, .centerX))
    }
    
    fileprivate var _activatedEffect: SAIAudioEffect?
    fileprivate weak var _activatedEffectView: SAIAudioEffectView?
    
    fileprivate lazy var _supportEffects: [SAIAudioEffect] = [
        SAIAudioEffect(type: .original),
        SAIAudioEffect(type: .ef1),
        SAIAudioEffect(type: .ef2),
        SAIAudioEffect(type: .ef3),
        SAIAudioEffect(type: .ef4),
        SAIAudioEffect(type: .ef5),
    ]
    
    
    fileprivate lazy var _simulateViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
    fileprivate lazy var _simulateView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._simulateViewLayout)
    
    fileprivate lazy var _playToolbar: SAIAudioPlayToolbar = SAIAudioPlayToolbar()
    
    fileprivate lazy var _recordButton: SAIAudioRecordButton = SAIAudioRecordButton()
    
    fileprivate lazy var _status: SAIAudioStatus = .none
    fileprivate lazy var _statusView: SAIAudioStatusView = SAIAudioStatusView()
    
    fileprivate var _recordDuration: TimeInterval = 0
    fileprivate lazy var _recordFileAtURL: URL = URL(fileURLWithPath: NSTemporaryDirectory().appending("sai-audio-record.m3a"))
    
    fileprivate var _processedFileAtURL: URL?
    
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

extension SAIAudioSimulateView {
    
    @objc func onCancel(_ sender: Any) {
        _logger.trace()
        
        let duration = _recordDuration
        let url = _processedFileAtURL ?? _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didFailure: url, duration: duration)
    }
    @objc func onConfirm(_ sender: Any) {
        _logger.trace()
        
        let duration = _recordDuration
        let url = _processedFileAtURL ?? _recordFileAtURL
        
        updateStatus(.none)
        
        delegate?.audioView(self, didComplete: url, duration: duration)
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
    
    @objc func onTouchStart(_ sender: Any) {
        guard _status.isNone || _status.isError else {
            return
        }
        _recorder = _makeRecorder(_recordFileAtURL)
        _recorder?.prepareToRecord()
        
        let ani = CAKeyframeAnimation(keyPath: "transform.scale")
        ani.values = [1, 1.2, 1]
        ani.duration = 0.15
        _recordButton.layer.add(ani, forKey: "click")
    }
    @objc func onTouchStop(_ sender: Any) {
        guard _status.isRecording else {
            return
        }
        _recorder?.stop()
    }
    @objc func onTouchDrag(_ sender: UIButton, withEvent event: UIEvent) {
        sender.isHighlighted = true
    }
}

// MARK: - SAIAudioEffectView

extension SAIAudioSimulateView: SAIAudioEffectViewDelegate {
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, shouldSelectItem audioEffect: SAIAudioEffect) -> Bool {
        return true
    }
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, didSelectItem audioEffect: SAIAudioEffect) {
        _logger.trace(audioEffect)
        
        if let view = _activatedEffectView, view.status.isPlaying || view.status.isProcessing {
            // 正在播放的时候需要停止
            _activatedEffect?.delegate = nil // 忽略任何错误和回调
            _activatedEffect?.stop()
            _player?.delegate = nil // 忽略任何错误和回调
            _player?.stop()
            
            _activatedEffectView?.status = .none
            
            // 如果是同一个view说明, 这是用户主动取消操作
            if audioEffectView === view {
                return
            }
        } 
        
        _activatedEffect = audioEffect
        _activatedEffectView = audioEffectView
        _playToolbar.confirmButton.isEnabled = false
        _simulateView.visibleCells.forEach {
            guard audioEffectView !== $0 else {
                return
            }
            $0.isSelected = false
        }
        
        audioEffectView.isSelected = true
        audioEffect.delegate = self
        audioEffect.process(at: _recordFileAtURL)
    }
    
    func audioEffectViewGetCurrentTime(_ audioEffectView: SAIAudioEffectView) -> TimeInterval {
        return _player?.currentTime ?? 0
    }
    func audioEffectViewGetProgress(_ audioEffectView: SAIAudioEffectView) -> CGFloat {
        return CGFloat((TimeInterval(_player?.currentTime ?? 0) + 0.2) / TimeInterval(_recordDuration))
    }
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumViewWillUpdateMeters: SAIAudioSpectrumMiniView) {
        _player?.updateMeters()
    }
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumViewDidUpdateMeters: SAIAudioSpectrumMiniView) {
    }
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumView: SAIAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float {
        return _player?.peakPower(forChannel: 0) ?? -160
    }
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumView: SAIAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float {
        return _player?.averagePower(forChannel: 0) ?? -160
    }
}

// MARK: - UICollectionViewDataSource, UICollectionViewDelegateFlowLayout

extension SAIAudioSimulateView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _supportEffects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? SAIAudioEffectView else {
            return
        }
        cell.effect = _supportEffects[indexPath.item]
        cell.delegate = self
        cell.isSelected = cell.effect === _activatedEffect
    }
}


// MARK: - SAIAudioEffect

extension SAIAudioSimulateView: SAIAudioEffectDelegate {
    
    func audioEffect(_ audioEffect: SAIAudioEffect, shouldStartProcessAt url: URL) -> Bool {
        _activatedEffectView?.status = .processing
        return true
    }
    func audioEffect(_ audioEffect: SAIAudioEffect, didStartProcessAt url: URL) {
        _logger.trace()
    }
    
    func audioEffect(_ audioEffect: SAIAudioEffect, didFinishProcessAt url: URL) {
        _logger.trace()
        
        _playToolbar.confirmButton.isEnabled = true
        _processedFileAtURL = url
        _activatedEffectView?.status = .processed
        
        // 进入播放状态
        _player = _makePlayer(url)
        _player?.play()
    }
    func audioEffect(_ audioEffect: SAIAudioEffect, didErrorOccur error: NSError) {
        _logger.trace()
        
        // TODO: 弹出提示窗
        _processedFileAtURL = nil
        _activatedEffectView?.status = .none
    }
}


// MARK: - SAIAudioPlayerDelegate

extension SAIAudioSimulateView: SAMAudioPlayerDelegate {
   
    public func audioPlayer(shouldPreparing audioPlayer: SAMedia.SAMAudioPlayer) -> Bool {
        _logger.trace()
        _activatedEffectView?.status = .waiting
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
        
        _activatedEffectView?.status = .playing
    }

    public func audioPlayer(didStop audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
        
        _activatedEffectView?.status = .none
    }

    public func audioPlayer(didInterruption audioPlayer: SAMedia.SAMAudioPlayer) {
        _logger.trace()
        
        _activatedEffectView?.status = .none
    }

    public func audioPlayer(didFinishPlaying audioPlayer: SAMedia.SAMAudioPlayer, successfully flag: Bool) {
        _logger.trace()
        
        _activatedEffectView?.status = .none
    }

    public func audioPlayer(didOccur audioPlayer: SAMedia.SAMAudioPlayer, error: Error?) {
        _logger.trace(error)
        
        updateStatus(.error(error?.localizedDescription ?? "Unknow error"))
        // TODO: 弹出提示窗
    }
}

// MARK: - SAIAudioRecorderDelegate

extension SAIAudioSimulateView: SAMAudioRecorderDelegate {
    
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
        DispatchQueue.main.async {
            guard self._recordButton.isHighlighted else {
                // 不能直接调用onCancel, 因为没有启动就没有失败
                return self.updateStatus(.none)
            }
            self._recorder?.record()
        }
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

extension SAIAudioSimulateView: SAIAudioStatusViewDelegate {
    
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
