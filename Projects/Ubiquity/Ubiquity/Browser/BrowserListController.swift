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
}

///
/// Provide collection view display support
///
extension BrowserListController: UICollectionViewDelegateFlowLayout {
    
    internal override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return container.numberOfSections
    }
    internal override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return container.numberOfItems(inSection: section)
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET-IMAGE", for: indexPath)
    }
    internal override func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell =  cell as? BrowserListCell else {
            return
        }
        return cell.apply(for: container.item(at: indexPath))
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else {
            return .zero
        }
        return layout.itemSize
    }
    
    internal override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        logger.trace?.write(indexPath)
        
        let controller = BrowserDetailController(container: container, at: indexPath)
        controller.animator = Animator(source: self, destination: controller)
        show(controller, sender: indexPath)
       
//        let animator = Animator(destination: controller, source: self, at: indexPath)
            //BrowserAnimator(destination: controller, source: self, at: indexPath)
//        controller.animator = animator
    }
}

///
/// Provide animatable transitioning support
///
extension BrowserListController: TransitioningDataSource {
    
    internal func ub_transitionView(using animator: Animator, for operation: Animator.Operation) -> TransitioningView? {
        logger.trace?.write()
        
        guard let indexPath = animator.indexPath else {
            return nil
        }
        // get at current index path the cell
        return collectionView?.cellForItem(at: indexPath) as? BrowserListCell
    }
    
    internal func ub_transitionShouldStart(using animator: Animator, for operation: Animator.Operation) -> Bool {
        logger.trace?.write()
        return true
    }
    internal func ub_transitionShouldStartInteractive(using animator: Animator, for operation: Animator.Operation) -> Bool {
        logger.trace?.write()
        return false
    }
    
    internal func ub_transitionDidPrepare(using animator: Animator, context: TransitioningContext) {
        logger.trace?.write()
        
        // must be attached to the collection view
        guard let collectionView = collectionView, let indexPath = animator.indexPath  else {
            return
        }
        // check the index path is displaying
        if !collectionView.indexPathsForVisibleItems.contains(indexPath) {
            // no, scroll to the cell at index path
            collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: false)
            // must call the layoutIfNeeded method, otherwise cell may not create
            collectionView.layoutIfNeeded()
        }
        // fetch cell at index path, if is displayed
        guard let cell = collectionView.cellForItem(at: indexPath) as? BrowserListCell else {
            return
        }
        // if it is to, reset cell boundary
        if context.ub_operation == .pop || context.ub_operation == .dismiss {
            let edg = collectionView.contentInset
            let frame = cell.convert(cell.bounds, to: view)
            let height = view.frame.height - topLayoutGuide.length - bottomLayoutGuide.length
            
            let y1 = -edg.top + frame.minY
            let y2 = -edg.top + frame.maxY
            
            // reset content offset if needed
            if y2 > height {
                // bottom over boundary, reset to y2(bottom)
                collectionView.contentOffset.y += y2 - height
            } else if y1 < 0 {
                // top over boundary, rest to y1(top)
                collectionView.contentOffset.y += y1
            }
        }
        cell.isHidden = true
    }
    internal func ub_transitionDidEnd(using animator: Animator, transitionCompleted: Bool) {
        guard let indexPath = animator.indexPath else {
            return
        }
        guard let cell = collectionView?.cellForItem(at: indexPath) as? BrowserListCell else {
            return
        }
        cell.isHidden = false
    }
}

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
