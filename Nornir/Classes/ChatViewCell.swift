//
//  ChatViewCell.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class ChatViewCell: UICollectionViewCell {
    
    open override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return presenter.map {
            let layout = $0.preferredLayoutFitting(at: layoutAttributes.indexPath)
            let newLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
            newLayoutAttributes.frame.size.height = layout.box.height
            return newLayoutAttributes
        } ?? layoutAttributes
    }
    
    internal weak var presenter: ChatViewPresenter?
}
