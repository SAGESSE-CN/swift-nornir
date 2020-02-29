//
//  SAPBrowser.swift
//  SAC
//
//  Created by SAGESSE on 9/21/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

open class SAPBrowser: UIViewController {
//    
////    open weak var delegate: SAPPreviewerDelegate?
////    open weak var dataSource: SAPPreviewerDataSource?
//    
//    open override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        title = "Browser"
//        automaticallyAdjustsScrollViewInsets = false
//        
//        view.backgroundColor = .black
//        
//        let ts: CGFloat = 20
//        
//        _contentViewLayout.scrollDirection = .horizontal
//        _contentViewLayout.minimumLineSpacing = ts * 2
//        _contentViewLayout.minimumInteritemSpacing = ts * 2
//        _contentViewLayout.headerReferenceSize = CGSize(width: ts, height: 0)
//        _contentViewLayout.footerReferenceSize = CGSize(width: ts, height: 0)
//        
//        _contentView.frame = view.bounds.inset(by: UIEdgeInsets(top: 0, left: -ts, bottom: 0, right: -ts))
//        _contentView.backgroundColor = .clear
//        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        _contentView.showsVerticalScrollIndicator = false
//        _contentView.showsHorizontalScrollIndicator = false
//        _contentView.scrollsToTop = false
//        _contentView.allowsSelection = false
//        _contentView.allowsMultipleSelection = false
//        _contentView.isPagingEnabled = true
//        _contentView.register(SAPPreviewerCell.self, forCellWithReuseIdentifier: "Item")
//        _contentView.dataSource = self
//        _contentView.delegate = self
//        //_contentView.isDirectionalLockEnabled = true
//        //_contentView.isScrollEnabled = false
//        
//        view.addSubview(_contentView)
//    }
//    
//    open override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        
//        _logger.trace()
//        
//        navigationController?.isNavigationBarHidden = false
//        navigationController?.isToolbarHidden = false
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
//    }
//    open override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        
//        _logger.trace()
//        
//        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
//    }
//    
//    fileprivate lazy var _contentViewLayout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
//    fileprivate lazy var _contentView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: self._contentViewLayout)
//    
//    fileprivate var _allLoader: [Int: SAPhotoLoader] = [:]
//}
//
//extension SAPBrowser: SAPBrowserViewDelegate {
//    
//    func browserView(_ browserView: SAPBrowserView, didTapWith sender: AnyObject) {
//        _logger.trace()
//        
//        let isHidden = navigationController?.isNavigationBarHidden ?? false
//        
//        navigationController?.navigationBar.isUserInteractionEnabled = isHidden
//        navigationController?.toolbar.isUserInteractionEnabled = isHidden
//        navigationController?.setNavigationBarHidden(!isHidden, animated: true)
//        navigationController?.setToolbarHidden(!isHidden, animated: true)
//    }
//    func browserView(_ browserView: SAPBrowserView, didDoubleTapWith sender: AnyObject) {
//        _logger.trace()
//        
//        // 双击的时候隐藏
//        navigationController?.setNavigationBarHidden(true, animated: true)
//        navigationController?.setToolbarHidden(true, animated: true)
//    }
//    
//    func browserView(_ browserView: SAPBrowserView, shouldRotation orientation: UIImage.Orientation) -> Bool {
//        _logger.trace()
//        
//        _contentView.isScrollEnabled = false
//        return true
//    }
//    
//    func browserView(_ browserView: SAPBrowserView, didRotation orientation: UIImage.Orientation) {
//        _logger.trace()
//        
//        _contentView.isScrollEnabled = true
//    }
//}
//
//extension SAPBrowser: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//    
//    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return 0//dataSource?.numberOfPhotos(in: self) ?? 0
//    }
//    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let cell = cell as? SAPPreviewerCell else {
//            return
//        }
////        if let photo = dataSource?.photoPreviewer(self, photoForItemAt: indexPath.item) {
////            cell.delegate = self
////            cell.loader = _allLoader[photo.hashValue] ?? {
////                let loader = SAPhotoLoader(photo: photo)
////                _allLoader[photo.hashValue] = loader
////                return loader
////            }()
////        } else {
////            cell.delegate = self
////            cell.loader = nil
////        }
//    }
//    
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return view.frame.size
//    }
}
