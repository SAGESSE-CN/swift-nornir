// The MIT License (MIT)
//
// Copyright (c) 2015-2016 forkingdog ( https://github.com/forkingdog )
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

extension UITableView {
    ///
    /// Access to internal template layout cell for given reuse identifier.
    /// Generally, you don't need to know these template layout cells.
    ///
    /// - parameter identifier: Reuse identifier for cell which must be registered.
    ///
    private func fd_templateReusableCellForIdentifier(identifier: String) -> UITableViewCell {
        let reusableCells = (objc_getAssociatedObject(self, self.dynamicType.fd_templateReusableCellForIdentifierKey) as? NSCache) ?? {
            let dic = NSCache()
            objc_setAssociatedObject(self, self.dynamicType.fd_templateReusableCellForIdentifierKey, dic, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return dic
        }()
        return (reusableCells.objectForKey(identifier) as? UITableViewCell) ?? {
            guard let templateCell = dequeueReusableCellWithIdentifier(identifier) else {
                fatalError("Cell must be registered to table view for identifier - \(identifier)")
            }
            templateCell.fd_isTemplateLayoutCell = true
            templateCell.contentView.translatesAutoresizingMaskIntoConstraints = false
            reusableCells.setObject(templateCell, forKey: identifier)
            fd_debugLog("template cell created - \(identifier)")
            return templateCell
        }()
    }
    
    ///
    /// Returns height of cell of type specifed by a reuse identifier and configured
    /// by the configuration block.
    ///
    /// The cell would be layed out on a fixed-width, vertically expanding basis with
    /// respect to its dynamic content, using auto layout. Thus, it is imperative that
    /// the cell was set up to be self-satisfied, i.e. its content always determines
    /// its height given the width is equal to the tableview's.
    ///
    /// - parameter identifier: A string identifier for retrieving and maintaining template
    ///             cells with system's "-dequeueReusableCellWithIdentifier:" call.
    /// - parameter configuration: An optional block for configuring and providing content
    ///             to the template cell. The configuration should be minimal for scrolling
    ///             performance yet sufficient for calculating cell's height.
    ///
    public func fd_heightForCellWithIdentifier(identifier: String, configuration: (UITableViewCell -> Void)? = nil) -> CGFloat {
        let templateLayoutCell = fd_templateReusableCellForIdentifier(identifier)
        
        // Manually calls to ensure consistent behavior with actual cells (that are displayed on screen).
        templateLayoutCell.prepareForReuse()
        
        // Customize and provide content for our template cell.
        configuration?(templateLayoutCell)
        
        var contentViewWidth = frame.width
        
        // If a cell has accessory view or system accessory type, its content view's width is smaller
        // than cell's by some fixed values.
        if let view = templateLayoutCell.accessoryView {
            contentViewWidth -= 16 + view.frame.width
        } else {
            switch templateLayoutCell.accessoryType {
            case .None:                     contentViewWidth -= 0
            case .DisclosureIndicator:      contentViewWidth -= 34
            case .DetailDisclosureButton:   contentViewWidth -= 68
            case .Checkmark:                contentViewWidth -= 40
            case .DetailButton:             contentViewWidth -= 48
            }
        }
        
        var fittingSize = CGSizeZero
        if (templateLayoutCell.fd_enforceFrameLayout) {
            // If not using auto layout, you have to override "-sizeThatFits:" to provide a fitting size by yourself.
            // This is the same method used in iOS8 self-sizing cell's implementation.
            // Note: fitting height should not include separator view.
            let inherited = templateLayoutCell.isMemberOfClass(UITableViewCell.self)
            let overrided = templateLayoutCell.dynamicType.instanceMethodForSelector("sizeThatFits:") != UITableViewCell.instanceMethodForSelector("sizeThatFits:")
            if (inherited && !overrided) {
                fatalError("Customized cell must override '-sizeThatFits:' method if not using auto layout.")
            }
            fittingSize = templateLayoutCell.sizeThatFits(CGSizeMake(contentViewWidth, 0))
        } else {
            // Add a hard width constraint to make dynamic content views (like labels) expand vertically instead
            // of growing horizontally, in a flow-layout manner.
            if (contentViewWidth > 0) {
                let widthFenceConstraint = NSLayoutConstraint(
                    item: templateLayoutCell.contentView,
                    attribute: .Width,
                    relatedBy: .Equal,
                    toItem: nil,
                    attribute: .NotAnAttribute,
                    multiplier: 1,
                    constant: contentViewWidth)
                templateLayoutCell.contentView.addConstraint(widthFenceConstraint)
                
                // Auto layout engine does its math
                fittingSize = templateLayoutCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
                
                templateLayoutCell.contentView.removeConstraint(widthFenceConstraint)
            }
        }
        
        // Add 1px extra space for separator line if needed, simulating default UITableViewCell.
        if self.separatorStyle != .None {
            fittingSize.height += 1.0 / UIScreen.mainScreen().scale
        }

        if (templateLayoutCell.fd_enforceFrameLayout) {
            fd_debugLog("calculate using frame layout - \(fittingSize.height)")
        } else {
            fd_debugLog("calculate using auto layout - \(fittingSize.height)")
        }
        
        return fittingSize.height
    }
    ///
    /// This method caches height by your model entity's identifier.
    /// If your model's changed, call `fd_invalidateHeightForKey`
    ///
    /// - parameter key: model entity's identifier whose data configures a cell.
    ///
    public func fd_heightForCellWithIdentifier(identifier: String, cacheByKey key: String, configuration: (UITableViewCell -> Void)? = nil) -> CGFloat {
        
        // Hit cache
        if let cachedHeight = fd_keyedHeightCache[key] {
            fd_debugLog("hit cache by key[\(key)] - \(cachedHeight)")
            return cachedHeight
        }
        
        let height = fd_heightForCellWithIdentifier(identifier, configuration: configuration)
        fd_keyedHeightCache[key] = height
        
        fd_debugLog("cached by key[\(key)] - \(height)")
        
        return height
    }
    /// recalculate cahce height for key
    public func fd_invalidateHeightForKey(key: String) {
        fd_keyedHeightCache.invalidateForKey(key)
    }
    /// recalculate all cache height
    public func fd_invalidateHeights() {
        fd_keyedHeightCache.invalidate()
    }
}

extension UITableView {
    /// tmp
    private class HeightCache: NSObject {
        
        subscript(key: String) -> CGFloat? {
            set { return heightsForDeviceOrientation[key] = newValue }
            get { return heightsForDeviceOrientation[key] as? CGFloat }
        }
        
        func invalidateForKey(key: String) {
            heightsForPortrait.removeObjectForKey(key)
            heightsForLandscape.removeObjectForKey(key)
        }
        func invalidate() {
            heightsForPortrait.removeAllObjects()
            heightsForLandscape.removeAllObjects()
        }
        
        private var heightsForPortrait: NSMutableDictionary = [:]
        private var heightsForLandscape: NSMutableDictionary = [:]
        private var heightsForDeviceOrientation: NSMutableDictionary {
            if UIDeviceOrientationIsPortrait(UIDevice.currentDevice().orientation) {
                return heightsForPortrait
            } else {
                return heightsForLandscape
            }
        }
    }
    
    /// Height cache by key. Generally, you don't need to use it directly.
    private var fd_keyedHeightCache: HeightCache {
        return (objc_getAssociatedObject(self, self.dynamicType.fd_keyedHeightCacheKey) as? HeightCache) ?? {
            let cache = HeightCache()
            objc_setAssociatedObject(self, self.dynamicType.fd_keyedHeightCacheKey, cache, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            return cache
        }()
    }
    /// some log
    private func fd_debugLog(log: String) {
        //print(log)
    }
    
    // some key
    private static var fd_keyedHeightCacheKey = unsafeAddressOf("fd_keyedHeightCacheKey")
    private static var fd_templateReusableCellForIdentifierKey = unsafeAddressOf("fd_templateReusableCellForIdentifierKey")
}

extension UITableViewCell {
    ///
    /// Indicate this is a template layout cell for calculation only.
    /// You may need this when there are non-UI side effects when configure a cell.
    /// Like:
    ///     func configureCell(cell: FooCell, atIndexPath indexPath: NSIndexPath) {
    ///       cell.entity = self.entityAtIndexPath(indexPath)
    ///       if !cell.fd_isTemplateLayoutCell {
    ///           self.notifySomething() // non-UI side effects
    ///       }
    ///   }
    ///
    public var fd_isTemplateLayoutCell: Bool {
        set { objc_setAssociatedObject(self, self.dynamicType.fd_isTemplateLayoutCellKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { return (objc_getAssociatedObject(self, self.dynamicType.fd_isTemplateLayoutCellKey) as? Bool) ?? false }
    }
    ///
    /// Enable to enforce this template layout cell to use "frame layout" rather than "auto layout",
    /// and will ask cell's height by calling "-sizeThatFits:", so you must override this method.
    /// Use this property only when you want to manually control this template layout cell's height
    /// calculation mode, default to NO.
    ///
    public var fd_enforceFrameLayout: Bool {
        set { objc_setAssociatedObject(self, self.dynamicType.fd_enforceFrameLayoutKey, newValue, .OBJC_ASSOCIATION_ASSIGN) }
        get { return (objc_getAssociatedObject(self, self.dynamicType.fd_enforceFrameLayoutKey) as? Bool) ?? false }
    }
    
    // some key
    private static var fd_enforceFrameLayoutKey = unsafeAddressOf("fd_enforceFrameLayoutKey")
    private static var fd_isTemplateLayoutCellKey = unsafeAddressOf("fd_isTemplateLayoutCellKey")
}
