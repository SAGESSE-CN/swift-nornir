//
//  BrowserListLayout.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserListLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        // must be attached to the collection view
        guard let collectionView = collectionView else {
            return
        }
        // recompute
        let rect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset)
        
        let minimumSpacing = CGFloat(2)
        let minimumItemSize = CGSize(width: 78, height: 78)
        
        let column = trunc((rect.width + minimumSpacing) / (minimumItemSize.width + minimumSpacing))
        let width = trunc(((rect.width + minimumSpacing) / column - minimumSpacing) * 2) / 2
        let spacing = (rect.width - width * column) / (column - 1)
        
        // setup
        itemSize = CGSize(width: width, height: width)
        minimumLineSpacing = spacing
        minimumInteritemSpacing = spacing
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard super.shouldInvalidateLayout(forBoundsChange: newBounds) else {
            return false
        }
        guard let collectionView = collectionView else {
            return false
        }
        let location = collectionView.convert(collectionView.center, from: collectionView.superview)
        // get center index path
        invaildCenterIndexPath = collectionView.indexPathsForVisibleItems.reduce((nil, Int.max)) {
            // get the cell center
            guard let center = collectionView.layoutAttributesForItem(at: $1)?.center else {
                return $0
            }
            // compute the cell to point the disance
            let disance = Int(fabs(sqrt(pow((center.x - location.x), 2) + pow((center.y - location.y), 2))))
            // if the cell is more close to update it
            guard disance < $0.1 else {
                return $0
            }
            return ($1, disance)
        }.0
        // update layout 
        invalidateLayout()
        
        return true
    }
    
    override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
        let offset = super.targetContentOffset(forProposedContentOffset: proposedContentOffset)
        // only the process screen rotation
        guard let indexPath = invaildCenterIndexPath else {
            return offset
        }
        // must get the center on new layout
        guard let collectionView = collectionView, let location = collectionView.layoutAttributesForItem(at: indexPath)?.center else {
            return offset
        }
        let frame = collectionView.frame
        let size = collectionViewContentSize
        let edg = collectionView.contentInset
        
        // check top boundary & bottom boundary
        return .init(x: offset.x, y: min(max(location.y - frame.midY, -edg.top),  size.height - frame.maxY + edg.bottom))
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
    
    private var invaildCenterIndexPath: IndexPath?
}
