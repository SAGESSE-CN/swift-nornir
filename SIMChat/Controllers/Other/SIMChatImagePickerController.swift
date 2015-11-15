//
//  SIMChatImagePickerController.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

import Photos
import AssetsLibrary

class SIMChatImagePickerController: UINavigationController {
    
    /// 初始化
    convenience init(){
        self.init(nibName: nil, bundle: nil)
    }
    /// 初始化
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        self.rootViewController = AlbumsViewController()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }
    /// 反序列化
    required init?(coder aDecoder: NSCoder) {
        self.rootViewController = AlbumsViewController()
        super.init(coder: aDecoder)
        
        // 可能需要直接转到指定页面
        self.viewControllers = [self.rootViewController]
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        assert(rootViewController != nil, "root must created!")
    }
    
    private var rootViewController: AlbumsViewController!
}

