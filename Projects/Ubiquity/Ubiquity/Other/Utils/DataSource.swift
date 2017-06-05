//
//  DataSource.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/24/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class DataSource {
    
    init(_ collection: Collection) {
        _collections = [collection]
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
        return _collections.ub_get(at: indexPath.section)?.ub_asset(at: indexPath.item)
    }
    
    private var _collections: Array<Collection>
}

internal class DataSourceOptions: RequestOptions {
    
    init(progressHandler: RequestProgressHandler? = nil) {
        self.progressHandler = progressHandler
    }
    
    /// if necessary will download the image from reomte
    var isNetworkAccessAllowed: Bool = true
    
    /// provide caller a way to be told how much progress has been made prior to delivering the data when it comes from remote.
    var progressHandler: RequestProgressHandler? = nil
}
