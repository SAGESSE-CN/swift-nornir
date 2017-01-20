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
        _commonInit()
    }
    public override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        _commonInit()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
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
