//
//  ChatViewCell.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class ChatViewCell: UICollectionViewCell {
    
    open override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        
        // ...
        guard let layoutAttributes = layoutAttributes as? ChatViewLayoutAttributes else {
            return
        }
        logger.trace?.write(layoutAttributes)
        
//        let transform = CGAffineTransform.identity//(translationX: layoutAttributes.frame.width, y: 0).scaledBy(x: -1, y: 1)
        
        _preferredLayout(at: layoutAttributes.indexPath).map {
            _setup(with: $0, transform: transform)
        }
        
    }

    func dequeueReusableView(with identifier: String) -> UIView? {
        
        if let view = _views[identifier] {
            return view
        }
        
        let view = UIView()
        
        view.layer.borderColor = #colorLiteral(red: 0.10, green: 0.41, blue: 1, alpha: 0.85)
        view.layer.borderWidth = 1 / UIScreen.main.scale
        view.layer.backgroundColor = #colorLiteral(red: 0.10, green: 0.41, blue: 1, alpha: 0.15)
        
        _views[identifier] = view
        
        return view
    }
    
    private var _views: [String: UIView] = [:]
    
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return _preferredLayout(at: layoutAttributes.indexPath).map {
            let newLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            newLayoutAttributes.frame.size.height = $0.box.height
            return newLayoutAttributes
        } ?? layoutAttributes
    }
    
    private func _preferredLayout(at indexPath: IndexPath) -> ComputedCustomLayout? {
        return presenter?.preferredLayoutFitting(at: indexPath)
    }
    
    private func _setup(with layout: ComputedCustomLayout, transform: CGAffineTransform) {
        
        layout.identifier.map {
            dequeueReusableView(with: $0).map {
                
                if contentView != $0.superview {
                    contentView.addSubview($0)
                }
                
                let nframe = layout.frame//.applying(transform)
                if $0.frame != nframe {
                    $0.frame = nframe
                }
                
                if $0.isHidden {
                    $0.isHidden = false
                }
            }
        }
        
        layout.children.forEach {
            _setup(with: $0, transform: transform)
        }
    }
    
    internal weak var presenter: ChatViewPresenter?
}
