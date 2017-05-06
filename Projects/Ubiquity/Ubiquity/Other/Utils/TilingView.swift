//
//  TilingView.swift
//  Ubiquity
//
//  Created by sagesse on 16/03/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

@objc internal protocol TilingViewDataSource {
    
    func tilingView(_ tilingView: TilingView, numberOfItemsInSection section: Int) -> Int
    // The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
    func tilingView(_ tilingView: TilingView, cellForItemAt indexPath: IndexPath) -> TilingViewCell
    
    @objc optional func numberOfSections(in tilingView: TilingView) -> Int
}

@objc internal protocol TilingViewDelegate {
    
    @objc optional func tilingView(_ tilingView: TilingView, shouldSelectItemAt indexPath: IndexPath) -> Bool
    @objc optional func tilingView(_ tilingView: TilingView, didSelectItemAt indexPath: IndexPath)
    
    @objc optional func tilingView(_ tilingView: TilingView, willDisplay cell: TilingViewCell, forItemAt indexPath: IndexPath)
    @objc optional func tilingView(_ tilingView: TilingView, didEndDisplaying cell: TilingViewCell, forItemAt indexPath: IndexPath)
    
    @objc optional func tilingView(_ tilingView: TilingView, layout: TilingViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
}

@objc internal class TilingView: UIScrollView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    weak var tilingDelegate: TilingViewDelegate?
    weak var tilingDataSource: TilingViewDataSource?
    
    var layout: TilingViewLayout {
        return _layout
    }
    
    var numberOfSections: Int {
        return tilingDataSource?.numberOfSections?(in: self) ?? 1
    }
    func numberOfItems(inSection section: Int) -> Int {
        return tilingDataSource?.tilingView(self, numberOfItemsInSection: section) ?? 0
    }
    
    func register(_ cellClass: AnyClass?, forCellWithReuseIdentifier identifier: String) {
        _registedCellClass[identifier] = cellClass as? TilingViewCell.Type
    }
    
    func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> TilingViewCell {
        if let cell = _reusableDequeues[identifier]?.pop(for: indexPath) {
            return cell
        }
        guard let cls = _registedCellClass[identifier] else {
            fatalError("not register cell")
        }
        let cell = cls.init()
        cell.reuseIdentifier = identifier
        return cell
    }
    
    func performBatchUpdates(_ updates: (() -> Swift.Void)?, completion: ((Bool) -> Swift.Void)? = nil) {
    }
    
    func insertItems(at indexPaths: [IndexPath]) {
        //logger.trace?.write(indexPaths)
        
    }
    func reloadItems(at indexPaths: [IndexPath]) {
        //logger.trace?.write(indexPaths)
        
        _needsUpdateLayout = true // 重新更新
        _needsUpdateLayoutVisibleRect = true // 重新计算
        
        _layout.invalidateLayout(at: indexPaths)
        // 更新大小
        contentSize = _layout.tilingViewContentSize
        
        _animationDuration = 0
        _animationBeginTime = CACurrentMediaTime()
        _animationIsStarted = true
        
        UIView.animate(withDuration: 0.25, animations: {
            UIView.setAnimationBeginsFromCurrentState(true)
            
            self._updateLayout()
            
        }, completion: { f in
            
            self._animationIsStarted = false
            self._needsUpdateLayoutVisibleRect = true
            self._updateLayout()
        })
        
        // 收集动画信息
        _animationDuration = _visableCells.reduce(0) { dur, ele in
            let layer = ele.value.layer
            let tmp = layer.animationKeys()?.flatMap({ layer.animation(forKey: $0)?.duration }).max()
            return max(dur, tmp ?? 0)
        }
    }
    func reloadItems(at indexPaths: [IndexPath], _ sizeForItemWithHandler: (TilingViewLayoutAttributes) -> CGSize) {
        //logger.trace?.write(indexPaths)
        
        _needsUpdateLayout = true // 重新更新
        _needsUpdateLayoutVisibleRect = true // 重新计算
        
        //如果
        //_needsUpdateLayoutVaildRect = true
        
        _layout.invalidateLayout(at: indexPaths, sizeForItemWithHandler)
        
        // 更新大小
        contentSize = _layout.tilingViewContentSize
            
        _updateLayout()
    }
    func deleteItems(at indexPaths: [IndexPath]) {
        logger.trace?.write(indexPaths)
    }
    
    var indexPathsForVisibleItems: [IndexPath] { 
        return _visableCells.flatMap {
            return $0.key
        }
    }
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        return _visableLayoutElements?.first(where: { 
            $0.frame.tiling_contains(point)
        })?.indexPath ?? _layout.indexPathForItem(at: point)
    }
    
    var visibleCells: [TilingViewCell] { 
        return _visableCells.flatMap {
            return $0.value
        }
    }
    func cellForItem(at indexPath: IndexPath) -> TilingViewCell? {
        return _visableCells[indexPath]
    }
    
    func layoutAttributesForItem(at indexPath: IndexPath) -> TilingViewLayoutAttributes? {
        return _layout.layoutAttributesForItem(at: indexPath)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        _updateLayout()
    }
    
    private func _updateLayout() {
        _updateLayoutVaildRectIfNeeded()
        _updateLayoutVisibleRectIfNeeded()
        _updateLayoutIfNeeded()
    }
    private func _updateLayoutVaildRectIfNeeded() {
        // 检查有效区域
        let vaildRect = UIEdgeInsetsInsetRect(_vaildLayoutRect, UIEdgeInsetsMake(0, 0, 0, _vaildLayoutRect.width / 2))
        if !_needsUpdateLayoutVaildRect && !vaildRect.contains(contentOffset) {
            _needsUpdateLayoutVaildRect = true
        }
        guard _needsUpdateLayoutVaildRect else {
            return
        }
        _needsUpdateLayoutVaildRect = false
        
        let width = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let offsetX = floor(contentOffset.x / width) * width
        let rect = CGRect(x: offsetX, y: 0, width: width * 2, height: width)
        // 更新当前布局, 假定一定是有序的
        _vaildLayoutRect = rect
        _vaildLayoutElements = _layout.layoutAttributesForElements(in: rect)
    }
    private func _updateLayoutVisibleRectIfNeeded() {
        // 更新可见区域
        
        // 获取当前显示区域(如果正在执行动画将包含在其中)
        let rect = layer.bounds.union(layer.presentation()?.bounds ?? layer.bounds)
        //
        // |    |>       visable       <|    |
        // | x1 | first | ...... | last | x2 |
        //
        // if x1 < visable.minX, left over boundary
        // if x2 > visable.maxX, right over boundary
        // if x1 > firstRect.maxX, first cell or more is over boundary
        // if x2 < lastRect.minX, last cell or more is over boundary
        if !_needsUpdateLayoutVisibleRect {
            let x1 = max(rect.minX, 0)
            let x2 = min(rect.maxX, contentSize.width)
            let visible = _visibleLayoutRect
            let lastRect = _visableLayoutElements?.last?.frame ?? .zero
            let firstRect = _visableLayoutElements?.first?.frame ?? .zero
            
            if x1 < visible.minX || x2 > visible.maxX || x1 > firstRect.maxX || x2 < lastRect.minX {
                _needsUpdateLayoutVisibleRect = true
            }
        }
        guard _needsUpdateLayoutVisibleRect else {
            return
        }
        _needsUpdateLayoutVisibleRect = false
        // 记录变更
        var insertIndexPaths: [IndexPath] = []
        var removeIndexPaths: [IndexPath] = []
        
        if let elements = _vaildLayoutElements {
            var begin = 0
            var end = 0
            
            let last = _visableLayoutElements?.last
            let first = _visableLayoutElements?.first
            for (offset, attr) in elements.enumerated() {
                if attr.indexPath == first?.indexPath {
                    begin = offset
                }
                if attr.indexPath == last?.indexPath {
                    end = offset + 1
                    break
                }
            }
            
            let count = _visableLayoutElements?.count ?? 0
            // 设置保留大小
            var newVisableElements: [TilingViewLayoutAttributes] = []
            newVisableElements.reserveCapacity(count + 8)
            // 初始化可见区域
            var x1: CGFloat = .greatestFiniteMagnitude
            var x2: CGFloat = .leastNormalMagnitude
            
            for index in (0 ..< begin).reversed() {
                // 检查是否可以添加
                let attr = elements[index]
                let frame = _visableRect(with: attr)
                guard rect.tiling_contains(frame) else {
                    // 检查是否还在区域内
                    guard frame.minX >= rect.minX else {
                        break
                    }
                    continue
                }
                newVisableElements.insert(attr, at: 0)
                insertIndexPaths.insert(attr.indexPath, at: 0)
                // 计算可见区域
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
            }
            for index in (0 ..< count) {
                guard let attr = _visableLayoutElements?[index] else {
                    continue
                }
                // 检查这个元素是否己经被移除了
                var frame = _visableRect(with: attr)
                // 如果可以的话直接获取屏幕的frame
                if let layer = _visableCells[attr.indexPath]?.layer {
                    // 试图包含动画区域
                    frame = layer.frame.union(layer.presentation()?.frame ?? layer.frame)
                }
                guard rect.tiling_contains(frame) else {
                    removeIndexPaths.append(attr.indexPath)
                    continue
                } 
                // TODO: 检查这个元素是否需要更新
                newVisableElements.append(attr)
                // 计算可见区域
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
            }
            for index in (end ..< elements.count) {
                // 检查是否可以添加
                let attr = elements[index]
                let frame = _visableRect(with: attr)
                guard rect.tiling_contains(frame) else {
                    // 检查是否还在区域内
                    guard frame.minX <= rect.maxX else {
                        break
                    }
                    continue
                }
                newVisableElements.append(attr)
                insertIndexPaths.append(attr.indexPath)
                // 计算可见区域
                x1 = min(x1, attr.frame.minX)
                x2 = max(x2, attr.frame.maxX)
            }
           
            _visibleLayoutRect = CGRect(x: x1, y: 0, width: x2 - x1, height: bounds.height)
            _visableLayoutElements = newVisableElements
            
        } else {
            // 没有任何元素, 移除所有
            removeIndexPaths = _visableLayoutElements?.flatMap {
                return $0.indexPath
            } ?? []
            _visibleLayoutRect = .zero
            _visableLayoutElements = nil
        }
        
        // 更新可见cell
        _updateLayoutVisibleCellIfNeeded(insertIndexPaths, removeIndexPaths, [])
        _needsUpdateLayout = true
    }
    private func _updateLayoutVisibleCellIfNeeded(_ ins: [IndexPath], _ rms: [IndexPath], _ rds: [IndexPath]) {
        // 更新可见单元格
        //print("IN: \(ins)")
        //print("RM: \(rms)")
        
        // 删除(先删除)
        rms.forEach { indexPath in
            guard let cell = _visableCells[indexPath] else {
                return
            }
            _visableCells.removeValue(forKey: indexPath)
            // 隐藏通知
            tilingDelegate?.tilingView?(self, didEndDisplaying: cell, forItemAt: indexPath)
            // 配置Cell
            cell.isHidden = true
            
            cell.layer.removeAllAnimations()
            cell.subviews.forEach { 
                $0.layer.removeAllAnimations()
            }
            
            guard let identifier = cell.reuseIdentifier else {
                cell.removeFromSuperview()
                return // 不允许重用
            }
            let queue = _reusableDequeues[identifier] ?? {
                let tmp = TilingViewReusableDequeue()
                _reusableDequeues[identifier] = tmp
                return tmp
            }()
            queue.push(for: indexPath, reuseableView: cell)
        }
        // 插入
        ins.forEach { indexPath in
            // 如果indexPath正在显示. 直接返回
            guard _visableCells[indexPath] == nil else {
                return
            }
            guard let cell = tilingDataSource?.tilingView(self, cellForItemAt: indexPath) else {
                return // 创建失败
            }
            _visableCells[indexPath] = cell
            // 配置Cell
            cell.isHidden = false
            
            addSubview(cell)
            
            // 显示通知
            tilingDelegate?.tilingView?(self, willDisplay: cell, forItemAt: indexPath)
        }
    }
    private func _updateLayoutIfNeeded() {
        guard _needsUpdateLayout else {
            return
        }
        _needsUpdateLayout = false
        
        _visableLayoutElements?.forEach { attr in
            guard let cell = _visableCells[attr.indexPath] else {
                return
            }
            guard !cell.frame.tiling_equal(attr.frame) else {
                return
            }
            let hasCustomAnimation = { Void -> Bool in
                guard !attr.fromFrame.tiling_equal(attr.frame) else {
                    return false // 并没有变更操作
                }
                guard _animationDuration != 0 else {
                    return false // 并没有正在执行中的动画
                }
                guard CACurrentMediaTime() < _animationBeginTime + _animationDuration else {
                    return false // 并没有正在执行中的动画
                }
                guard cell.layer.animationKeys() == nil else {
                    return false // 动画己经执行过了
                }
                return true
            }()
            //print("animation at \(attr.indexPath): \(cell.frame)(\(cell.layer.presentation()?.frame)), \(attr.fromFrame) to \(attr.frame)")
            if (UIView.areAnimationsEnabled || hasCustomAnimation) {
                UIView.performWithoutAnimation {
                    cell.frame = attr.fromFrame
                    cell.layoutIfNeeded()
                }
            }
            guard hasCustomAnimation else {
                cell.frame = attr.frame
                cell.layoutIfNeeded()
                return
            }
            UIView.animate(withDuration: _animationDuration, animations: {
                cell.frame = attr.frame
                cell.layoutIfNeeded()
            })
            // 修改动画启动时间和持续时间(用于连接己显示的动画)
            cell.layer.animationKeys()?.forEach { key in
                let layer = cell.layer
                guard let ani = layer.animation(forKey: key)?.mutableCopy() as? CABasicAnimation else {
                    return
                }
                ani.beginTime = _animationBeginTime
                ani.duration = _animationDuration
                // 恢复动画
                layer.add(ani, forKey: key)
            }
        }
    }
    
    private func _visableRect(with attr: TilingViewLayoutAttributes) -> CGRect {
        guard _animationIsStarted else {
            return attr.frame
        }
        // 如果正在执行动画, 额外添加可见区域
        return attr.frame.union(attr.fromFrame)
    }
    
    private dynamic func _tapHandler(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: self)
        guard let attr = _visableLayoutElements?.filter({ $0.frame.contains(location) }).first else {
            return
        }
        guard tilingDelegate?.tilingView?(self, shouldSelectItemAt: attr.indexPath) ?? true else {
            return
        }
        tilingDelegate?.tilingView?(self, didSelectItemAt: attr.indexPath)
    }
    
    private func _commonInit() {
        
        _lazyTapGestureRecognizer.delaysTouchesEnded = true
        _lazyTapGestureRecognizer.addTarget(self, action: #selector(_tapHandler(_:)))
        
        addGestureRecognizer(_lazyTapGestureRecognizer)
    }
    
    private var _animationBeginTime: CFTimeInterval = 0
    private var _animationDuration: CFTimeInterval = 0
    
    private var _animationIsStarted: Bool = false
    
    private var _needsUpdateLayout: Bool = true
    private var _needsUpdateLayoutVaildRect: Bool = true
    private var _needsUpdateLayoutVisibleRect: Bool = true
    
    private var _vaildLayoutRect: CGRect = .zero
    private var _vaildLayoutElements: [TilingViewLayoutAttributes]?
    
    private var _visibleLayoutRect: CGRect = .zero
    private var _visableLayoutElements: [TilingViewLayoutAttributes]?
    
    private lazy var _layoutIsPrepared: Bool = false
    private lazy var _layout: TilingViewLayout = {
        let layout = TilingViewLayout(tilingView: self)
        
        layout.prepare()
        self.contentSize = layout.tilingViewContentSize
        
        return layout
    }()
    
    private lazy var _visableCells: [IndexPath: TilingViewCell] = [:]
    private lazy var _reusableDequeues: [String: TilingViewReusableDequeue] = [:]
    private lazy var _registedCellClass: [String: TilingViewCell.Type] = [:]
    
    private lazy var _lazyTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
}

fileprivate class TilingViewReusableDequeue: NSObject {
    
    private var _arr: Array<TilingViewCell> = []
    
    func push(for indexPath: IndexPath, reuseableView view: TilingViewCell) {
        _arr.append(view)
    }
    func pop(for indexPath: IndexPath) -> TilingViewCell? {
        if !_arr.isEmpty {
            return _arr.removeLast()
        }
        return nil
    }
}

internal extension CGRect {
    
    func tiling_contains(_ point: CGPoint) -> Bool {
        return (minX <= point.x && point.x <= maxX) 
            && (minY <= point.y && point.y <= maxY)
    }
    func tiling_contains(_ rect2: CGRect) -> Bool {
        return ((minX <= rect2.minX && rect2.minX <= maxX) || (minX <= rect2.maxX && rect2.maxX <= maxX))
            && ((minY <= rect2.minY && rect2.minY <= maxY) || (minY <= rect2.maxY && rect2.maxY <= maxY))
    }
    
    // 避免误差
    func tiling_equal(_ rect: CGRect) -> Bool {
        return (fabs(minX - rect.minX) < 0.000001)
            && (fabs(minY - rect.minY) < 0.000001)
            && (fabs(width - rect.width) < 0.000001)
            && (fabs(height - rect.height) < 0.000001)
    }
}
