//
//  NavigationController.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/16/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class NavigationController: UINavigationController {
    
    override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}
