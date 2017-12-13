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
                $0.margin.left = 10
                $0.margin.right = 10 + 40
                $0.margin.bottom = 10
                $0.append(axis: .vertical) { // R:1
                    $0.priority = 1000
                    $0.append("<Avatar>", axis: .vertical) { // A
                        $0.margin.top = 2
                        $0.margin.left = 2
                        $0.margin.right = 2
                        $0.margin.bottom = 2
                    }
                }
                $0.append(axis: .vertical) { // R:2
                    $0.append("<Card>") {
                        $0.margin.top = 0
                        $0.margin.left = 0
                        $0.margin.right = 0
                        $0.margin.bottom = 0
                    }
                    $0.append("<Bubble>") {
                        $0.margin.top = 8
                        $0.margin.left = 10
                        $0.margin.right = 10
                        $0.margin.bottom = 8
                        $0.append("<Contents>") {
                            $0.margin.top = 2
                            $0.margin.left = 2
                            $0.margin.right = 2
                            $0.margin.bottom = 2
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
                $0.margin.top = 10
                $0.margin.left = 10
                $0.margin.right = 10 + 40
                $0.margin.bottom = 10
                $0.append(axis: .vertical) { // R:1
                    $0.priority = 1000
                    $0.append("<Avatar>", axis: .vertical) { // A
                        $0.margin.top = 2
                        $0.margin.left = 2
                        $0.margin.right = 2
                        $0.margin.bottom = 2
                    }
                }
                $0.append(axis: .vertical) { // R:2
                    $0.append("<Bubble>") {
                        $0.margin.top = 8
                        $0.margin.left = 10
                        $0.margin.right = 10
                        $0.margin.bottom = 8
                        
                        $0.append("<Contents>") {
                            $0.margin.top = 2
                            $0.margin.left = 2
                            $0.margin.right = 2
                            $0.margin.bottom = 2
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
    
    private lazy var _styles: [MessageStyle: CustomLayout] = [:]
}

