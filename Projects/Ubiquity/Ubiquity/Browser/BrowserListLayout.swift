//
//  BrowserListLayout.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserListLayout: UICollectionViewFlowLayout {
    
    internal override func prepare() {
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
    
    internal override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        logger.trace(itemIndexPath)
        return super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
    }
    internal override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        logger.trace(itemIndexPath)
        return super.finalLayoutAttributesForDisappearingItem(at: itemIndexPath)
    }
}
