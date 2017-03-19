//
//  BrowserCollectionController.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class BrowserListController: UICollectionViewController {
    
    internal init(container: Container) {
        self.container = container
        super.init(collectionViewLayout: BrowserListLayout())
    }
    internal required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func loadView() {
        super.loadView()
        // setup controller
        title = "Collection"
        
        // setup colleciton view
        collectionView?.register(BrowserListCell.dynamic(with: UIImageView.self), forCellWithReuseIdentifier: "ASSET-IMAGE")
        collectionView?.backgroundColor = .white
        collectionView?.alwaysBounceVertical = true
    }
    
    internal let container: Container
    
    fileprivate var _detailAnimator: BrowserAnimator?
}

///
/// Provide collection view display support
///
extension BrowserListController: UICollectionViewDelegateFlowLayout {
    
    internal override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Browser.colors.count
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET-IMAGE", for: indexPath)
    }
    internal override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = Browser.colors[indexPath.item]
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        return layout.itemSize
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        logger.trace(indexPath)
        
        //BrowserAnimator
        
        let vc = BrowserDetailController(container: container)
        let animator = BrowserAnimator()
        vc.transitioningDelegate = animator
        //show(vc, sender: indexPath)
        navigationController?.pushViewController(vc, animated: true)
        _detailAnimator = animator
    }
}

//    weak var delegate: BrowseDelegate?
//    weak var dataSource: BrowseDataSource?
//
//    var browseIndexPath: IndexPath? { 
//        return _browseIndexPath
//    }
//    
//    func browseContentSize(at indexPath: IndexPath) -> CGSize {
//        return dataSource?.browser(self, assetForItemAt: indexPath).browseContentSize ?? .zero
//    }
//    func browseContentMode(at indexPath: IndexPath) -> UIViewContentMode {
//        return .scaleAspectFill
//    }
//    func browseContentOrientation(at indexPath: IndexPath) -> UIImageOrientation {
//        return .up
//    }
//    
//    func browseTransitioningView(at indexPath: IndexPath, forKey key: UITransitionContextViewKey) -> UIView? {
//        // self => controller
//        if key == .from {
//            let cell = collectionView.cellForItem(at: indexPath) as? BrowseViewCell
//            return cell?.previewView
//        }
//        // self <= conroller
//        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
//            // 没有包含indexPath, 说明这个cell并没有正在显示中, 滚动到这个cell里面
//            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
//            // 重置偏移
//            var pt = collectionView.contentOffset 
//            pt.y += collectionViewLayout.itemSize.height / 2
//            collectionView.contentOffset = pt
//            // 必须调用layoutIfNeeded, 否则cell并没有创建
//            collectionView.layoutIfNeeded()
//        }
//        // 检查这个indexPath是不是正在显示
//        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowseViewCell else {
//            return nil
//        }
//        let edg = collectionView.contentInset
//        let frame = cell.convert(cell.bounds, to: view)
//        let height = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length 
//      
//        let y1 = -edg.top + frame.minY
//        let y2 = -edg.top + frame.maxY
//        
//        // reset content offset if needed
//        if y2 > height {
//            // bottom over boundary, reset to y2(bottom)
//            collectionView.contentOffset.y += y2 - height
//        } else if y1 < 0 {
//            // top over boundary, rest to y1(top)
//            collectionView.contentOffset.y += y1
//        }
//        
//        return cell.previewView
//    }
//    
//    func showDetail(at indexPath: IndexPath, animated: Bool) {
//        let controller = BrowseDetailViewController()
//        
//        controller.delegate = delegate
//        controller.dataSource = dataSource
//        
//        _browseAnimator = IBControllerAnimator(from: self, to: controller)
//        _browseIndexPath = indexPath
//        
//        // self => controller
//        
//        let root = view.window?.rootViewController
//        
//        if let nav = root as? UINavigationController {
//            nav.delegate = _browseAnimator
//            nav.pushViewController(controller, animated: true)
//        } else {
//            controller.transitioningDelegate = _browseAnimator
//            root?.present(controller, animated: true, completion: nil)
//        }
//    }
//    
//    func showDetail(_ asset: Browseable, animated: Bool) {
//        let controller = BrowseDetailViewController()
//        
//        controller.view.backgroundColor = asset.backgroundColor
//        
//        show(controller, sender: self)
//    }
//    
//    lazy var _assets:[Browseable] = {
//        return (0 ..< 140).map{ _ in
//            return LocalImageAsset()
//        }
////        return (0 ..< 1400).map{ _ in
////            return LocalImageAsset()
////        }
//    }()
//    
//    fileprivate var _browseAnimator: IBControllerAnimator?
//    fileprivate var _browseIndexPath: IndexPath?
//    
//    
//}
//
