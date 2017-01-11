//
//  SAPToolbar.swift
//  SAC
//
//  Created by SAGESSE on 10/8/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc
public enum SAPToolbarContext: Int {
    case edit
    case preview
    case list
    case panel
}


open class SAPToolbar: UIToolbar {
    
    open override var items: [UIBarButtonItem]? {
        set {
            return setItems(newValue, animated: false)
        }
        get {
            return _items
        }
    }
    open override func setItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        guard (items ?? []) != (_items ?? []) else {
            return
        }
        _items = items
        _updateItems(items, animated: animated)
    }
    
    private func _updateItems(_ newValue: [UIBarButtonItem]?, animated: Bool) {
        let items: [UIBarButtonItem]? = newValue?.map {
            guard let item = $0 as? SAPButtonBarItem else {
                return $0
            }
            return item.toBarItem()
        }
        super.setItems(items, animated: animated)
    }
    
    private var _items: [UIBarButtonItem]?
}
