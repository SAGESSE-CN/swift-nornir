//
//  IBTilingViewLayout.swift
//  Browser
//
//  Created by sagesse on 11/28/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

@objc class IBTilingViewLayoutPage: NSObject {
    
    init(begin: Int, end: Int) {
        self.begin = begin
        self.end = end
        super.init()
    }
    
    var index: Int = 0
    
    var begin: Int 
    var end: Int 
    
    var vaildRect: CGRect = .zero
    var visableRect: CGRect = .zero
    
    var isVailded: Bool = false
}

@objc class IBTilingViewLayout: NSObject {
    
    init(tilingView: IBTilingView) {
        super.init()
        self.tilingView = tilingView
    }
    
    var tilingViewContentSize: CGSize { 
        return _tilingViewContentSize
    }
    
    var estimatedItemSize: CGSize = CGSize(width: 20, height: 40)
    var minimumInteritemSpacing: CGFloat = 1
    
    func prepare() {
        guard let tilingView = tilingView else {
            return
        }
        
        let count = (0 ..< tilingView.numberOfSections).reduce(0) { 
            return $0 + tilingView.numberOfItems(inSection: $1)
        }
        
        var elements = [IBTilingViewLayoutAttributes]()
        var pages = [IBTilingViewLayoutPage]()
        var maps = [IndexPath: IBTilingViewLayoutAttributes](minimumCapacity: count)
        
        // 调整预留大小(性能优化)
        elements.reserveCapacity(count)
        
        
        var index: Int = 0
        
        var width: CGFloat = 0
        var height: CGFloat = 0
        
        var pageX: CGFloat = 0
        var pageStart: Int = 0
        let pageHeight = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        let pageWidth = pageHeight
        
        // 生成所有的元素
        for section in 0 ..< tilingView.numberOfSections {
            for item in 0 ..< tilingView.numberOfItems(inSection: section) {
                let indexPath = IndexPath(item: item, section: section)
                let attributes = IBTilingViewLayoutAttributes(forCellWith: indexPath)
                
                var frame = CGRect(x: width, y: 0, width: 0, height: 0)
                frame.size = sizeForItem(at: indexPath)
                attributes.frame = frame
                attributes.fromFrame = frame
                
                // 更新偏移
                index += 1
                width = frame.maxX + minimumInteritemSpacing
                height = max(frame.maxY, height)
                
                // 保存
                elements.append(attributes)
                maps[indexPath] = attributes
                
                // 检查page
                if index == count || frame.maxX >= pageX + pageWidth {
                    let page = IBTilingViewLayoutPage(begin: pageStart, end: index)
                    
                    page.index = pages.count
                    page.visableRect = attributes.frame.union(elements[pageStart].frame)
                    page.vaildRect = CGRect(x: pageX, y: 0, width: pageWidth, height: pageHeight)
                    pages.append(page)
                    
                    // 移动..
                    pageStart = index
                    pageX += pageWidth
                }
            }
        }
        
        // 保存数据
        _tilingViewLayoutPages = pages
        _tilingViewLayoutElements = elements
        _tilingViewLayoutElementMaps = maps
        // 更新内容大小
        _tilingViewContentSize = CGSize(width: max(width - minimumInteritemSpacing, 0), height: height)
    }
    
    func sizeForItem(at indexPath: IndexPath) -> CGSize {
        guard let tilingView = tilingView else {
            return estimatedItemSize
        }
        return tilingView.tilingDelegate?.tilingView?(tilingView, layout: self, sizeForItemAt: indexPath) ?? estimatedItemSize
    }
    
    func invalidateLayout(at indexPaths: [IndexPath]) {
        return invalidateLayout(at: indexPaths) { attr in
            return sizeForItem(at: attr.indexPath)
        }
    }
    func invalidateLayout(at indexPaths: [IndexPath], _ sizeForItemWithHandler: (IBTilingViewLayoutAttributes) -> CGSize) {
        guard !indexPaths.isEmpty else {
            return // indexPaths is empty, no change
        }
        let reloadElements = indexPaths.sorted().flatMap { _tilingViewLayoutElementMaps[$0] }
        if reloadElements.isEmpty {
            return // reloadElements is empty(all remove), no change
        }
        // update version
        _version += 1
        // show rect
        let showedWidth: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        var showedRect: CGRect = CGRect(x: 0, y: 0, width: showedWidth * 2, height: showedWidth)
        var showedIndexs: [Int] = []
        if let contentOffset = tilingView?.contentOffset {
            showedRect.origin.x = floor(contentOffset.x / showedWidth) * showedWidth
        }
        // update all visable rect for page
        var offset: CGFloat = 0
        var reloadIndex: Int = 0
        let reloadCount: Int = reloadElements.count
        for index in 0 ..< _tilingViewLayoutPages.count {
            let page = _tilingViewLayoutPages[index]
            
            // 移动
            page.visableRect = page.visableRect.offsetBy(dx: offset, dy: 0)
            if offset != 0 {
                page.isVailded = true
            }
            // 检查正在显示的page
            if page.vaildRect.intersects(showedRect) {
                showedIndexs.append(index)
            }
            // 检查是否需要更新区域内的元素
            guard reloadIndex < reloadCount else {
                // 如果offset为0, 因为申请更新的indexPath己经全部处理完成了, 可以中断
                guard offset != 0 else {
                    break
                }
                continue
            }
            let firstAttributes = reloadElements[reloadIndex]
            guard page.visableRect.tiling_contains(firstAttributes.frame) else {
                // 不在区域内
                continue 
            }
            // 在区域内, 需要更新
            (page.begin ..< page.end).forEach({ 
                let attributes = _tilingViewLayoutElements[$0]
                
                var frame = attributes.frame
                if reloadIndex < reloadCount && attributes.indexPath == reloadElements[reloadIndex].indexPath {
                    // 读取大小
                    frame.size = sizeForItemWithHandler(attributes)
                    // 己找到, 下一个
                    reloadIndex += 1
                }
                frame.origin.x += offset
                
                attributes.fromFrame = attributes.frame
                attributes.frame = frame
                attributes.version = _version
                
                offset += frame.width - attributes.fromFrame.width
            })
        }
        for index in showedIndexs {
            _updatePage(_tilingViewLayoutPages[index])
        }
        // update content size
        _tilingViewContentSize.width += offset
    }
        
    func indexPathForItem(at point: CGPoint) -> IndexPath? {
        // 首先查询该位置在那一页(性能优化)
        guard let page = _tilingViewLayoutPages.first(where: { $0.visableRect.tiling_contains(point) }) else {
            return nil // 不在任何一页里面
        }
        // 如果可见区域己经失效, 先更新页
        if page.isVailded {
            _updatePage(page)
        }
        // 然后读取该页中的元素(性能优化)
        for index in page.begin ..< page.end {
            let attributes = _tilingViewLayoutElements[index]
            guard attributes.frame.tiling_contains(point) else {
                continue // 并不是, 继续查找
            }
            return attributes.indexPath // ok
        }
        return nil // 并没有找到, 可以点击到空白处了
    }
    func layoutAttributesForItem(at indexPath: IndexPath) -> IBTilingViewLayoutAttributes? {
        return _tilingViewLayoutElementMaps[indexPath]
    }
    func layoutAttributesForElements(in rect: CGRect) -> [IBTilingViewLayoutAttributes]? {
        var begin: Int = .max
        var end: Int = .min
        // 可能跨页, 所以可能会存在多个结果(性能优化)
        for index in 0 ..< _tilingViewLayoutPages.count {
            let page = _tilingViewLayoutPages[index]
            if page.vaildRect.intersects(rect) {
                // 如果可见区域己经失效, 先更新页
                if page.isVailded {
                    _updatePage(page)
                }
                // 合并结果
                begin = min(begin, page.begin)
                end = max(end, page.end)
            }
            if page.vaildRect.minX > rect.maxX {
                break // 己经超出的话忽略(性能优化)
            }
        }
        logger.debug("\(rect) => \(begin) ..< \(end)")
        guard begin < end else {
            return nil
        }
        return Array(_tilingViewLayoutElements[begin ..< end]) // copy
    }
    
    private func _updatePage(_ page: IBTilingViewLayoutPage) {
        //_logger.debug(page.index)
        
        let x1 = page.visableRect.minX
        var x2 = x1
        for index in page.begin ..< page.end {
            let attr = _tilingViewLayoutElements[index]
            let tx2 = x2 + attr.frame.width + minimumInteritemSpacing
            
            if attr.version != _version {
                var frame = attr.frame
                
                frame.origin.x = x2
                
                attr.version = _version
                attr.fromFrame = attr.frame
                attr.frame = frame
            }
            
            x2 = tx2
        }
        
//        let count = _tilingViewLayoutElements.count
//        
//        var x1 = page.visableRect.minX
//        var begin = min(page.begin, max(count - 1, 0))
//        
//        // begin << n
//        while begin > 0 && begin <= count {
//            let attr = _tilingViewLayoutElements[begin - 1]
//            let tx1 = x1 - attr.frame.width - minimumInteritemSpacing
//           
//            // 往左边查找第一个不符合条件的元素
//            // vaildRect.minX < tx1 <= page.vaildRect.maxX
//            guard page.vaildRect.minX <= tx1 && tx1 <= page.vaildRect.maxX else  {
//                break
//            }
//            begin -= 1
//            x1 = tx1
//        }
//        // begin >> n
//        while begin < count {
//            let attr = _tilingViewLayoutElements[begin] 
//            let tx2 = x1 + attr.frame.width + minimumInteritemSpacing
//            
//            // 往右边查找第一个符合条件的元素
//            // vaildRect.minX <= x1 <= page.vaildRect.maxX
//            if page.vaildRect.minX <= x1 && x1 <= page.vaildRect.maxX  {
//                break // found
//            }
//            if page.vaildRect.maxX <= x1 {
//                break // is over boundary
//            }
//            begin += 1
//            x1 = tx2
//        }
//        // end >> n
//        var x2 = x1
//        var end = begin
//        while end < count {
//            let attr = _tilingViewLayoutElements[end]
//            let tx1 = x2
//            let tx2 = x2 + attr.frame.width + minimumInteritemSpacing
//            
//            guard page.vaildRect.minX <= tx1 && tx1 <= page.vaildRect.maxX else {
//                break // x1 over boundary
//            }
//            guard page.vaildRect.minX <= tx2 else {
//                break // x2 over boundary
//            }
//            
//            if attr.version != _version {
//                var frame = attr.frame
//                
//                frame.origin.x = tx1
//                
//                attr.version = _version
//                attr.fromFrame = attr.frame
//                attr.frame = frame
//            }
//            
//            end += 1
//            x2 = tx2
//        }
//        
//        page.begin = begin
//        page.end = end
        
        page.visableRect.origin.x = x1
        page.visableRect.size.width = x2 - x1
        
        page.isVailded = false
    }
    
    weak var tilingView: IBTilingView?
    
    private var _tilingViewContentSize: CGSize = .zero
    
    private var _version: Int = 0
    private lazy var _tilingViewLayoutPages: [IBTilingViewLayoutPage] = []
    private lazy var _tilingViewLayoutElements: [IBTilingViewLayoutAttributes] = []
    private lazy var _tilingViewLayoutElementMaps: [IndexPath: IBTilingViewLayoutAttributes] = [:]
}
