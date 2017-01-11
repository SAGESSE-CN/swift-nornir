//
//  SAPPreviewerLayout.swift
//  SAC
//
//  Created by SAGESSE on 10/10/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPPreviewerLayout: UICollectionViewFlowLayout {
    
    var lastIndexPath: IndexPath?
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            lastIndexPath = collectionView?.indexPathsForVisibleItems.first
            _insertIndexPath = lastIndexPath
            _removeIndexPath = lastIndexPath
            invalidateLayout()
            return true
        }
        return false
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if _insertIndexPath == itemIndexPath {
            _insertIndexPath = nil
            return layoutAttributesForItem(at: itemIndexPath)
        }
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if _removeIndexPath == itemIndexPath {
            _removeIndexPath = nil
            return layoutAttributesForItem(at: itemIndexPath)
        }
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    
    private var _insertIndexPath: IndexPath?
    private var _removeIndexPath: IndexPath?
}
