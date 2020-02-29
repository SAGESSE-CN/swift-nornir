//
//  SAIAudioStatusView.swift
//  SAC
//
//  Created by SAGESSE on 9/18/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc
internal protocol SAIAudioStatusViewDelegate: NSObjectProtocol {
    
    
    func statusView(_ statusView: SAIAudioStatusView, spectrumView: SAIAudioSpectrumView, peakPowerFor channel: Int) -> Float
    func statusView(_ statusView: SAIAudioStatusView, spectrumView: SAIAudioSpectrumView, averagePowerFor channel: Int) -> Float
    
    @objc optional func statusView(_ statusView: SAIAudioStatusView, spectrumViewWillUpdateMeters: SAIAudioSpectrumView)
    @objc optional func statusView(_ statusView: SAIAudioStatusView, spectrumViewDidUpdateMeters: SAIAudioSpectrumView)
}

internal class SAIAudioStatusView: UIView {
    
    var textLabel: UILabel {
        return _textLabel
    }
    var spectrumView: SAIAudioSpectrumView {
        return _spectrumView
    }
    var activityIndicatorView: UIActivityIndicatorView {
        return _activityIndicatorView
    }
    
    var font: UIFont? {
        set { return _textLabel.font = newValue }
        get { return _textLabel.font }
    }
    
    var text: String? {
        willSet {
            _updateText(newValue ?? "")
        }
    }
    var textColor: UIColor? {
        set { return _textLabel.textColor = newValue }
        get { return _textLabel.textColor }
    }
    
    var status: SAIAudioStatus = .none {
        willSet {
            _updateStatus(newValue, status)
        }
    }
    
    weak var delegate: SAIAudioStatusViewDelegate?
    
    private func _updateStatus(_ newValue: SAIAudioStatus, _ oldValue: SAIAudioStatus) {
        switch newValue {
        case .none: // 默认状态
            
            _updateText("按住说话")
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
        case .waiting: // 等待状态
            
            _updateText("准备中", _activityIndicatorView.bounds)
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
        case .processing: // 处理状态
            
            _updateText("处理中...", _activityIndicatorView.bounds)
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
        case .playing: // 播放状态
            
            //_updateText("00:00")
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
        case .recording: // 录音状态
            
            _updateText("00:00")
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
        case .processed: // 试听状态
            
            //_updateText("00:00")
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = false
            _spectrumView.stopAnimating()
            
        case .error(let err): // 错误状态
            
            _updateText(err)
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
        }
    }
    private func _updateText(_ str: String, _ bounds: CGRect? = nil) {
        if let bounds = bounds {
            let at = NSTextAttachment()
            at.bounds = bounds.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: bounds.height, right: -8))
            let mas = NSMutableAttributedString(string: str)
            mas.insert(NSAttributedString(attachment: at), at: 0)
            
            _textLabel.attributedText = mas
        } else {
            _textLabel.text = str
        }
    }
    private func _init() {
        
        _textLabel.text = "按住说话"
        _textLabel.font = UIFont.systemFont(ofSize: 16)
        _textLabel.textColor = .gray
        _textLabel.translatesAutoresizingMaskIntoConstraints = false
        
        _activityIndicatorView.isHidden = true
        _activityIndicatorView.hidesWhenStopped = true
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        _spectrumView.isHidden = true
        _spectrumView.dataSource = self
        _spectrumView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_spectrumView)
        addSubview(_activityIndicatorView)
        addSubview(_textLabel)
        
        addConstraint(_SAILayoutConstraintMake(_textLabel, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_textLabel, .left, .equal, self, .left))
        addConstraint(_SAILayoutConstraintMake(_textLabel, .right, .equal, self, .right))
        addConstraint(_SAILayoutConstraintMake(_textLabel, .bottom, .equal, self, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_spectrumView, .centerX, .equal, self, .centerX))
        addConstraint(_SAILayoutConstraintMake(_spectrumView, .centerY, .equal, self, .centerY))
        
        addConstraint(_SAILayoutConstraintMake(_activityIndicatorView, .left, .equal, _textLabel, .left))
        addConstraint(_SAILayoutConstraintMake(_activityIndicatorView, .centerY, .equal, _textLabel, .centerY))
    }
    
    fileprivate lazy var _textLabel: UILabel = UILabel()
    fileprivate lazy var _spectrumView: SAIAudioSpectrumView = SAIAudioSpectrumView()
    fileprivate lazy var _activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(style: .gray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAIAudioStatusView: SAIAudioSpectrumViewDataSource {
    
    func spectrumView(willUpdateMeters spectrumView: SAIAudioSpectrumView) {
        delegate?.statusView?(self, spectrumViewWillUpdateMeters: spectrumView)
    }
    
    func spectrumView(_ spectrumView: SAIAudioSpectrumView, peakPowerFor channel: Int) -> Float {
        return delegate?.statusView(self, spectrumView: spectrumView, peakPowerFor: channel) ?? -160
    }
    func spectrumView(_ spectrumView: SAIAudioSpectrumView, averagePowerFor channel: Int) -> Float {
        return delegate?.statusView(self, spectrumView: spectrumView, averagePowerFor: channel) ?? -160
    }
    
    func spectrumView(didUpdateMeters spectrumView: SAIAudioSpectrumView) {
        delegate?.statusView?(self, spectrumViewDidUpdateMeters: spectrumView)
    }
}
