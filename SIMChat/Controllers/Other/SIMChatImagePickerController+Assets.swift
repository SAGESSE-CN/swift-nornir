//
//  SIMChatAssetsViewController.swift
//  SIMChat
//
//  Created by sagesse on 11/15/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

extension SIMChatImagePickerController {
    /// 图片控制器
    class AssetsViewController: UICollectionViewController {
        
        init(album: SIMChatImagePickerAlbum) {
            self.album = album
            super.init(collectionViewLayout: UICollectionViewFlowLayout())
        }
        required init?(coder aDecoder: NSCoder) {
            self.album = nil
            super.init(coder: aDecoder)
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            assert(album != nil, "Album can't empty!")
            
            self.title = album?.title
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "onCancel:")
            
            // Register cell classes
            self.collectionView?.backgroundColor = UIColor.whiteColor()
            self.collectionView?.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: "Asset")
        }
        
        // MARK: UICollectionViewDataSource
        
        override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return album?.count ?? 0
        }
        
        override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("Asset", forIndexPath: indexPath)
            
            cell.backgroundColor = UIColor.orangeColor()
            
            return cell
        }
        
        // ..
        private var album: SIMChatImagePickerAlbum?
    }
}


// MARK: - Event
extension SIMChatImagePickerController.AssetsViewController {
    /// 取消
    private dynamic func onCancel(sender: AnyObject) {
        SIMLog.trace()
        self.navigationController?.dismissViewControllerAnimated(true, completion: nil)
    }
}