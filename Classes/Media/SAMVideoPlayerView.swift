//
//  SAMVideoPlayerView.swift
//  SAMedia
//
//  Created by SAGESSE on 27/10/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import AVFoundation

///
/// 视频播放器视图
///
open class SAMVideoPlayerView: UIView {
    
    open override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    public init(player: SAMVideoPlayer) {
        super.init(frame: .zero)
        self.player = player
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    open var player: SAMVideoPlayer? {
        set {
            if let layer = layer as? AVPlayerLayer {
                layer.player = newValue?.player
            }
            return _player = newValue
        }
        get {
            return _player
        }
    }
    
    private var _player: SAMVideoPlayer?
}
