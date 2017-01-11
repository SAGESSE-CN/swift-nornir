//
//  IBExtendedToolbar.swift
//  Browser
//
//  Created by sagesse on 11/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import UIKit

open class IBExtendedToolbar: UIToolbar {
    // 每一行
    private class LineContext: NSObject {
        
        var height: CGFloat = 0
        var minimuxHeight: CGFloat = 0
        
        var view: UIView?
        var items: [UIBarButtonItem]?
    }
    
    open override var items: [UIBarButtonItem]? {
        set { return setItems(newValue, animated: false) }
        get { return _items }
    }
    
    open override func setItems(_ items: [UIBarButtonItem]?, animated: Bool) {
        _items = items
        let lines = items?.reduce([], { result, item -> [[UIBarButtonItem]] in
            if item is IBExtendedItem {
                return result + [[item]]
            }
            if result.last?.last is IBExtendedItem || result.isEmpty {
                return result + [[item]]
            }
            var tmp = result
            tmp[tmp.count - 1] += [item]
            return tmp
        })
        _setLines(lines, animated: animated)
    }
    
    private func _setLines(_ lines: [[UIBarButtonItem]]?, animated: Bool) {
        
        var index: Int = 0
        var height: CGFloat = 0
        let minimuxHeight: CGFloat = super.sizeThatFits(.zero).height
        
        // 生成行所需的数据
        let oldLines: [LineContext]? = _lines
        let newLines: [LineContext]? = lines?.map { 
            let context = LineContext()
            
            context.items = $0
            context.minimuxHeight = minimuxHeight
            
            if let item = $0.first as? IBExtendedItem {
                context.view = item.customView
                context.height = item.height
            } else {
                context.view = _dequeueReusableToolbar(with: IndexPath(item: index, section: 0))
                context.height = minimuxHeight
                index += 1
            }
            height += context.height
            
            return context
        }
        if height == 0 {
            height = minimuxHeight
        }
        // 生成无效的数据
        let invaildLines: [LineContext]? = oldLines?.filter { o in
            // 如果找到说明正在使用, 不能删除
            let f = newLines?.contains { n in
                n.view == o.view
            } ?? false
            return !f
        }
        
        // 更新
        _lines = newLines
        // 添加视图&更新
        newLines?.forEach { 
            guard let view = $0.view else {
                return
            }
            view.alpha = 1
            addSubview(view)
            guard let toolbar = view as? UIToolbar else {
                return
            }
            toolbar.setItems($0.items, animated: animated)
        }
        invaildLines?.forEach {
            guard let toolbar = $0.view as? UIToolbar else {
                return
            }
            toolbar.setItems(nil, animated: animated)
        }
        // 更新布局
        self.setNeedsLayout()
        self.layoutIfNeeded()
        self._layoutSubviewsWithLines(oldLines, in: self.frame.height)
        self._layoutSubviewsWithLines(newLines, in: max(self.frame.height, minimuxHeight))
        
        let block: () -> Void = {
            // 更新frame
            var nframe = self.frame
            nframe.origin.y -= height - self.frame.height 
            nframe.size.height = height 
            self.frame = nframe 
            // 更新subviews
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self._layoutSubviewsWithLines(oldLines, in: nframe.height)
            self._layoutSubviewsWithLines(newLines, in: nframe.height)
            // 清除无效subviews
            invaildLines?.forEach {
                $0.view?.alpha = 0
            }
        }
        let completion: (Bool) -> Void = { successed in
            // 动画是成功的?
            guard successed else {
                return
            }
            // 清除无效subviews
            invaildLines?.forEach {
                $0.view?.alpha = 1
                $0.view?.removeFromSuperview()
            }
        }
        self.invalidateIntrinsicContentSize()
        // 检查是否需要执行动画
        guard animated else {
            block()
            completion(true)
            return
        }
        // 执行
        UIView.animate(withDuration: 0.25, animations: block, completion: completion)
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        _layoutSubviewsWithLines(_lines, in: frame.height)
    }
    
    private func _layoutSubviewsWithLines(_ lines: [LineContext]?, in offset: CGFloat) {
        var y = offset
        lines?.reversed().forEach {
            let h1 = $0.height
            let h2 = max(min(y, h1), 0)
            if let view = $0.view {
                var nframe = view.frame
                nframe.origin.x = 0
                nframe.origin.y = y - h2
                nframe.size.width = frame.width
                nframe.size.height = h2
                view.frame = nframe
                view.layoutIfNeeded()
            }
            y -= h1
        }
    }
    
    private func _dequeueReusableToolbar(with indexPath: IndexPath) -> UIToolbar {
        if indexPath.item < _toolbars.count {
            return _toolbars[indexPath.item]
        }
        let toolbar = UIToolbar()
        
        toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        
        _toolbars.append(toolbar)
        return toolbar
    }
    
    private var _items: [UIBarButtonItem]?
    private var _lines: [LineContext]?
    
    private lazy var _toolbars: [UIToolbar] = []
}
