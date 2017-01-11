//
//  SAPNavigationBar.swift
//  SAC
//
//  Created by SAGESSE on 10/9/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc
internal protocol SAPNavigationBarDelegate: UINavigationBarDelegate {
    
    @objc optional func sap_navigationBar(_ navigationBar: SAPNavigationBar, shouldPop item: UINavigationItem) -> Bool
    @objc optional func sap_navigationBar(_ navigationBar: SAPNavigationBar, didPop item: UINavigationItem)
    
}

internal class SAPNavigationBar: UINavigationBar {
    
    override func popItem(animated: Bool) -> UINavigationItem? {
        if let item = self.topItem {
            guard _delegate?.sap_navigationBar?(self, shouldPop: item) ?? true else {
                return nil
            }
            let oitem = super.popItem(animated: animated)
            _delegate?.sap_navigationBar?(self, didPop: item)
            return oitem
        }
        return super.popItem(animated: animated)
    }
    
    private weak var _delegate: SAPNavigationBarDelegate? {
        return delegate as? SAPNavigationBarDelegate
    }
}
