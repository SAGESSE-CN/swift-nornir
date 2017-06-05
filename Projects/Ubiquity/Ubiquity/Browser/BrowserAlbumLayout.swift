//
//  BrowserAlbumLayout.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserAlbumLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        // must be attached to the collection view
        guard let collectionView = collectionView else {
            return
        }
        // recompute
        let rect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset)
        let (size, spacing) = BrowserAlbumLayout._itemSize(with: rect)
        
        // setup
        itemSize = size
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
        _invaildCenterIndexPath = collectionView.indexPathsForVisibleItems.reduce((nil, Int.max)) {
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
        guard let indexPath = _invaildCenterIndexPath else {
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
    
    private static func _itemSize(with rect: CGRect) -> (CGSize, CGFloat) {
        
        let column = trunc((rect.width + minimumItemSpacing) / (minimumItemSize.width + minimumItemSpacing))
        let width = trunc(((rect.width + minimumItemSpacing) / column - minimumItemSpacing) * 2) / 2
        let spacing = (rect.width - width * column) / (column - 1)
        
        return (.init(width: width, height: width), spacing)
    }
    
    static let minimumItemSpacing: CGFloat = 2
    static let minimumItemSize: CGSize = .init(width: 78, height: 78)
    
    static let thumbnailItemSize: CGSize = {
        
        let size = _itemSize(with: UIScreen.main.bounds).0
        let scale = UIScreen.main.scale
        
        return .init(width: size.width * scale, height: size.height * scale)
    }()
    
    private var _invaildCenterIndexPath: IndexPath?
}

