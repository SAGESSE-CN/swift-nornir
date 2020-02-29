//
//  SAPBrowserView.swift
//  SAC
//
//  Created by SAGESSE on 9/29/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import Photos

@objc
internal protocol SAPBrowserViewDelegate: NSObjectProtocol {
    
    @objc optional func browserView(_ browserView: SAPBrowserView, photo: SAPAsset, didTapWith sender: AnyObject)
    @objc optional func browserView(_ browserView: SAPBrowserView, photo: SAPAsset, didDoubleTapWith sender: AnyObject)
    
    @objc optional func browserView(_ browserView: SAPBrowserView, shouldRotation photo: SAPAsset) -> Bool
    @objc optional func browserView(_ browserView: SAPBrowserView, didRotation photo: SAPAsset, orientation: UIImage.Orientation)
}

internal class SAPBrowserViewFastPreviewing: NSObject, SAPPreviewable {
    
    var view: UIView
    
    var photo: SAPAsset
    
    var previewingFrame: CGRect {
        
        let width = CGFloat(self.photo.pixelWidth)
        let height = CGFloat(self.photo.pixelHeight)
        
        if width < view.frame.width && height < view.frame.height {
            var nframe = view.frame
            
            nframe.origin.x = (nframe.width - width) / 2
            nframe.origin.y = (nframe.height - height) / 2
            nframe.size.width = width
            nframe.size.height = height
            
            return nframe
        }
        
        return view.frame
    }
    
    
    var previewingContent: Progressiveable? {
        return photo.imageItem
    }
    var previewingContentSize: CGSize {
        return photo.size
    }
    
    var previewingContentMode: UIView.ContentMode {
        return .scaleAspectFit
    }
    var previewingContentOrientation: UIImage.Orientation {
        return .up
    }
    
    init(photo: SAPAsset, view: UIView) {
        self.view = view
        self.photo = photo
        super.init()
    }
}


internal class SAPBrowserView: UIView, SAPPreviewable {
    
    var previewingContent: Progressiveable? {
        return _imageView.progressiveValue(forKey: "image")
    }
    var previewingContentSize: CGSize {
        return photo?.size ?? .zero
    }
    var previewingContentVisableSize: CGSize {
        return SAPhotoMaximumSize
    }
    
    var previewingContentMode: UIView.ContentMode {
        return .scaleAspectFit
    }
    var previewingContentOrientation: UIImage.Orientation {
        return photoContentOrientation
    }
    
    var previewingFrame: CGRect {
        guard let view = _imageView.superview else {
            return .zero
        }
        return view.convert(_imageView.frame, to: window)
    }
    
    var photoContentOrientation: UIImage.Orientation {
        set { return _orientation = newValue }
        get { return _orientation }
    }
    var photo: SAPAsset? {
        willSet {
          
            _containterView.contentSize = newValue?.size ?? .zero
            _containterView.zoom(to: _containterView.bounds, with: .up, animated: false)
            
            guard let newValue = newValue else {
                _imageView.setProgressiveValue(nil, forKey: "image")
                return
            }
            let options = SAPRequestOptions(size: newValue.size)
            let task = SAPLibrary.shared.imageTask(with: newValue, options: options)
            
            _imageView.setProgressiveValue(task, forKey: "image")
            
        }
    }
    
    weak var delegate: SAPBrowserViewDelegate? {
        set { return _delegate = newValue }
        get { return _delegate }
    }
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
////        if _cacheBounds?.width != bounds.width {
////            _restoreContent(loader?.size ?? .zero, oldBounds: _cacheBounds ?? bounds, animated: false)
////            _cacheBounds = bounds
////        }
//    }
//    private func _rotation(for orientation: UIImage.Orientation) -> CGFloat {
//        switch orientation {
//        case .up,
//             .upMirrored:
//            return 0 * CGFloat(M_PI_2)
//        case .right,
//             .rightMirrored:
//            return 1 * CGFloat(M_PI_2)
//        case .down,
//             .downMirrored:
//            return 2 * CGFloat(M_PI_2)
//        case .left,
//             .leftMirrored:
//            return 3 * CGFloat(M_PI_2)
//        }
//    }
//    private func _orientation(for rotation: CGFloat) -> UIImage.Orientation {
//        switch Int(rotation / CGFloat(M_PI_2)) % 4 {
//        case 0:     return .up
//        case 1, -3: return .right
//        case 2, -2: return .down
//        case 3, -1: return .left
//        default:    return .up
//        }
//    }
//    
//    private func _minimumZoomScale(_ size: CGSize) -> CGFloat {
//        return 1
//    }
//    private func _maximumZoomScale(_ size: CGSize) -> CGFloat {
//        let scale = _aspectFitZoomScale(size)
//        let width = max(size.width * scale, 1)
//        let height = max(size.height * scale, 1)
//        return max(max(size.width / width, size.height / height), 2)
//    }
//    private func _aspectFitZoomScale(_ size: CGSize) -> CGFloat {
//        let width = max(size.width, 1)
//        let height = max(size.height, 1)
//        return min(min(bounds.width, width) / width, min(bounds.height, height) / height)
//    }
//    
//    private func _sizeThatFits(_ size: CGSize) {
//
//        let scale = _aspectFitZoomScale(size)
//        let minimumZoomScale = _minimumZoomScale(size)
//        let maximumZoomScale = _maximumZoomScale(size)
//        
//        let fit = CGSize(width: size.width * scale, height: size.height * scale)
//        let nbounds = CGRect(origin: .zero, size: fit)
//        
//        _scrollView.minimumZoomScale = minimumZoomScale
//        _scrollView.maximumZoomScale = maximumZoomScale
//        _scrollView.zoomScale = 1
//        
//        _imageView.frame = nbounds.applying(transform)
//        _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
//    }
//    
//    private func _restoreContent(_ size: CGSize, oldBounds: CGRect, animated: Bool) {
//        _logger.trace()
//        
//        let fitZoomScale = _aspectFitZoomScale(size)
//        let minimumZoomScale = _minimumZoomScale(size)
//        let maximumZoomScale = _maximumZoomScale(size)
//        
//        let zoomScaleRatio = (_scrollView.zoomScale - _scrollView.minimumZoomScale) / (_scrollView.maximumZoomScale - _scrollView.minimumZoomScale)
//        let zoomScale = (minimumZoomScale + (maximumZoomScale - minimumZoomScale) * zoomScaleRatio)
//        
//        let pt = _scrollView.contentOffset
//        let npt = pt
//        
//        _imageView.bounds = CGRect(x: 0, y: 0, width: size.width * fitZoomScale, height: size.height * fitZoomScale)
//        _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
//        
//        _scrollView.minimumZoomScale = minimumZoomScale
//        _scrollView.maximumZoomScale = maximumZoomScale
//        _scrollView.zoomScale = zoomScale
//        
//        _scrollView.setContentOffset(npt, animated: animated)
//    }
//    
////    fileprivate func _updateContent(for loader: SAPhotoLoaderType, animated: Bool) {
////        //_logger.trace()
////        
////        _imageView.image = loader.image
////        _sizeThatFits(loader.size ?? .zero)
////    }
//    fileprivate func _updateOrientation(for rotation: CGFloat, animated: Bool) {
//        guard let photo = photo else {
//            return // is error
//        }
//        
//        //_logger.trace(rotation)
//        
//        let angle = round(rotation / CGFloat(M_PI_2)) * CGFloat(M_PI_2)
//        
//        let oldOrientation = photoContentOrientation
//        let newOrientation = _orientation(for: _rotation(for: oldOrientation) + angle)
//        
//        // 如果旋转的角度没有超过阀值或者没有设置图片, 那么放弃手势
//        guard oldOrientation != newOrientation else {
//            guard animated else {
//                _scrollView.transform = .identity
//                _delegate?.browserView?(self, photo: photo, didRotation: newOrientation)
//                return
//            }
//            UIView.animate(withDuration: 0.35, animations: { [_scrollView] in
//                _scrollView.transform = .identity
//            }, completion: { [_delegate] b in
//                _delegate?.browserView?(self, photo: photo, didRotation: newOrientation)
//            })
//            return
//        }
//        // 生成新的图片(符合方向的)
//        photoContentOrientation = newOrientation
//        
//        let oldImage = _imageView.image
//        
//        let newSize = photo.size(with: newOrientation)
//        let newImage = oldImage?.withOrientation(newOrientation)
//        
//        let scale = _aspectFitZoomScale(newSize)
//        let minimumZoomScale = _minimumZoomScale(newSize)
//        let maximumZoomScale = _maximumZoomScale(newSize)
//        
//        let nbounds = CGRect(x: 0, y: 0, width: newSize.width * scale, height: newSize.height * scale)
//        let transform = CGAffineTransform(rotationAngle: angle)
//        let ignoreContentOffsetChanges = _scrollView.ignoreContentOffsetChanges
//        
//        // version 2
//        UIView.animate(withDuration: 0.35, animations: { [_scrollView, _imageView] in
//            
//            _scrollView.transform = transform
//            _scrollView.frame = self.bounds
//            
//            _scrollView.minimumZoomScale = minimumZoomScale
//            _scrollView.maximumZoomScale = maximumZoomScale
//            _scrollView.zoomScale = 1
//            
//            _scrollView.contentSize = self.bounds.size
//            _scrollView.setContentOffset(.zero, animated: false)
//            _scrollView.ignoreContentOffsetChanges = false
//            
//            _imageView.frame = nbounds.applying(transform)
//            _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
//            
//        }, completion: { [_scrollView, _imageView, _delegate] b in
//            
//            _scrollView.transform = .identity
//            _scrollView.frame = self.bounds
//            _scrollView.contentSize = self.bounds.size
//            _scrollView.ignoreContentOffsetChanges = ignoreContentOffsetChanges
//            
//            _imageView.image = newImage
//            _imageView.frame = nbounds
//            _imageView.center = CGPoint(x: _scrollView.bounds.midX, y: _scrollView.bounds.midY)
//            
//            _delegate?.browserView?(self, photo: photo, didRotation: newOrientation)
//        })
//    }
//    
    private func _init() {
        
        _tapGestureRecognizer.require(toFail: _doubleTapGestureRecognizer)
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2
        
        _containterView.frame = bounds
        _containterView.delegate = self
        _containterView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        _containterView.addSubview(_imageView)
        _containterView.addGestureRecognizer(_tapGestureRecognizer)
        _containterView.addGestureRecognizer(_doubleTapGestureRecognizer)
        
        addSubview(_containterView)

    }
//
//    fileprivate var _isRotationing: Bool = false {
//        willSet {
//            // 旋转的时候锁定缩放和移动事件
//            //_imageView.ignoreTransformChanges = newValue
//            //_scrollView.ignoreContentOffsetChanges = newValue
//        }
//    }
//    
//    private var _cacheBounds: CGRect?
//    
    
    fileprivate var _orientation: UIImage.Orientation = .up
    
    fileprivate weak var _delegate: SAPBrowserViewDelegate?

    fileprivate lazy var _tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler(_:)))
    fileprivate lazy var _doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler(_:)))
    
    fileprivate lazy var _imageView: SAPImageView = SAPImageView()
    fileprivate lazy var _containterView: SAPContainterView = SAPContainterView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        _init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        _init()
    }
//}
//
//private extension SAPBrowserView {
//    
    @objc dynamic func tapHandler(_ sender: AnyObject) {
        guard let photo = photo else {
            return
        }
        //_logger.trace()
        _delegate?.browserView?(self, photo: photo, didTapWith: sender)
    }
//    dynamic func rotationHandler(_ sender: UIRotationGestureRecognizer) {
//        guard let photo = photo else {
//            return
//        }
//        //_logger.trace(sender.rotation)
//        
//        guard sender.state == .ended || sender.state == .cancelled || sender.state == .failed else {
//            // 开始旋转
//            if !_isRotationing {
//                guard _delegate?.browserView?(self, photo: photo, shouldRotation: photoContentOrientation) ?? true else {
//                    return // .. 不允许旋转
//                }
//                _isRotationing = true
//            }
//            _scrollView.transform = CGAffineTransform(rotationAngle: sender.rotation)
//            return
//        }
//        guard _isRotationing else {
//            return // 并没有开始旋转
//        }
//        // 停止旋转
//        _isRotationing = false
//        _updateOrientation(for: sender.rotation, animated: true)
//    }
    @objc dynamic func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        guard let photo = photo else {
            return
        }
         _logger.trace()
        
        if _containterView.zoomScale != _containterView.minimumZoomScale {
            _containterView.setZoomScale(_containterView.minimumZoomScale, at: sender.location(in: _imageView), animated: true)
        } else {
            _containterView.setZoomScale(_containterView.maximumZoomScale, at: sender.location(in: _imageView), animated: true)
        }
        
        delegate?.browserView?(self, photo: photo, didDoubleTapWith: sender)
    }
//
//}
//
//extension SAPBrowserView: UIGestureRecognizerDelegate {
//    
//    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
//        if otherGestureRecognizer.view === _scrollView {
//            return true
//        }
//        return false
//    }
}

extension SAPBrowserView: SAPContainterViewDelegate {
    
    public func viewForZooming(in containterView: SAPContainterView) -> UIView? {
        return _imageView
    }
    
    func containterViewShouldBeginRotationing(_ containterView: SAPContainterView, with view: UIView?) -> Bool {
        guard let photo = photo else {
            return false
        }
        return _delegate?.browserView?(self, shouldRotation: photo) ?? true
    }
    func containterViewDidEndRotationing(_ containterView: SAPContainterView, with view: UIView?, atOrientation orientation: UIImage.Orientation) {
        guard let photo = photo else {
            return
        }
        _orientation = orientation
//        _imageView.image = _imageView.image?.withOrientation(orientation)
        _delegate?.browserView?(self, didRotation: photo, orientation: orientation)
    }
}
