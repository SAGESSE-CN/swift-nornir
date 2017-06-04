//
//  Source.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/24/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class Source {
    
    init(_ collection: Collection) {
        //_collections = [collection]
        _collections = (0 ..< 30).map { _ in collection }
    }
    init(_ collections: Array<Collection>) {
        _collections = collections
    }
    
    var title: String? {
        return _collections.first?.ub_localizedTitle
    }
    
    var numberOfSections: Int {
        return _collections.count
    }
    func numberOfItems(inSection section: Int) -> Int {
        return _collections.ub_get(at: section)?.ub_assetCount ?? 0
    }
    
    func asset(at indexPath: IndexPath) -> Asset? {
        //return _collections.ub_get(at: /*indexPath.section*/0)?.ub_asset(at: /*indexPath.item*/0)
        return _collections.ub_get(at: /*indexPath.section*/0)?.ub_asset(at: indexPath.item)
    }
    
    private var _collections: Array<Collection>
}
