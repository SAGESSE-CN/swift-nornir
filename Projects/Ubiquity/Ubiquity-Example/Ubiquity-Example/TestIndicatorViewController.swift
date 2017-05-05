//
//  TestIndicatorViewController.swift
//  Ubiquity-Example
//
//  Created by SAGESSE on 4/23/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit
@testable import Ubiquity


class MYCollectionViewFlowLayout: UICollectionViewFlowLayout {
    
    
}


//class MYCollectionView: UICollectionView {
////    override func layoutSubviews() {
////        super.layoutSubviews()
////        logger.trace?.write()
////    }
//    
//    
//    override func reloadItems(at indexPaths: [IndexPath]) {
//        
//        let items = collectionViewLayout.layoutAttributesForElements(in: .init(x: 0, y: 0, width: contentSize.width, height: contentSize.height))
//        var map: [IndexPath:UICollectionViewLayoutAttributes] = [:]
//        items?.forEach({
//            map[$0.indexPath] = $0
//        })
//        
//        
//        UIView.performWithoutAnimation {
//            super.reloadItems(at: indexPaths)
//        }
//        UIView.animate(withDuration: 0.25, animations: {
//            self.indexPathsForVisibleItems.forEach({
//                guard let cell = self.cellForItem(at: $0), let att = map[$0] else {
//                    return
//                }
//                let frame = cell.frame
//                UIView.performWithoutAnimation {
//                    cell.frame = att.frame
//                }
//                cell.frame = frame
//            })
//        })
//    }
//
//}

class IndicatorAnimationContext: NSObject {
    
    func save(_ collectionView: UICollectionView, at indexPaths: [IndexPath]) {
    }
    func restore(_ collectionView: UICollectionView) {
    }
}

class IndicatorView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = bounds.width
        let height = bounds.height
        
        _collectionView.frame = .init(x: -width, y: 0, width: width  * 3, height: height)
        _collectionView.contentInset = .init(top: 0, left: width * 1.5, bottom: 0, right: width * 1.5)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        logger.trace?.write(scrollView.contentOffset)
        
        
        _deactive(animated: true)
    }
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        logger.trace?.write(scrollView.contentOffset, targetContentOffset.move())
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        logger.trace?.write(scrollView.contentOffset, decelerate)
        
        if !decelerate {
            scrollViewDidEndDecelerating(scrollView)
        }
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        logger.trace?.write(scrollView.contentOffset)
        
        var pt = scrollView.contentOffset
        pt.x += scrollView.bounds.width / 2
        guard let indexPath = _collectionView.indexPathForItem(at: pt) else {
            return // 并没有找到该cell
        }
        _active(at: indexPath, animated: true)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        logger.trace?.write(scrollView.contentOffset)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET", for: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard _indexPath == indexPath else {
            return .init(width: 20, height: collectionView.frame.height)
        }
        return .init(width: 20 + 88, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = colors[indexPath.item]
        manager.apply(cell: cell, at: indexPath)
    }
    
    var _indexPath: IndexPath?
    lazy var colors: [UIColor] = (0 ..< 999).map { _ in
        return .random
    }
    
    private func _active(at indexPath: IndexPath, animated: Bool) {
        logger.trace?.write(indexPath)
        
        _indexPath = indexPath
        _reloadItems(at: [indexPath])
    }
    private func _deactive(animated: Bool) {
        guard let indexPath = _indexPath else {
            return
        }
        logger.info?.write(indexPath)
        logger.debug?.write(_collectionView.indexPathsForVisibleItems)
        
        _indexPath = nil
        _reloadItems(at: [indexPath])
    }
    
    
//    open func reloadItems(at indexPaths: [IndexPath])
//    open func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath)
    
    private func _performBatchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
        logger.trace?.write()
       
    }
    
    private func _insertItems(at indexPaths: [IndexPath]) {
        logger.trace?.write()
        
    }
    private func _deleteItems(at indexPaths: [IndexPath]) {
        logger.trace?.write()
        
    }
    class IndicatorAnimationManager: NSObject {
        
        init(with collectionView: UICollectionView) {
            self.collectionView = collectionView
            super.init()
        }
        
        func animate(withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)?) {
            
            begin(with: duration)
            UIView.performWithoutAnimation {
                collectionView.performBatchUpdates({
                    animations()
                }, completion: nil)
            }
            commit()
            
            collectionView.indexPathsForVisibleItems.forEach { indexPath in
                guard let cell = self.collectionView.cellForItem(at: indexPath) else {
                    return
                }
                apply(cell: cell, at: indexPath)
            }
        }
        
        
        private func begin(with duration: TimeInterval) {
            logger.trace?.write()
            
            _processing = true
            _duration = duration
            _making = [:] // 允许生成
        }
        private func commit() {
            logger.trace?.write()
            
            _processing = false
            _beginTime = CACurrentMediaTime()
            
//            allLines.forEach { line in
//                guard line.isValid else {
//                    return
//                }
//                guard let newLine = _making?[line.newLayoutAttributes.indexPath] else {
//                    return
//                }
//                let size = line.presentationSize
//                var nframe = line.newLayoutAttributes.frame
//                nframe.origin.x += size.width
//                nframe.origin.y += size.height
//                nframe.size.width += size.width
//                nframe.size.height += size.height
//                newLine.oldLayoutAttributes.frame = nframe
//            }
//            allLines.removeAll()
            
            _making?.forEach { (key, line) in
                guard let attr = collectionView.layoutAttributesForItem(at: line.newLayoutAttributes.indexPath) else {
                    logger.error?.write("unable to find layout attributes the at \(line.newLayoutAttributes.indexPath)")
                    return
                }
                
                line.newLayoutAttributes = attr
                line.beginTime = _beginTime
                line.endTime = _beginTime + _duration
                // 复制
                allLines.append(line)
            }
            _making = nil // 禁止生成
        }
        
        func reloadItems(at indexPaths: [IndexPath]) {
            // 每个改变都创建一行
            indexPaths.forEach {
                guard let attr = _presentationLayoutAttributesForItem(at: $0) else {
                    logger.error?.write("unable to find layout attributes the at \($0)")
                    return
                }
                _making?[$0] = .init(layoutAttributes: attr, action: .reload)
            }
            // 通知ui更新
            collectionView.reloadItems(at: indexPaths)
        }
        
        func apply(cell: UICollectionViewCell, at indexPath: IndexPath) {
            guard !_processing else {
                return
            }
            
            // 还有动画需要添加
//            guard _beginTime + _duration > CACurrentMediaTime() else {
//                return
//            }
            guard let offset = offset(at: indexPath) else {
                return
            }
            let frame = cell.frame
            UIView.performWithoutAnimation {
                var nframe = frame
                nframe.origin.x += offset.origin.x
                nframe.origin.y += offset.origin.y
                nframe.size.width += offset.size.width
                nframe.size.height += offset.size.height
                cell.frame = nframe
            }
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(_duration)
            cell.frame = frame
            UIView.commitAnimations()
            
            // 修改动画启动时间和持续时间(用于连接己显示的动画)
            cell.layer.animationKeys()?.forEach { key in
                let layer = cell.layer
                guard let ani = layer.animation(forKey: key)?.mutableCopy() as? CABasicAnimation else {
                    return
                }
                ani.beginTime = _beginTime
                layer.add(ani, forKey: key)
            }
        }
        
        func _layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attr = collectionView.layoutAttributesForItem(at: indexPath)
            return attr
        }
        func _presentationLayoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
            let attr = _layoutAttributesForItem(at: indexPath)
            
            var size: CGSize = .zero
            var origin: CGPoint = .zero
            
            allLines.forEach { line in
                // 这条线是否己经过期
                guard line.isValid else {
                    return
                }
                guard _duration == 0 else {
                    return
                }
                let result = line.compare(at: indexPath)
                guard result != .orderedAscending else {
                    return
                }
                let duration = _duration
                let current = CACurrentMediaTime() - _beginTime
                let width = line.size.width * CGFloat(current / duration)
                let height = line.size.height * CGFloat(current / duration)
                
                guard result != .orderedDescending else {
                    origin.x += width
                    origin.y += height
                    return
                }
                size.width += width
                size.height += height
            }
            
            if var nframe = attr?.frame {
                nframe.origin.x += origin.x
                nframe.origin.y += origin.y
                nframe.size.width += size.width
                nframe.size.height += size.height
                attr?.frame = nframe
            }
            
            return attr
        }
        
        func offset(at indexPath: IndexPath) -> CGRect? {
            
            var size: CGSize = .zero
            var origin: CGPoint = .zero
            
            allLines.forEach { line in
                // 这条线是否己经过期
                guard line.isValid else {
                    return
                }
                let result = line.compare(at: indexPath)
                guard result != .orderedAscending else {
                    return
                }
                guard result != .orderedDescending else {
                    origin.x += line.size.width
                    origin.y += line.size.height
                    return
                }
                size.width += line.size.width
                size.height += line.size.height
            }
            
            if size == .zero && origin == .zero {
                return nil
            }
            
            
            
            return .init(origin: origin, size: size)
        }
        
        private var _processing: Bool = false
        
        private var _beginTime: CFTimeInterval = 0
        private var _duration: TimeInterval = 0
        
        // 生成中的line
        private var _making: [IndexPath: IndicatorAnimationLine]?
        
        lazy var allLines: [IndicatorAnimationLine] = []
        
        unowned var collectionView: UICollectionView
    }
    class IndicatorAnimationLine: NSObject {
        
        init(layoutAttributes: UICollectionViewLayoutAttributes, action: UICollectionUpdateAction) {
            self.action = action
            self.oldLayoutAttributes = layoutAttributes
            self.newLayoutAttributes = layoutAttributes
            super.init()
        }
        
        var isValid: Bool {
            return endTime > CACurrentMediaTime()
        }
        
        var size: CGSize = .zero
        var action: UICollectionUpdateAction
        
        var beginTime: CFTimeInterval = 0
        var endTime: CFTimeInterval = 0
        
        var oldLayoutAttributes: UICollectionViewLayoutAttributes
        var newLayoutAttributes: UICollectionViewLayoutAttributes {
            willSet {
                let nframe = newValue.frame
                let oframe = oldLayoutAttributes.frame
                
                size.width = oframe.width - nframe.width
                size.height = oframe.height - nframe.height
            }
        }
        
        func compare(at itemIndexPath: IndexPath) -> ComparisonResult {
            // if itemIndexPath the section is greater than indexPath the section,
            // then itemIndexPath must greater the indexPath
            if itemIndexPath.section > newLayoutAttributes.indexPath.section {
                return .orderedDescending
            }
            // if itemIndexPath the section is less than indexPath the section,
            // then itemIndexPath must less the indexPath
            if itemIndexPath.section < newLayoutAttributes.indexPath.section {
                return .orderedAscending
            }
            // under the same section, if the item is bigger that he in the back
            if itemIndexPath.item > newLayoutAttributes.indexPath.item {
                return .orderedDescending
            }
            // under the same section, if the item is small that he in the front
            if itemIndexPath.item < newLayoutAttributes.indexPath.item {
                return .orderedAscending
            }
            // itemIndexPath and indexPath is the same
            return .orderedSame
        }
    }
    
    
    private lazy var manager: IndicatorAnimationManager = .init(with: self._collectionView)
    
    private func _reloadItems(at indexPaths: [IndexPath]) {
        logger.trace?.write()
        
        self.manager.animate(withDuration: 0.25 * 10, animations: {
            
            self.manager.reloadItems(at: indexPaths)
            
        }, completion: { finished in
            
            
        })
        
//        UIView.performWithoutAnimation {
//            manager.begin()
//
//            manager.commit()
//        }
//        
//        
//        
////        // 收集动画信息
////        UIView.animate(withDuration: 0.25, animations: {
////            let ani = self.layer.action(forKey: #keyPath(backgroundColor)) as? CABasicAnimation
////            self.logger.trace?.write(ani)
////            self.logger.trace?.write(ani?.beginTime, ani?.duration)
////        })
//        
//        UIView.animate(withDuration: 0.25, animations: {
//            self._collectionView.indexPathsForVisibleItems.forEach({
//                guard let cell = self._collectionView.cellForItem(at: $0) else {
//                    return
//                }
//                guard let offset = manager.offset(at: $0) else {
//                    return
//                }
//                let frame = cell.frame
//                UIView.performWithoutAnimation {
//                    var nframe = frame
//                    nframe.origin.x += offset.origin.x
//                    nframe.origin.y += offset.origin.y
//                    nframe.size.width += offset.size.width
//                    nframe.size.height += offset.size.height
//                    cell.frame = nframe
//                }
//                cell.frame = frame
//            })
//        })
    }
    
    
    private func _setup() {
        
        _collectionViewLayout.scrollDirection = .horizontal
        _collectionViewLayout.minimumLineSpacing = 0
        _collectionViewLayout.minimumInteritemSpacing = 0
        
        _collectionView.backgroundColor = .clear
        _collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "ASSET")
        _collectionView.dataSource = self
        _collectionView.delegate = self
        
        addSubview(_collectionView)
    }
    
    
    private lazy var _collectionView: UICollectionView = .init(frame: .zero, collectionViewLayout: self._collectionViewLayout)
    private lazy var _collectionViewLayout: UICollectionViewFlowLayout = MYCollectionViewFlowLayout()
    
}

class XA: UIView {
}

class TestIndicatorViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    
    
//
//    override func viewWillLayoutSubviews() {
//        super.viewWillLayoutSubviews()
//        let edg = UIEdgeInsetsMake(0, view.bounds.width, 0, view.bounds.width)
//        collectionView.contentInset = edg
//    }
//
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        return colors.count
//    }
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "ASSET", for: indexPath)
//    }
//
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        logger.trace?.write(indexPath)
//        
//        cell.backgroundColor = colors[indexPath.item]
//    }
//    
}
