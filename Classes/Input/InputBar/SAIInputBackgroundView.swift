//
//  SAIInputBackgroundView.swift
//  SAIInputBar
//
//  Created by SAGESSE on 8/31/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

internal class SAIInputBackgroundView: UIToolbar {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        _init()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        _init()
//    }
//    deinit {
//        _deinit()
//    }
//    
//    private func _init() {
//        let center = NSNotificationCenter.defaultCenter()
//        center.addObserver(self, selector: #selector(willSnapshot(_:)), name: SAIInputBarWillSnapshot, object: nil)
//        center.addObserver(self, selector: #selector(didSnapshot(_:)), name: SAIInputBarDidSnapshot, object: nil)
//    }
//    private func _deinit() {
//        let center = NSNotificationCenter.defaultCenter()
//        
//        center.removeObserver(self)
//    }
//    
//    func willSnapshot(sender: NSNotification) {
//        _logger.trace()
//        
//        hidden = true
//        superview?.backgroundColor = UIColor.whiteColor()
////        if let tv = UI?.snapshotViewAfterScreenUpdates(false) {
////            superview?.addSubview(tv)
////        }
//    }
//    func didSnapshot(sender: NSNotification) {
//        _logger.trace()
//        
////        hidden = false
////        superview?.backgroundColor = nil
//    }
}

//private extension UIView {
//    
//    func ib_findInputBar() -> SAIInputBar? {
//        if let ib = self as?  SAIInputBar {
//            return ib
//        }
//        for view in subviews {
//            if let ib = view.ib_findInputBar() {
//                return ib
//            }
//        }
//        return nil
//    }
//    
//    @objc func ib_snapshotViewAfterScreenUpdates(afterUpdates: Bool) -> UIView? {
//        guard let inputBar = ib_findInputBar() else {
//            return ib_snapshotViewAfterScreenUpdates(afterUpdates)
//        }
//        inputBar._backgroundView?.hidden = true
//        let view = ib_snapshotViewAfterScreenUpdates(afterUpdates)
//        if let view = view {
//            let v = SAIInputBackgroundView()
//            
//            //v.frame = UIEdgeInsetsInsetRect(view.bounds, UIEdgeInsetsMake(0, 0, inputBar.frame.height, 0))
//            v.frame = inputBar.convertRect(inputBar.bounds, toView: self)
//            
//            view.insertSubview(v, atIndex: 0) //addSubview(v)
//        }
//        dispatch_async(dispatch_get_main_queue()) { 
//            inputBar._backgroundView?.hidden = false
//        }
//        return view
//    }
//}
