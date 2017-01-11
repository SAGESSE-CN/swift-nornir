//
//  SACMessageImageContentView.swift
//  SAChat
//
//  Created by sagesse on 05/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class SACMessageImageContentView: UIImageView, SACMessageContentViewType {
    
    public override init(image: UIImage?) {
        super.init(image: image)
        _logger.trace()
        _commonInit()
    }
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        _logger.trace()
        _commonInit()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _logger.trace()
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _logger.trace()
        _commonInit()
    }
    deinit {
        _logger.trace()
    }
    
    open func apply(_ message: SACMessageType) {
        guard let content = message.content as? SACMessageImageContent else {
            return
        }
        image = content.image
    }
    
    private func _commonInit() {
        
        layer.cornerRadius = 14
        layer.masksToBounds = true
    }
}
