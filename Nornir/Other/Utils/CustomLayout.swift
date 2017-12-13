//
//  CustomLayout.swift
//  Nornir
//
//  Created by sagesse on 13/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

public enum CustomLayoutAxis: Int {
    case vertical
    case horizontal
}

public class CustomLayout: NSObject {
    
    public init(_ identifier: String? = nil, axis: CustomLayoutAxis = .horizontal) {
        self.axis = axis
        self.priority = 0
        self.identifier = identifier
        
        self.size = .init(width: -1, height: -1)
        self.margin = .zero
        
        self.children = []
        
        super.init()
    }
    
    public convenience init(_ identifier: String? = nil, axis: CustomLayoutAxis = .horizontal, map: ((CustomLayout) -> ())? = nil) {
        self.init(identifier, axis: axis)
        map?(self)
    }
    
    public var axis: CustomLayoutAxis
    public var priority: Double
    public var identifier: String?
    
    public var size: CGSize
    public var margin: UIEdgeInsets
    
    public var children: Array<CustomLayout>
    
    public func append(_ identifier: String? = nil, axis: CustomLayoutAxis = .horizontal, map: ((CustomLayout) -> ())? = nil) {
        let node = CustomLayout(identifier, axis: axis)
        children.append(node)
        map?(node)
    }
    
    /// Find the first matching identifier the node.
    public func match(with identifier: String) -> CustomLayout? {
        
        guard self.identifier != identifier else {
            return self
        }
        
        for children in self.children {
            if let layout = children.match(with: identifier) {
                return layout
            }
        }
        
        return nil
    }
    
    /// Calculating all node layout data.
    public func compute(with box: CGSize, eval: (String?, CGSize) -> CGSize) -> ComputedCustomLayout {
        
        
        func precomputing(_ layout: CustomLayout) -> ComputedCustomLayout {
            let computed = ComputedCustomLayout(layout: layout)
            
            computed._frame.size = layout.size
            
            // Prioritized the layout of the subnodes
            computed._children = layout.children.map {
                return precomputing($0)
            }
            
            // Calculate all the size that you have used.
            computed._used = computed.children.reduce(.zero) {
                switch computed.axis {
                case .vertical:
                    return .init(width: max($0.width, $1.used.width),
                                 height: $0.height + $1.used.height)
                    
                case .horizontal:
                    return .init(width: $0.width + $1.used.width,
                                 height: max($0.height, $1.used.height))
                }
            }
            
            // If there is no child node, take all of the visual areas.
            if computed.children.isEmpty {
                computed._used.width = max(layout.size.width, 0)
                computed._used.height = max(layout.size.height, 0)
            }
            
            // Add the padding margin.
            computed._used.width += layout.margin.right + layout.margin.left
            computed._used.height += layout.margin.bottom + layout.margin.top
            
            return computed
        }
        
        @discardableResult
        func computing(_ computed: ComputedCustomLayout, _ box: CGSize, _ eval: (String?, CGSize) -> CGSize) -> CGSize {
            
            if computed.children.isEmpty {
                // The node is compute finish.
                guard computed.frame.size.width < 0 || computed.frame.size.height < 0 else {
                    return .zero
                }
                
                // This is the leaf node, for evaluation.
                computed._frame.size = eval(computed.identifier, box)
                
            } else {
                // This is the normal node, foreach all child node for the priority.
                let children = computed.children.sorted {
                    return $0.priority < $1.priority
                }
                
                var adjustment: CGSize = .zero
                
                // Computing used areas for all child node.
                computed._frame.size = children.reduce(.zero) {
                    
                    // Recalculate the available areas.
                    let nsize = CGSize(width: max(box.width - adjustment.width, 0),
                                       height: max(box.height - adjustment.height, 0))
                    
                    // Calculate the area that is actually used and modify the resize.
                    let nadjustment = computing($1, nsize, eval)
                    
                    switch computed.axis {
                    case .vertical:
                        // The vertical layout only updates the height.
                        adjustment.height += nadjustment.height
                        return .init(width: max($0.width, $1.used.width),
                                     height: $0.height + $1.used.height)
                        
                    case .horizontal:
                        // The horizontal layout only updates the width.
                        adjustment.width += nadjustment.width
                        return .init(width: $0.width + $1.used.width,
                                     height: max($0.height, $1.used.height))
                    }
                }
            }
            
            let old = computed.used
            
            // Add the padding margin.
            computed._used.width = computed.frame.width + computed.margin.right + computed.margin.left
            computed._used.height = computed.frame.height + computed.margin.bottom + computed.margin.top
            
            return .init(width: computed.used.width - old.width,
                         height: computed.used.height - old.height)
        }
        
        func updating(_ computed: ComputedCustomLayout, _ offset: CGPoint) {
            
            computed._box.origin = offset
            computed._box.size = computed.used
            
            computed._frame.origin.x = offset.x + computed.margin.left
            computed._frame.origin.y = offset.y + computed.margin.top
            
            _ = computed.children.reduce(computed.frame.origin) {
                updating($1, $0)
                
                switch computed.axis {
                case .vertical:
                    return .init(x: $0.x, y: $1.box.maxY)
                    
                case .horizontal:
                    return .init(x: $1.box.maxX, y: $0.y)
                }
            }
        }
        
        // Calculate the fixed size of the node and generate the computed layout.
        let computed = precomputing(self)
        
        //  Calculate calculates the size of the remainder available.
        let remaining = CGSize(width: max(max(box.width, 0) - computed.used.width, -1),
                               height: max(max(box.height, 0) - computed.used.height, -1))
        
        // Calculate the size of the fiexible node and update the used area.
        computing(computed, remaining, eval)
        
        // Update layout position.
        updating(computed, .zero)
        
        return computed
    }
}

public class ComputedCustomLayout: NSObject, NSCoding {
    
    fileprivate init(layout: CustomLayout) {
        _axis = layout.axis
        _priority = layout.priority
        _identifier = layout.identifier
        
        _frame = .zero
        _margin = layout.margin
        
        _box = .zero
        _used = .zero
        
        _children = []
        
        super.init()
    }
    public required init?(coder aDecoder: NSCoder) {
        
        _axis = CustomLayoutAxis(rawValue: aDecoder.decodeInteger(forKey: "axis")) ?? .horizontal
        _priority = aDecoder.decodeDouble(forKey: "priority")
        _identifier = aDecoder.decodeObject(forKey: "identifier") as? String
        
        _frame = aDecoder.decodeCGRect(forKey: "frame")
        _margin = aDecoder.decodeUIEdgeInsets(forKey: "margin")
        
        _box = aDecoder.decodeCGRect(forKey: "box")
        _used = aDecoder.decodeCGSize(forKey: "used")
        
        _children = aDecoder.decodeObject(forKey: "children") as? [ComputedCustomLayout] ?? []
        
        super.init()
    }
    
    
    public var axis: CustomLayoutAxis {
        return _axis
    }
    public var priority: Double {
        return _priority
    }
    public var identifier: String? {
        return _identifier
    }
    
    public var box: CGRect {
        return _box
    }
    public var frame: CGRect {
        return _frame
    }
    public var margin: UIEdgeInsets {
        return _margin
    }
    
    public var used: CGSize {
        return _used
    }
    
    public var children: [ComputedCustomLayout] {
        return _children
    }
    
    /// Find the first matching identifier the node.
    public func match(with identifier: String) -> ComputedCustomLayout? {
        
        guard self.identifier != identifier else {
            return self
        }
        
        for children in self.children {
            if let layout = children.match(with: identifier) {
                return layout
            }
        }
        
        return nil
    }
    
    /// Encode data in NSCoder
    public func encode(with aCoder: NSCoder) {
        
        aCoder.encode(_axis.rawValue, forKey: "axis")
        aCoder.encode(_priority, forKey: "priority")
        aCoder.encode(_identifier, forKey: "identifier")
        
        aCoder.encode(_frame, forKey: "frame")
        aCoder.encode(_margin, forKey: "margin")
        
        aCoder.encode(_box, forKey: "box")
        aCoder.encode(_used, forKey: "used")
        
        aCoder.encode(_children, forKey: "children")
    }
    
    fileprivate var _axis: CustomLayoutAxis
    fileprivate var _priority: Double
    fileprivate var _identifier: String?
    
    fileprivate var _frame: CGRect
    fileprivate var _margin: UIEdgeInsets
    
    fileprivate var _box: CGRect
    fileprivate var _used: CGSize
    
    fileprivate var _children: [ComputedCustomLayout]
}

