//
//  SAPBrowseableContentView.swift
//  SAPhotos
//
//  Created by SAGESSE on 11/5/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import SAMedia

internal class SAPBrowseableContentView: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
    
    var image: Any? {
        set {
            let oldValue = _imageView.image
            let newValue = newValue as? UIImage
            guard newValue != oldValue else {
                return // no change
            }
            // 更新图片和背景色
            _imageView.setImage(newValue, animated: !CATransaction.disableActions() && UIView.areAnimationsEnabled)
            _imageView.backgroundColor = _backgroundColor(with: newValue)
        }
        get {
            return _imageView.image 
        }
    }
    
    
    
    var player: SAMVideoPlayer? {
        set {
            if let newValue = newValue {
                
                let view = _playerView ?? SAMVideoPlayerView(player: newValue)
                
                view.player = newValue
                view.frame = bounds
                view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                addSubview(view)
                
                _playerView = view
                
            } else {
                _playerView?.removeFromSuperview()
                _playerView = nil
            }
        }
        get {
            return _playerView?.player
        }
        
    }
    
    var orientation: UIImage.Orientation = .up {
        willSet {
            guard newValue != orientation else {
                return
            }
            // 删除图片变更动画
            //_imageView.layer.removeAnimation(forKey: "image")
            
            _imageView.transform = CGAffineTransform(rotationAngle: _angle(orientation: newValue))
            _imageView.frame = bounds
            
            _playerView?.transform = CGAffineTransform(rotationAngle: _angle(orientation: newValue))
            _playerView?.frame = bounds
        }
    }
    
    private func _backgroundColor(with image: UIImage?) -> UIColor {
        guard image == nil else {
            return UIColor.clear
        }
        return UIColor(white: 0.94, alpha: 1)
    }
    
    private func _angle(orientation: UIImage.Orientation) -> CGFloat {
        switch orientation {
        case .up, .upMirrored:  return 0 * CGFloat(M_PI_2)
        case .right, .rightMirrored: return 1 * CGFloat(M_PI_2)
        case .down, .downMirrored: return 2 * CGFloat(M_PI_2)
        case .left, .leftMirrored: return 3 * CGFloat(M_PI_2)
        }
    }
    
    private func _init() {
        
        _imageView.frame = bounds
        _imageView.contentMode = .scaleAspectFill
        _imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _imageView.backgroundColor = _backgroundColor(with: nil)
        
        addSubview(_imageView)
    }
    
    private var _player: SAMPlayerProtocol?
    private var _playerView: SAMVideoPlayerView?
    
    private lazy var _imageView: UIImageView = UIImageView()
}
