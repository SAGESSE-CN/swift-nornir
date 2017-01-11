//
//  SAPPickerViewLayout.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAPPickerViewLayout: UICollectionViewFlowLayout {
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        if collectionView?.frame.width != newBounds.width {
            invalidateLayout()
            return true
        }
        return false
    }
}
