//
//  BrowseDetailViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/15/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseDetailViewLayout: UICollectionViewFlowLayout {
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard super.shouldInvalidateLayout(forBoundsChange: newBounds) else {
            return false
        }
        invalidateLayout()
        return true
    }

    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
}
