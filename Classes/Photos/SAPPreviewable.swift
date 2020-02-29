//
//  SAPPreviewable.swift
//  SAC
//
//  Created by SAGESSE on 10/12/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit

@objc public protocol SAPPreviewableDelegate: NSObjectProtocol {
    
    func toPreviewable(with item: AnyObject) -> SAPPreviewable?
    func fromPreviewable(with item: AnyObject) -> SAPPreviewable?
    
    @objc optional func previewable(_ previewable: SAPPreviewable, willShowItem item: AnyObject)
    @objc optional func previewable(_ previewable: SAPPreviewable, didShowItem item: AnyObject)
}

@objc public protocol SAPPreviewable: NSObjectProtocol {
    
    var previewingFrame: CGRect { get }
    
    var previewingContent: Progressiveable? { get }
    var previewingContentSize: CGSize { get }
    
    var previewingContentMode: UIView.ContentMode { get }
    var previewingContentOrientation: UIImage.Orientation { get }
}
