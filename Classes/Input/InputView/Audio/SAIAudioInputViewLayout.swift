//
//  SAIAudioInputViewLayout.swift
//  SAC
//
//  Created by SAGESSE on 9/17/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIAudioInputViewLayout: UICollectionViewLayout {
    
    var lastIndexPath: IndexPath?
    
    override var collectionViewContentSize: CGSize {
        if let size = _cacheContentSize {
            return size
        }
        guard let collectionView = collectionView else {
            return .zero
        }
        let width = collectionView.frame.width
        let count = collectionView.numberOfItems(inSection: 0)
        let size = CGSize(width: width * CGFloat(count), height: 0)
        _cacheContentSize = size
        return size
    }
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            lastIndexPath = collectionView?.indexPathsForVisibleItems.first
            return true
        }
        return false
    }
    
    override func prepare() {
        super.prepare()
        _cacheContentSize = nil
        _cacheLayoutAttributes = nil
    }
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if let attributes = _cacheLayoutAttributes {
            return attributes
        }
        guard let collectionView = collectionView else {
            return []
        }
        _logger.debug("recalc in rect: \(rect)")
        var allAttributes: [UICollectionViewLayoutAttributes] = []
        
        let width = collectionView.frame.width
        let height = collectionView.frame.height
        
        (0 ..< collectionView.numberOfItems(inSection: 0)).forEach { item in
            let idx = IndexPath(item: item, section: 0)
            let attributes = layoutAttributesForItem(at: idx) ?? UICollectionViewLayoutAttributes(forCellWith: idx)
            
            attributes.frame = CGRect(x: width * CGFloat(item), y: 0, width: width, height: height)
            allAttributes.append(attributes)
        }
        
        _cacheLayoutAttributes = allAttributes
        return allAttributes
    }
    
    
    private var _cacheContentSize: CGSize?
    private var _cacheLayoutAttributes: [UICollectionViewLayoutAttributes]?
}
