//
//  PhotoLibrary.swift
//  Ubiquity-Example
//
//  Created by SAGESSE on 5/23/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@testable import Ubiquity

class PhotoLibraryController: UITabBarController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    private func _setup() {
        
        let library = PhotoLibrary()
        
        let vc1 = Ubiquity.BrowserAlbumZoomableController(library: library)
        let vc2 = Ubiquity.BrowserAlbumListController(library: library)
        
        viewControllers = [
            UINavigationController(rootViewController: vc2),
            UINavigationController(rootViewController: vc1),
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
}
