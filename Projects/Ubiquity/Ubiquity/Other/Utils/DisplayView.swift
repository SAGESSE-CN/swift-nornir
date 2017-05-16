//
//  DisplayView.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/16/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class DisplayView: UIView, Displayable {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _setup()
    }
    
    ///
    /// display container content with item
    ///
    /// - parameter item: need display the item
    /// - parameter orientation: need display the orientation
    ///
    func willDisplay(with item: Item, orientation: UIImageOrientation) {
        // update rotation
        _contentView.transform = .init(rotationAngle: orientation.ub_angle)
    }
    ///
    /// end display content with item
    ///
    /// - parameter item: need display the item
    ///
    func endDisplay(with item: Item) {
        // nothing
    }
    
    ///
    /// generate quick snapshot, if there is time synchronous display
    ///
    /// - parameter afterUpdates: whether you need to update now
    ///
    override func snapshotView(afterScreenUpdates afterUpdates: Bool) -> UIView? {
        
        let contentView = UIView(frame: .zero)
        let snapshotView = UIView(frame: frame)
        let replicantView = DisplayReplicantView(contentView: _contentView)
        
        // calculate the size of the rotation after
        let size = snapshotView.bounds.applying(_contentView.transform).size
        
        // setup snapshot view
        snapshotView.backgroundColor = backgroundColor
        snapshotView.addSubview(contentView)
        
        // setup content view
        contentView.bounds = .init(origin: .zero, size: size)
        contentView.center = .init(x: snapshotView.bounds.midX, y: snapshotView.bounds.midY)
        contentView.transform = _contentView.transform
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(replicantView)
        
        // setup replicant view
        replicantView.frame = contentView.bounds
        replicantView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // ok
        return snapshotView
    }
    /// update the subview layout
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // computing size after rotation
        let size = bounds.applying(_contentView.transform).size
        // update content view layout
        _contentView.bounds = .init(x: 0, y: 0, width: size.width, height: size.height)
        _contentView.center = .init(x: bounds.midX, y: bounds.midY)
    }
    /// only added to the _contentView
    override func addSubview(_ view: UIView) {
        _contentView.addSubview(view)
    }
    
    private func _setup() {
        
        // setup content view
        _contentView.frame = bounds
        _contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        super.addSubview(_contentView)
    }
    
    private lazy var _contentView: DisplayContentView = .init()
}
internal class DisplayContentView: UIView {
}
internal class DisplayReplicantView: UIView {
    
    init(contentView: UIView) {
        super.init(frame: contentView.frame)
        _contentView = contentView
    }
    
    override init(frame: CGRect) {
        // can't alloc the type of object
        fatalError("init(frame:) has not been implemented")
    }
    required init?(coder aDecoder: NSCoder) {
        // can't alloc the type of object
        fatalError("init(coder:) has not been implemented")
    }
    
    override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        
        logger.debug?.write("show is \(newWindow != nil)")
        // need to display a snapshot?
        guard let contentView = _contentView else {
            return
        }
        
        if newWindow == nil {
            // setup for hidde
            guard _caches != nil else {
                return // ownership has been transferred
            }
            _caches?.forEach { (view, frame) in
                view.frame = frame
                contentView.addSubview(view)
            }
            _caches = nil
            
        } else {
            // setup for show
            guard _caches == nil else {
                return // in display
            }
            _caches = contentView.subviews.map { view in
                let frame = view.frame
                view.frame = bounds
                addSubview(view)
                return (view, frame)
            }
        }
    }
    
    // cache frame before ownership transfer
    private var _caches: [(UIView, CGRect)]?
    // need to manage the view
    private weak var _contentView: UIView?
}
