//
//  SAIAudioEffectView.swift
//  SAC
//
//  Created by SAGESSE on 9/19/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol SAIAudioEffectViewDelegate: NSObjectProtocol {
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, shouldSelectItem audioEffect: SAIAudioEffect) -> Bool
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, didSelectItem audioEffect: SAIAudioEffect)
    
    func audioEffectViewGetCurrentTime(_ audioEffectView: SAIAudioEffectView) -> TimeInterval
    func audioEffectViewGetProgress(_ audioEffectView: SAIAudioEffectView) -> CGFloat
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumView: SAIAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumView: SAIAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float
    
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumViewWillUpdateMeters: SAIAudioSpectrumMiniView)
    func audioEffectView(_ audioEffectView: SAIAudioEffectView, spectrumViewDidUpdateMeters: SAIAudioSpectrumMiniView)
    
}

internal class SAIAudioEffectView: UICollectionViewCell {
    
    weak var delegate: SAIAudioEffectViewDelegate?
    
    var status: SAIAudioStatus = .none {
        willSet {
            _updateStatus(newValue)
        }
    }
    var effect: SAIAudioEffect? {
        willSet {
            _updateEffect(newValue)
        }
    }
    
    override var isSelected: Bool {
        set {
            _titleButton.isSelected = newValue
            super.isSelected = newValue
        }
        get {
            return super.isSelected 
        }
    }
    
    func onTap(_ sender: Any) {
        guard let effect = effect else {
            return
        }
        if delegate?.audioEffectView(self, shouldSelectItem: effect) ?? true {
            delegate?.audioEffectView(self, didSelectItem: effect)
        }
    }
    
    private func _updateStatus(_ newValue: SAIAudioStatus) {
        _logger.trace(newValue)
        
        switch newValue {
        case .none:
            
            _tipsLabel.isHidden = true
            
            _playButton.progress = 0
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _foregroundView.isHidden = true
            
        case .waiting:
            
            _tipsLabel.text = "等待中"
            _tipsLabel.isHidden = false
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
            _foregroundView.isHidden = false
            
        case .processing:
            
            _tipsLabel.text = "处理中"
            _tipsLabel.isHidden = false
            
            _spectrumView.isHidden = true
            _spectrumView.stopAnimating()
            
            _activityIndicatorView.isHidden = false
            _activityIndicatorView.startAnimating()
            
            _foregroundView.isHidden = false
            
        case .playing:
            
            _tipsLabel.text = "00:00"
            _tipsLabel.isHidden = false
            
            _activityIndicatorView.isHidden = true
            _activityIndicatorView.stopAnimating()
            
            _spectrumView.isHidden = false
            _spectrumView.startAnimating()
            
            _foregroundView.isHidden = false
            
        default:
            break
        }
        
    }
    
    private func _updateEffect(_ newValue: SAIAudioEffect?) {
        
        _backgroundView.image = newValue?.image
        _titleButton.setTitle(newValue?.title, for: .normal)
        //_playButton.setBackgroundImage(newValue?.image, for: .normal)
    }
    
    private func _init() {
        _logger.trace()
        
        let hcolor = UIColor(colorLiteralRed: 0x18 / 255.0, green: 0xb4 / 255.0, blue: 0xed / 255.0, alpha: 1)
        
        
        _backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        _foregroundView.isHidden = true
        _foregroundView.translatesAutoresizingMaskIntoConstraints = false
        _foregroundView.image = UIImage.sai_init(named: "keyboard_audio_simulate_effect_select")
        
        _playButton.translatesAutoresizingMaskIntoConstraints = false
        _playButton.progress = 0
        _playButton.progressColor = hcolor
        _playButton.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
        _playButton.setBackgroundImage(UIImage.sai_init(named: "keyboard_audio_simulate_effect_press"), for: .highlighted)
        
        _titleButton.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        _titleButton.setTitleColor(.black, for: .normal)
        _titleButton.setTitleColor(.white, for: .selected)
        _titleButton.setBackgroundImage(UIImage.sai_init(named: "keyboard_audio_simulate_text_select"), for: .selected)
        _titleButton.isUserInteractionEnabled = false
        _titleButton.translatesAutoresizingMaskIntoConstraints = false
        _titleButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8)
        
        _tipsLabel.isHidden = true
        _tipsLabel.translatesAutoresizingMaskIntoConstraints = false
        _tipsLabel.font = UIFont.systemFont(ofSize: 12)
        _tipsLabel.text = "准备中"
        _tipsLabel.textColor = .white
        
        _spectrumView.color = .white
        _spectrumView.dataSource = self
        _spectrumView.translatesAutoresizingMaskIntoConstraints = false
        _spectrumView.isHidden = true
        
        _activityIndicatorView.isHidden = true
        _activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(_backgroundView)
        addSubview(_titleButton)
        addSubview(_foregroundView)
        addSubview(_playButton)
        
        addSubview(_spectrumView)
        addSubview(_activityIndicatorView)
        addSubview(_tipsLabel)
        
        addConstraint(_SAILayoutConstraintMake(_backgroundView, .top, .equal, self, .top))
        addConstraint(_SAILayoutConstraintMake(_backgroundView, .centerX, .equal, self, .centerX))
        
        addConstraint(_SAILayoutConstraintMake(_foregroundView, .top, .equal, _backgroundView, .top))
        addConstraint(_SAILayoutConstraintMake(_foregroundView, .left, .equal, _backgroundView, .left))
        addConstraint(_SAILayoutConstraintMake(_foregroundView, .right, .equal, _backgroundView, .right))
        addConstraint(_SAILayoutConstraintMake(_foregroundView, .bottom, .equal, _backgroundView, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_playButton, .top, .equal, _backgroundView, .top))
        addConstraint(_SAILayoutConstraintMake(_playButton, .left, .equal, _backgroundView, .left))
        addConstraint(_SAILayoutConstraintMake(_playButton, .right, .equal, _backgroundView, .right))
        addConstraint(_SAILayoutConstraintMake(_playButton, .bottom, .equal, _backgroundView, .bottom))
        
        addConstraint(_SAILayoutConstraintMake(_titleButton, .top, .equal, _backgroundView, .bottom, 4))
        addConstraint(_SAILayoutConstraintMake(_titleButton, .centerX, .equal, _backgroundView, .centerX))
        
        // status view
        
        let size = _tipsLabel.sizeThatFits(CGSize(width: .max, height: .max))
        
        addConstraint(_SAILayoutConstraintMake(_spectrumView, .centerX, .equal, self, .centerX))
        addConstraint(_SAILayoutConstraintMake(_spectrumView, .centerY, .equal, self, .centerY, -(size.height + 4)))
        addConstraint(_SAILayoutConstraintMake(_activityIndicatorView, .centerX, .equal, _spectrumView, .centerX))
        addConstraint(_SAILayoutConstraintMake(_activityIndicatorView, .centerY, .equal, _spectrumView, .centerY))
        addConstraint(_SAILayoutConstraintMake(_tipsLabel, .top, .equal, _spectrumView, .bottom, 4))
        addConstraint(_SAILayoutConstraintMake(_tipsLabel, .centerX, .equal, _spectrumView, .centerX))
    }
    
    fileprivate lazy var _playButton: SAIAudioPlayButton = SAIAudioPlayButton()
    
    fileprivate lazy var _backgroundView: UIImageView = UIImageView()
    fileprivate lazy var _foregroundView: UIImageView = UIImageView()
    fileprivate lazy var _titleButton: UIButton = UIButton()
    
    fileprivate lazy var _tipsLabel: UILabel = UILabel()
    fileprivate lazy var _spectrumView: SAIAudioSpectrumMiniView = SAIAudioSpectrumMiniView()
    fileprivate lazy var _activityIndicatorView: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .white)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
}

extension SAIAudioEffectView: SAIAudioSpectrumMiniViewDataSource {
    
    func spectrumMiniView(willUpdateMeters spectrumMiniView: SAIAudioSpectrumMiniView) {
        _updateTime()
        delegate?.audioEffectView(self, spectrumViewWillUpdateMeters: spectrumMiniView)
    }
    func spectrumMiniView(didUpdateMeters spectrumMiniView: SAIAudioSpectrumMiniView) {
        delegate?.audioEffectView(self, spectrumViewDidUpdateMeters: spectrumMiniView)
    }
    
    func spectrumMiniView(_ spectrumMiniView: SAIAudioSpectrumMiniView, peakPowerFor channel: Int) -> Float {
        return delegate?.audioEffectView(self, spectrumView: spectrumMiniView, peakPowerFor: channel) ?? -160
    }
    func spectrumMiniView(_ spectrumMiniView: SAIAudioSpectrumMiniView, averagePowerFor channel: Int) -> Float {
        return delegate?.audioEffectView(self, spectrumView: spectrumMiniView, averagePowerFor: channel) ?? -160
    }
    
    private func _updateTime() {
        guard status.isPlaying else {
            return
        }
        let time = delegate?.audioEffectViewGetCurrentTime(self) ?? 0
        let progress = delegate?.audioEffectViewGetProgress(self) ?? 0
        
        _tipsLabel.text = String(format: "%0d:%02d", Int(time) / 60, Int(time) % 60)
        _playButton.setProgress(progress, animated: true)
    }
}
