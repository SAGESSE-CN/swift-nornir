//
//  AnimatedImage.swift
//  Ubiquity
//
//  Created by SAGESSE on 5/14/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//  
//  Original Author
//    Project https://github.com/Flipboard/FLAnimatedImage
//    Created by Raphael Schaad on 7/8/13.
//    Copyright (c) 2013-2015 Flipboard. All rights reserved.
//

import UIKit
import ImageIO
import MobileCoreServices


internal class AnimatedImage: UIImage {
    
    init?(source: CGImageSource) {
        // check whether the type support
        guard let type = CGImageSourceGetType(source), UTTypeConformsTo(type, kUTTypeGIF) else {
            return nil
        }
        // try prase gif file
        guard let info = AnimatedImageInfo(source: source) else {
            return nil
        }
        // init
        _info = info
        _source = source
        
        super.init()
    }
    
    convenience init?(named name: String) {
        self.init(named: name, in: nil, compatibleWith: nil)
    }

    convenience init?(named name: String, in bundle: Bundle?, compatibleWith traitCollection: UITraitCollection?) {
        // not found
        let ext = (name as NSString).pathExtension.isEmpty ? "gif" : ""
        guard let url = (bundle ?? .main).url(forResource: name, withExtension: ext) else {
            return nil
        }
        // try to load the file
        guard let data = try? Data(contentsOf: url) else {
            return nil
        }
        // create a image data source
        guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
            return nil
        }
        // create image
        self.init(source: source)
    }
    
    required convenience init(imageLiteralResourceName name: String) {
        self.init(named: name)!
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var size: CGSize {
        // check whether there is a frame
        guard _info.frameCount != 0 else {
            return .zero
        }
        let frame = _info.frame(at: 0)
        return .init(width: frame.pixelWidth, height: frame.pixelHeight)
    }
    override var cgImage: CGImage? {
        // if already have cache, don't load
        if let image = _cgImage {
            return image
        }
        // check whether there is a frame
        guard _info.frameCount != 0 else {
            return nil
        }
        let frame = _info.frame(at: 0)
        _cgImage = frame.cgImage
        return frame.cgImage
    }
    
    func cache(at index: Int) -> AnimatedImageFrameInfo {
        // must has any change
        if _index != index {
            _index = index
            _start()
        }
        // return current frame
        return frame(at: index)
    }
    func clear() {
        
        _stop()
        _queue.async {
            // clear all objects
            self._cache.removeAllObjects()
            self._cachedIndexs.removeAll()
        }
    }
    
    var loopCount: Int {
        return _info.loopCount
    }
    
    var frameCount: Int {
        return _info.frameCount
    }
    func frame(at index: Int) -> AnimatedImageFrameInfo {
        return _info.frame(at: index)
    }
    
    private func _start() {
        // if not runing, start
        guard !_starting && !_runing else {
            return
        }
        _runing = false
        _starting = true
        _queue.async {
            self._process()
        }
    }
    private func _process() {
        // if it's cancelled on the way, ignore
        guard _starting else {
            return
        }
        let frameCount = _info.frameCount
        let predrawCount = min(3, frameCount)
        // if there is only one frame, no cache is needed
        guard frameCount > 1 else {
            return
        }
        var cache = 0
        var offset = 0
        // always running
        _runing = true
        _starting = false
        
        while _runing {
            // gets the index that is currently being displayed
            guard let current = _index else {
                return
            }
            // check the cache expired
            if cache != current {
                cache = current
                // resets offset in case of cache expired
                offset = 0
                // clear expired cache
                let required = Set((current ..< current + predrawCount).map {
                    return $0 % frameCount
                })
                // find the currently expired frame
                let expired = _cachedIndexs.filter{ index in
                    return !required.contains(index)
                }
                // clear expired frame
                expired.forEach { index in
                    _cache.removeObject(forKey: index as AnyObject)
                    _cachedIndexs.remove(index)
                }
            }
            // convert to real index 
            let index = (current + offset) % frameCount
            
            // if the frame has been cached, ignore
            if !_cachedIndexs.contains(index) {
                // start pre render
                if let image = _info.frame(at: index).predraw(), _runing {
                    // save render results
                    _cachedIndexs.insert(index)
                    _cache.setObject(image, forKey: index as AnyObject)
                }
            }
            
            // only processing `count` frame
            guard offset < predrawCount else {
                break
            }
            // move to next frame
            offset += 1
        }
        _starting = false
        _runing = false
    }
    private func _stop() {
        // if is runing or starting, stop
        guard _starting || _runing else {
            return
        }
        _runing = false
        _starting = false
    }
    
    // status
    private var _runing: Bool = false
    private var _starting: Bool = false
    
    private var _info: AnimatedImageInfo
    private var _index: Int?
    private var _source: CGImageSource
    
    private var _cgImage: CGImage? // cache forever the first frame
    
    private lazy var _cache: NSCache<AnyObject, CGImage> = .init()
    private lazy var _cachedIndexs: Set<Int> = []
    
    private lazy var _queue: DispatchQueue = .init(label: "ubiquity.custom-image.decode")
}
internal class AnimatedImageView: UIImageView {
    // forward helper
    internal class AnimatedImageViewHelper: NSObject {
        init(target: AnimatedImageView) {
            self.target = target
            super.init()
        }
        dynamic func update(_ sender: CADisplayLink) {
            target.update(sender)
        }
        unowned(unsafe) var target: AnimatedImageView
    }
    
    deinit {
        // clear
        _link?.invalidate()
        _image?.clear()
    }
    
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        
        if window == nil {
            // hide, pause
            if _starting {
                _link?.isPaused = true
            }
        } else {
            // show, restore
            if _starting {
                _link?.isPaused = false
            }
        }
    }
    
    override var image: UIImage? {
        set {
            // Stop animating before the animated image gets cleared out.
            if _starting {
                stopAnimating()
            }
            super.image = newValue
            
            _image = newValue as? AnimatedImage
            _loopCount = 0
            
            // Start animating after the new animated image has been set.
            if shouldAnimate {
                startAnimating()
            }
        }
        get {
            return super.image
        }
    }
    
    override func startAnimating() {
        // only process custom image
        guard let _ = _image else {
            // using the original method
            return super.startAnimating()
        }
        // Lazily create the display link.
        if _link == nil {
            // It is important to note the use of a weak proxy here to avoid a retain cycle. `-displayLinkWithTarget:selector:`
            // will retain its target until it is invalidated. We use a weak proxy so that the image view will get deallocated
            // independent of the display link's lifetime. Upon image view deallocation, we invalidate the display
            // link which will lead to the deallocation of both the display link and the weak proxy.
            _link = CADisplayLink(target: AnimatedImageViewHelper(target: self), selector: #selector(update(_:)))
            
            // Note: The display link's `.frameInterval` value of 1 (default) means getting callbacks at the refresh rate of the display (~60Hz).
            _link?.add(to: .main, forMode: .commonModes)
        }
        // if is in display, cancel the pause
        if window != nil {
            _link?.isPaused = false
        }
        _starting = true
    }
    override func stopAnimating() {
        // only process custom image
        guard let _ = _image else {
            // using the original method
            return super.stopAnimating()
        }
        // suspended
        _link?.isPaused = true
        _starting = false
    }
    
    override var isAnimating: Bool {
        // only process custom image
        guard let _ = _image else {
            // using the original method
            return super.isAnimating
        }
        // display link runing equ to animating
        return !(_link?.isPaused ?? true)
    }
    
    var shouldAnimate: Bool {
        return (_image?.frameCount ?? 0) > 1
    }
    
    func update(_ sender: CADisplayLink) {
        // only process custom image
        guard let image = _image, _index < image.frameCount else {
            return
        }
        
        // move time
        _accumulator += sender.duration
        
        // While-loop first inspired by & good Karma to: https://github.com/ondalabs/OLImageView/blob/master/OLImageView.m
        while _accumulator > 0 {
            // get current frame info
            let frame = image.frame(at: _index)
            guard _accumulator >= frame.duration else {
                break
            }
            // move to next frame
            _index += 1
            _accumulator -= frame.duration
            // if the index cross-border, switch to the next loop
            guard _index >= image.frameCount else {
                break
            }
            _index = 0
            _loopCount = min(_loopCount + 1, image.loopCount)
            // if the last loop, stop the animation
            guard _loopCount == image.loopCount, _loopCount != 0 else {
                break
            }
            _loopCount = 0
            stopAnimating()
        }
        
        // update cache if needed
        if _cachedFrame?.index != _index {
            _cachedFrame = image.cache(at: _index)
            _needsDisplayWhenImageBecomesAvailable = true
        }
        // update content if needed
        if _needsDisplayWhenImageBecomesAvailable && _cachedFrame?.cgImageWithPredraw != nil {
            _needsDisplayWhenImageBecomesAvailable = false
            // updat content
            layer.setNeedsDisplay()
        }
    }
    
    override func display(_ layer: CALayer) {
        // update content
        layer.contents = _cachedFrame?.cgImageWithPredraw
    }
    
    private var _link: CADisplayLink?
    private var _starting: Bool = false
    
    private var _index: Int = 0
    private var _loopCount: Int = 0
    private var _accumulator: TimeInterval = 0
    
    private var _cachedFrame: AnimatedImageFrameInfo?
    private var _needsDisplayWhenImageBecomesAvailable: Bool = false
    
    private var _image: AnimatedImage?
}


internal class AnimatedImageInfo: NSObject {
    // Note: 0 means repeating the animation indefinitely.
    // Image properties example:
    // {
    //     FileSize = 314446;
    //     "{GIF}" = {
    //         HasGlobalColorMap = 1;
    //         LoopCount = 0;
    //     };
    // }
    init?(source: CGImageSource) {
        // fetch properties information
        guard let properties: NSDictionary = CGImageSourceCopyProperties(source, nil) else {
            return nil
        }
        // must include the GIF info
        guard let subproperties = properties[kCGImagePropertyGIFDictionary] as? NSDictionary else {
            return nil
        }
        // get frame info
        let loopCount = subproperties[kCGImagePropertyGIFLoopCount] as? Int ?? 0
        let hasGlobalColorMap = subproperties[kCGImagePropertyGIFHasGlobalColorMap] as? Bool ?? false
        
        var last: AnimatedImageFrameInfo?
        let count: Int = CGImageSourceGetCount(source)
        
        // Iterate through frame images
        let frames = (0 ..< count).flatMap { index -> AnimatedImageFrameInfo? in
            // must include the GIF info
            guard let info = AnimatedImageFrameInfo(source: source, at: index, previous: last) else {
                return nil
            }
            last = info
            return info
        }
        
        // init
        _frames = frames
        _loopCount = loopCount
        _hasGlobalColorMap = hasGlobalColorMap
        
        super.init()
    }
    
    var frameCount: Int {
        return _frames.count
    }
    func frame(at index: Int) -> AnimatedImageFrameInfo {
        return _frames[index]
    }

    /// The number of times to repeat an animated sequence.
    var loopCount: Int {
        return _loopCount
    }
    /// Whether or not the GIF has a global color map.
    var hasGlobalColorMap: Bool {
        return _hasGlobalColorMap
    }
    
    private let _loopCount: Int
    private let _hasGlobalColorMap: Bool
    
    private let _frames: Array<AnimatedImageFrameInfo>
    
    static let defaultDelayTime: TimeInterval = 0.1
    static let minimumDelayTime: TimeInterval = 0.02
}
internal class AnimatedImageFrameInfo: NSObject {
    // Note: It's not in (1/100) of a second like still falsely described in the documentation as per iOS 8 (rdar://19507384) but in seconds stored as `kCFNumberFloat32Type`.
    // Frame properties example:
    // {
    //     ColorModel = RGB;
    //     Depth = 8;
    //     PixelHeight = 960;
    //     PixelWidth = 640;
    //     "{GIF}" = {
    //         DelayTime = "0.4";
    //         UnclampedDelayTime = "0.4";
    //     };
    // }
    init?(source: CGImageSource, at index: Int, previous: AnimatedImageFrameInfo? = nil) {
        // fetch properties information
        guard let properties: NSDictionary = CGImageSourceCopyPropertiesAtIndex(source, index, nil) else {
            return nil
        }
        // must include the GIF info
        guard let subproperties = properties[kCGImagePropertyGIFDictionary] as? NSDictionary else {
            return nil
        }
        // fetch frame width
        guard let width = properties[kCGImagePropertyPixelWidth] as? Int else {
            return nil
        }
        // fetch frame height
        guard let height = properties[kCGImagePropertyPixelHeight] as? Int else {
            return nil
        }
        // fetch value from properties
        let delayTime = subproperties[kCGImagePropertyGIFDelayTime] as? TimeInterval
        let unclampedDelayTime = subproperties[kCGImagePropertyGIFUnclampedDelayTime] as? TimeInterval
        
        // If we don't get a delay time from the properties, fall back to `kDelayTimeIntervalDefault` or carry over the preceding frame's value.
        var duration = unclampedDelayTime ?? delayTime ?? previous?.duration ?? AnimatedImageInfo.defaultDelayTime
        
        // Support frame delays as low as `kDelayTimeIntervalMinimum`, with anything below being rounded up to `kDelayTimeIntervalDefault` for legacy compatibility.
        // This is how the fastest browsers do it as per 2012: http://nullsleep.tumblr.com/post/16524517190/animated-gif-minimum-frame-delay-browser-compatibility
        // To support the minimum even when rounding errors occur, use an epsilon when comparing. We downcast to float because that's what we get for delayTime from ImageIO.
        //if duration
        if (duration < (AnimatedImageInfo.minimumDelayTime - .ulpOfOne)) {
            duration = AnimatedImageInfo.defaultDelayTime
        }
        
        // init
        _pixelWidth = width
        _pixelHeight = height
        
        _depth = properties[kCGImagePropertyDepth] as? Int ?? 0
        _hasAlpha = properties[kCGImagePropertyHasAlpha] as? Bool ?? false
        _colorModel = properties[kCGImagePropertyColorModel] as? String
        
        _duration = duration
        _delayTime = delayTime
        _unclampedDelayTime = unclampedDelayTime
        
        _index = index
        _source = source
        _cgImage = CGImageSourceCreateImageAtIndex(source, index, nil)
        
        super.init()
    }
    
    var cgImage: CGImage? {
        return _cgImage
    }
    var cgImageWithPredraw: CGImage? {
        return _cgImageWithPredraw
    }
    
    // Decodes the image's data and draws it off-screen fully in memory; it's thread-safe and hence can be called on a background thread.
    // On success, the returned object is a new `UIImage` instance with the same content as the one passed in.
    // On failure, the returned object is the unchanged passed in one; the data will not be predrawn in memory though and an error will be logged.
    // First inspired by & good Karma to: https://gist.github.com/steipete/1144242
    func predraw() -> CGImage? {
        // if have the cache, direct display
        if let image = _cgImageWithPredraw {
            return image
        }
        // if is nil, do not need to create
        guard let image = _cgImage else {
            return nil
        }
        // Always use a device RGB color space for simplicity and predictability what will be going on.
        let space = CGColorSpaceCreateDeviceRGB()
        
        // Even when the image doesn't have transparency, we have to add the extra channel because Quartz doesn't support other pixel formats than 32 bpp/8 bpc for RGB:
        // kCGImageAlphaNoneSkipFirst, kCGImageAlphaNoneSkipLast, kCGImageAlphaPremultipliedFirst, kCGImageAlphaPremultipliedLast
        // (source: docs "Quartz 2D Programming Guide > Graphics Contexts > Table 2-1 Pixel formats supported for bitmap graphics contexts") - Latest Checked Date: Nov 1st 2015
        
        let numberOfComponents = space.numberOfComponents + 1 // [RGB + A] - The number of color components in the specified color space, not including the alpha value. For example, for an RGB color space, CGColorSpaceGetNumberOfComponents returns a value of 3.
        
        let width = image.width
        let height = image.height
        let bitsPerComponent = Int(CHAR_BIT)
        
        let bitsPerPixel = bitsPerComponent * numberOfComponents
        let bytesPerPixel = bitsPerPixel/Int(BYTE_SIZE)
        let bytesPerRow = bytesPerPixel * Int(width)
        
        let bitmapInfo: CGBitmapInfo = [.byteOrder32Little]
        var alphaInfo = image.alphaInfo
        
        // If the alpha info doesn't match to one of the supported formats (see above), pick a reasonable supported one.
        // "For bitmaps created in iOS 3.2 and later, the drawing environment uses the premultiplied ARGB format to store the bitmap data." (source: docs)
        switch alphaInfo {
        case .none, .alphaOnly:
            alphaInfo = .noneSkipFirst
            
        case .first:
            alphaInfo = .premultipliedFirst
            
        case .last:
            alphaInfo = .premultipliedLast
            
        default:
            break
        }
        
        // "The constants for specifying the alpha channel information are declared with the `CGImageAlphaInfo` type but can be passed to this parameter safely." (source: docs)
        let info = bitmapInfo.rawValue | alphaInfo.rawValue
        
        // Create our own graphics context to draw to; `UIGraphicsGetCurrentContext`/`UIGraphicsBeginImageContextWithOptions` doesn't create a new context but returns the current one which isn't thread-safe (e.g. main thread could use it at the same time).
        // Note: It's not worth caching the bitmap context for multiple frames ("unique key" would be `width`, `height` and `hasAlpha`), it's ~50% slower. Time spent in libRIP's `CGSBlendBGRA8888toARGB8888` suddenly shoots up -- not sure why.
        
        guard let context = CGContext(data: nil, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: space, bitmapInfo: info) else {
            return nil
        }
        
        // Draw image in bitmap context and create image by preserving receiver's properties.
        context.draw(image, in: .init(x: 0, y: 0, width: width, height: height))
        let newImage = context.makeImage()
        _cgImageWithPredraw = newImage
        return newImage
        
    }
    
    
    /// The number of bits in each color sample of each pixel. If present, this key is a CFNumber value.
    var depth: Int {
        return _depth
    }
    /// Whether or not the image has an alpha channel. The value of this key is kCFBooleanTrue if the image contains an alpha channel.
    var hasAlpha: Bool {
        return _hasAlpha
    }
    /// The color model of the image such as, RGB, CMYK, Gray, or Lab. The value of this key is of type CFStringRef.
    var colorModel: String? {
        return _colorModel
    }
    
    /// The number of pixels in the x dimension. If present, this key is a CFNumber value.
    var pixelWidth: Int {
        return _pixelWidth
    }
    /// The number of pixels in the y dimension. If present, this key is a CFNumber value.
    var pixelHeight: Int {
        return _pixelHeight
    }
    
    var index: Int {
        return _index
    }
    var duration: TimeInterval {
        return _duration
    }
    
    /// If a time of 50 milliseconds or less is specified, then the actual delay time stored in this parameter is 100 miliseconds. See kCGImagePropertyGIFUnclampedDelayTime.
    var delayTime: TimeInterval? {
        return _delayTime
    }
    /// The amount of time, in seconds, to wait before displaying the next image in an animated sequence. This value may be 0 milliseconds or higher. Unlike the kCGImagePropertyGIFDelayTime property, this value is not clamped at the low end of the range.
    var unclampedDelayTime: TimeInterval? {
        return _unclampedDelayTime
    }
    
    // normal
    private let _depth: Int
    private let _hasAlpha: Bool
    private let _colorModel: String?
    
    private let _pixelWidth: Int
    private let _pixelHeight: Int
    
    // gif
    private let _delayTime: TimeInterval?
    private let _unclampedDelayTime: TimeInterval?
    
    private var _index: Int
    private var _source: CGImageSource
    private var _duration: TimeInterval
    
    private var _cgImage: CGImage?
    private weak var _cgImageWithPredraw: CGImage?
}


private func _synchronized<Result>(token: Any, invoking body: () throws -> Result) rethrows -> Result {
    objc_sync_enter(token)
    defer {
        objc_sync_exit(token)
    }
    return try body()
}

