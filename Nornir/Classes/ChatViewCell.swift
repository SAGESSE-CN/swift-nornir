//
//  ChatViewCell.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ChatViewCell: UICollectionViewCell {
    
    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let newLayoutAttributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        newLayoutAttributes.frame.size.height = 120
        return newLayoutAttributes
    }
}
