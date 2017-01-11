//
//  SACChatView.swift
//  SAChat
//
//  Created by SAGESSE on 26/12/2016.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

class SACChatView: UICollectionView {
    
    override init(frame: CGRect, collectionViewLayout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: collectionViewLayout)
        _commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _commonInit()
    }
    
    
    //UIKit`-[UICollectionView _shouldShowMenuForCell:]:
    //UIKit`-[UICollectionViewCell _gestureRecognizerShouldBegin:]:
//    private dynamic func _gestureRecognizerShouldBegin(_ sender: UILongPressGestureRecognizer) {
//    }
    
    private func _commonInit() {
       
        backgroundColor = .white
        
        allowsSelection = false
        allowsMultipleSelection = false
    }
    
//    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        guard gestureRecognizer == _menuGesture else {
//            return super.gestureRecognizerShouldBegin(gestureRecognizer)
//        }
//        
//        return false
//    }
//    
}

//extension SACChatView: UIGestureRecognizerDelegate {
//}

protocol SACChatViewDataSource {
    
    func numberOfItems(in chatView: SACChatView)
    
    func chatView(_ chatView: SACChatView, itemAtIndexPath: IndexPath)
    
}

protocol SACChatViewDelegate {
    
    func chatView(_ chatView: SACChatView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool
    func chatView(_ chatView: SACChatView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool
    func chatView(_ chatView: SACChatView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?)
}

