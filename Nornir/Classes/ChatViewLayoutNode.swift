//
//  ChatViewLayoutNode.swift
//  Nornir
//
//  Created by sagesse on 13/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal enum ChatViewLayoutAxis: Int {
    case vertical
    case horizontal
    
}

internal class ChatViewLayoutComputedNode {
    
    init(node: ChatViewLayoutNode) {
        _axis = node.axis
        _priority = node.priority
        _identifier = node.identifier
        
        _frame = .zero
        _margin = node.margin
        
        _box = .zero
        _used = .zero
        
        _children = []
    }
    
    internal var axis: ChatViewLayoutAxis {
        return _axis
    }
    internal var priority: CGFloat {
        return _priority
    }
    internal var identifier: String? {
        return _identifier
    }
    
    internal var box: CGRect {
        return _box
    }
    internal var frame: CGRect {
        return _frame
    }
    internal var margin: UIEdgeInsets {
        return _margin
    }
    
    internal var used: CGSize {
        return _used
    }
    
    internal var children: [ChatViewLayoutComputedNode] {
        return _children
    }
    
    /// Find the first matching identifier the node.
    internal func node(with identifier: String) -> ChatViewLayoutComputedNode? {
        
        guard self.identifier != identifier else {
            return self
        }
        
        for children in self.children {
            if let layout = children.node(with: identifier) {
                return layout
            }
        }
        
        return nil
    }
    
    fileprivate var _axis: ChatViewLayoutAxis
    fileprivate var _priority: CGFloat
    fileprivate var _identifier: String?
    
    fileprivate var _frame: CGRect
    fileprivate var _margin: UIEdgeInsets
    
    fileprivate var _box: CGRect
    fileprivate var _used: CGSize
    
    fileprivate var _children: [ChatViewLayoutComputedNode]
}

internal class ChatViewLayoutNode {
    
    internal typealias Evaluation = (String?, UIEdgeInsets, CGSize) -> CGSize
    
    
    init(_ identifier: String? = nil, axis: ChatViewLayoutAxis = .horizontal) {
        self.identifier = identifier
        self.axis = axis
        
        self.margin = .zero
        
        self.children = []
    }
    convenience init(_ identifier: String? = nil, axis: ChatViewLayoutAxis = .horizontal, map: ((ChatViewLayoutNode) -> ())? = nil) {
        self.init(identifier, axis: axis)
        map?(self)
    }
    
    let axis: ChatViewLayoutAxis
    var priority: CGFloat = 0
    let identifier: String?
    
    var size: CGSize = .init(width: -1, height: -1)
    var margin: UIEdgeInsets
    
    var children: Array<ChatViewLayoutNode>
    
    func append(_ identifier: String? = nil, axis: ChatViewLayoutAxis = .horizontal, map: ((ChatViewLayoutNode) -> ())? = nil) {
        let node = ChatViewLayoutNode(identifier, axis: axis)
        children.append(node)
        map?(node)
    }
    
    /// Find the first matching identifier the node.
    func node(with identifier: String) -> ChatViewLayoutNode? {
        
        guard self.identifier != identifier else {
            return self
        }
        
        for children in self.children {
            if let layout = children.node(with: identifier) {
                return layout
            }
        }
        
        return nil
    }
    
    /// Calculating all node layout data.
    func compute(with box: CGSize, eval: Evaluation) -> ChatViewLayoutComputedNode {
        
        
        func precomputing(_ root: ChatViewLayoutNode) -> ChatViewLayoutComputedNode {
            let computed = ChatViewLayoutComputedNode(node: root)
            
            computed._frame.size = root.size
            
            // Prioritized the layout of the subnodes
            computed._children = root.children.map {
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
                computed._used.width = max(root.size.width, 0)
                computed._used.height = max(root.size.height, 0)
            }
            
            // Add the padding margin.
            computed._used.width += root.margin.right + root.margin.left
            computed._used.height += root.margin.bottom + root.margin.top
            
            return computed
        }
        
        @discardableResult
        func computing(_ computed: ChatViewLayoutComputedNode, _ box: CGSize, _ eval: Evaluation) -> CGSize {
            
            if computed.children.isEmpty {
                // The node is compute finish.
                guard computed.frame.size.width < 0 || computed.frame.size.height < 0 else {
                    return .zero
                }
                
                // This is the leaf node, for evaluation.
                computed._frame.size = eval(computed.identifier, computed.margin, box)
                
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
        
        func updating(_ computed: ChatViewLayoutComputedNode, _ offset: CGPoint) {
            
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

////
//// +----------------R:0----------+-T:0-+
//// | +-R:1-+--------R:2----------+     |
//// | |+---+ <NAME>               |     |
//// | || A | +-------R:3--------\ |     |
//// | |+---+ | +--------------+ | |     |
//// | |      | |   CONTENT    | | |     |
//// | |      | +--------------+ | |     |
//// | |      \------------------/ |     |
//// | +-----+---------------------+     |
//// +-----------------------------------+
////
//let root = ChatViewLayoutNode(axis: .horizontal) { // R:0
//    
//    $0.margin.top = 6
//    $0.margin.left = 8
//    $0.margin.right = 8 + 20
//    $0.margin.bottom = 6
//    
//    $0.append(axis: .vertical) { // R:1
//        $0.append("avatar", axis: .vertical) { // A
//            // avatar margin, scale: 2x
//            // +---------+
//            // | +-----+ |
//            // | |     | |
//            // | +-----+ |
//            // +---------+
//            $0.margin.top = 2
//            $0.margin.left = 2
//            $0.margin.right = 2
//            $0.margin.bottom = 2
//            
//            $0.size.width = 40
//            $0.size.height = 40
//        }
//    }
//    $0.append(axis: .vertical) { // R:2
//        $0.append("card") {
//            // card margin, scale: 2x
//            // +-------------------+
//            // | +---------------+ |
//            // | +---------------+ |
//            // +-------------------+
//            $0.margin.top = 0
//            $0.margin.left = 0
//            $0.margin.right = 0
//            $0.margin.bottom = 0
//        }
//        $0.append("bubble") {
//            // bubble image margin, scale: 2x
//            // /------------------\
//            // |  +------------+  |
//            // |  |            |  |
//            // |  +------------+  |
//            // \------------------/
//            $0.margin.top = 8
//            $0.margin.left = 10
//            $0.margin.right = 10
//            $0.margin.bottom = 8
//            
//            $0.append("bubble-contnet") {
//                // content margin, scale: 2x, radius: 15
//                // +----------------+
//                // | +------------+ |
//                // | |            | |
//                // | +------------+ |
//                // +----------------+
//                $0.margin.top = 2
//                $0.margin.left = 2
//                $0.margin.right = 2
//                $0.margin.bottom = 2
//            }
//        }
//    }
//}
//
//let computed = root.compute(with: .init(width: UIScreen.main.bounds.width, height: -1)) { identifier, _, tar in
//    switch identifier ?? "" {
//    case "card":
//        return .init(width: 150, height: 40)
//        
//    case "bubble-contnet":
//        return .init(width: 180, height: 999)
//        
//    default:
//        return .zero
//    }
//}
//logger.debug?.write(computed)

