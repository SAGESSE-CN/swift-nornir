//
//  BrowserDetailLayout.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserDetailLayout: UICollectionViewFlowLayout {
    
    internal override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard super.shouldInvalidateLayout(forBoundsChange: newBounds) else {
            return false
        }
        invaildIndexPath = collectionView?.indexPathsForVisibleItems.first
        invalidateLayout()
        return true
    }
    
    internal override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let offset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        // if cell is currently being displayed
        guard let collectionView = collectionView, let indexPath = invaildIndexPath else {
            return offset
        }
        // must, send to front
        collectionView.visibleCells.reversed().forEach {
            collectionView.bringSubview(toFront: $0)
        }
        // adjust x
        return .init(x: CGFloat(indexPath.item) * collectionView.bounds.width, y: offset.y)
    }
    
    internal override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        // clear invaild index path on collection view update animation
        invaildIndexPath = nil
        super.prepare(forCollectionViewUpdates: updateItems)
    }

    internal override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        logger.trace(itemIndexPath)
        // special handling of update operations
        guard invaildIndexPath == itemIndexPath else {
            // use the original method
            return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        }
        // ignore any animation
        return layoutAttributesForItem(at: itemIndexPath)
    }
    internal override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        logger.trace(itemIndexPath)
        // special handling of update operations 
        guard invaildIndexPath == itemIndexPath else {
            // use the original method
            return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
        }
        // ignore any animation
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
    private var invaildIndexPath: IndexPath?
}
