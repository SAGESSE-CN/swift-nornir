//
//  ChatViewLayout.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit



open class ChatViewLayout: UICollectionViewFlowLayout {
    
    open override func prepare() {
        // The estimated item width automatic following view.
        self.collectionView.map {
            self.estimatedItemSize = .init(width: $0.frame.width, height: 80)
        }
        // Continue to prepare for the layout
        super.prepare()
    }
    
    open class override var layoutAttributesClass: AnyClass {
        return ChatViewLayoutAttributes.self
    } 
    
    open func style(with style: MessageStyle) -> CustomLayout {
        // Is hit cache?
        if let style = _styles[style] {
            return style
        }
        
        let new: CustomLayout
        switch style {
        case .prominent:
            // The is a normal message. Reference by QQ, WeChat, Discord.
            //
            // +----------------R:0----------+-T:0-+
            // | +-R:1-+--------R:2----------+     |
            // | |+---+ <NAME>               |     |
            // | || A | +-------R:3--------\ |     |
            // | |+---+ | +--------------+ | |     |
            // | |      | |   CONTENT    | | |     |
            // | |      | +--------------+ | |     |
            // | |      \------------------/ |     |
            // | +-----+---------------------+     |
            // +-----------------------------------+
            //
            new = CustomLayout(axis: .horizontal) {
                $0.margin.top = 10
                $0.margin.left = 8
                $0.margin.right = 8
                $0.margin.bottom = 0
                $0.append(axis: .vertical) { // R:1
                    $0.priority = 666
                    $0.append("<Avatar>", axis: .vertical) { // A
                        $0.margin.top = 2
                        $0.margin.left = 2
                        $0.margin.right = 2
                        $0.margin.bottom = 2
                    }
                }
                $0.append(axis: .vertical) { // R:2
                    $0.priority = 233
                    $0.append("<Card>") {
                        $0.margin.left = 7.5
                        $0.margin.right = 7.5
                    }
                    $0.append("<Bubble>") {
                        $0.margin.left = 0
                        $0.margin.right = 40.5
                        $0.append("<Contents>") {
                            $0.margin.top = 16
                            $0.margin.left = 22
                            $0.margin.right = 22
                            $0.margin.bottom = 18.5
                        }
                    }
                }
            }
            
        case .minimal:
            // The is a normal message whitout name. Reference by QQ.
            //
            // +----------------R:0----------+-T:0-+
            // | +-R:1-+--------R:2----------+     |
            // | |+---+ +-------R:3--------\ |     |
            // | || A | | +--------------+ | |     |
            // | |+---+ | |   CONTENT    | | |     |
            // | |      | +--------------+ | |     |
            // | |      \------------------/ |     |
            // | +-----+---------------------+     |
            // +-----------------------------------+
            //
            new = CustomLayout(axis: .horizontal) {
                $0.margin.top = 14
                $0.margin.left = 8
                $0.margin.right = 8
                $0.margin.bottom = 0
                $0.append(axis: .vertical) { // R:1
                    $0.priority = 666
                    $0.append("<Avatar>", axis: .vertical) { // A
                        $0.margin.top = 2 + 6
                        $0.margin.left = 2
                        $0.margin.right = 2
                        $0.margin.bottom = 2
                    }
                }
                $0.append(axis: .vertical) { // R:2
                    $0.priority = 233
                    $0.append("<Bubble>") {
                        $0.margin.left = 0
                        $0.margin.right = 40
                        $0.append("<Contents>") {
                            $0.margin.top = 16
                            $0.margin.left = 22
                            $0.margin.right = 22
                            $0.margin.bottom = 18.5
                        }
                    }
                }
            }
            
        case .notice:
            // The is a system message.
            new = CustomLayout(axis: .horizontal) {
                $0.margin.top = 10
                $0.margin.left = 20
                $0.margin.right = 20
                $0.margin.bottom = 10
                $0.append("<Contents>") {
                    $0.margin.top = 4
                    $0.margin.left = 10
                    $0.margin.right = 10
                    $0.margin.bottom = 4
                }
            }
            
        case .custom:
            // The is a custom message.
            new = CustomLayout(axis: .horizontal)
        }

        // Save for next fetch.
        _styles[style] = new
        
        return new
    }
    
    open func xxx(_ identifier: String, sizeForProposed size: CGSize) -> CGSize {
        switch identifier {
        case "<Card>":
            // The card for the prominent style message.
            return .init(width: size.width, height: 20)
            
        case "<Avatar>":
            // The avatar for the prominent & minimal style message.
            return .init(width: 40, height: 40)
            
        case "<Contents>":
            // The avatar for the prominent & minimal & notice style message.
            return .init(width: size.width, height: 120)
            
        default:
            // The item is custom, default is zero.
            // Please in subclasses implement this method.
            return .zero
        }
    }

    
    open override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return super.layoutAttributesForItem(at: indexPath).map {
            return _layoutAttributes($0)
        }
    }
    
    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return super.layoutAttributesForElements(in: rect)?.map {
            return _layoutAttributes($0)
        }
    }
    
    private func _layoutAttributes(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        // only process `ChatViewLayoutAttributes`
        guard let newLayoutAttributes = layoutAttributes as? ChatViewLayoutAttributes else {
            return layoutAttributes
        }

        newLayoutAttributes.preferredLayout = _styles[.prominent]?.compute(with: .init(width: collectionView?.frame.width ?? 0, height: -1)) {
            return  xxx($0 ?? "", sizeForProposed: $1)
        }
        
        return newLayoutAttributes
    }
    
    private lazy var _styles: [MessageStyle: CustomLayout] = [:]
}

