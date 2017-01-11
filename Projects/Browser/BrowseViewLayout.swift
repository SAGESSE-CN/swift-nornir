//
//  BrowseViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/14/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

class BrowseViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        super.prepare()
        guard let collectionView = collectionView else {
            return
        }
        // 重新计算
        let rect = UIEdgeInsetsInsetRect(collectionView.bounds, collectionView.contentInset)
        
        let minimumSpacing = CGFloat(2)
        let minimumItemSize = CGSize(width: 78, height: 78)
        
        let column = trunc((rect.width + minimumSpacing) / (minimumItemSize.width + minimumSpacing))
        let width = trunc(((rect.width + minimumSpacing) / column - minimumSpacing) * 2) / 2
        let spacing = (rect.width - width * column) / (column - 1)
        
        self.itemSize = CGSize(width: width, height: width)
        self.minimumLineSpacing = spacing
        self.minimumInteritemSpacing = spacing
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
}
