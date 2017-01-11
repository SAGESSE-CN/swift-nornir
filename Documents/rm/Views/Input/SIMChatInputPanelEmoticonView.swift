//
//  SIMChatInputPanelEmoticonView.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

// TODO: 暂未支持横屏
// TODO: tabbar显示未正常

/////
///// 表情面板代理
/////
//internal protocol SIMChatInputPanelEmoticonViewDelegate: SIMChatInputPanelDelegate {
//    ///
//    /// 获取表情组数量
//    ///
//    func numberOfGroupsInInputPanelEmoticon(_ inputPanel: UIView) -> Int
//    ///
//    /// 获取一个表情组
//    ///
//    func inputPanel(_ inputPanel: UIView, emoticonGroupAtIndex index: Int) -> SIMChatEmoticonGroup?
//    
//    ///
//    /// 将要选择表情, 返回false拦截该处理
//    ///
//    func inputPanel(_ inputPanel: UIView, shouldSelectEmoticon emoticon: SIMChatEmoticon) -> Bool
//    ///
//    /// 选择了表情
//    ///
//    func inputPanel(_ inputPanel: UIView, didSelectEmoticon emoticon: SIMChatEmoticon)
//    ///
//    /// 点击了返回, 返回false拦截该处理
//    ///
//    func inputPanelShouldReturn(_ inputPanel: UIView) -> Bool
//    ///
//    /// 点击了退格, 返回false拦截该处理
//    ///
//    func inputPanelShouldBackspace(_ inputPanel: UIView) -> Bool
//}
//
/////
///// 表情面板
/////
//internal class SIMChatInputPanelEmoticonView: UIView, SIMChatInputPanelProtocol {
//    /// 代理
//    weak var delegate: SIMChatInputPanelDelegate?
//    /// 创建面板
//    static func inputPanel() -> UIView {
//        return self.init()
//    }
//    /// 获取对应的Item
//    static func inputPanelItem() -> SIMChatInputItemProtocol {
//        let R = { (name: String) -> UIImage? in
//            return SIMChatBundle.imageWithResource("InputBar/\(name).png")
//        }
//        let item = SIMChatBaseInputItem("kb:emoticon", R("chat_bottom_emotion_nor"), R("chat_bottom_emotion_press"))
//        SIMChatInputPanelContainer.registerClass(self.self, byItem: item)
//        return item
//    }
//    
//    /// 初始化
//    @inline(__always) private func build() {
//        
//        // add view
//        addSubview(_contentView)
//        addSubview(_pageControl)
//        addSubview(_tabBar)
//        addSubview(_sendButton)
//        addSubview(_preview)
//        
//        // add layout
//        SIMChatLayout.make(_contentView)
//            .top.equ(self).top
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(_tabBar).top
//            .submit()
//        
//        SIMChatLayout.make(_pageControl)
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(_contentView).bottom(5)
//            .submit()
//        
//        SIMChatLayout.make(_tabBar)
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(self).bottom
//            .submit()
//        
//        SIMChatLayout.make(_sendButton)
//            .top.equ(_tabBar).top
//            .right.equ(_tabBar).right
//            .bottom.equ(_tabBar).bottom
//            .submit()
//        
//        
//        _contentView.reloadData()
//        
//        guard !_builtInGroups.isEmpty else {
//            return
//        }
//        DispatchQueue.main.async {
//            DispatchQueue.main.async {
//                // 查找默认显示的
//                let idx = (0 ..< self._contentView.numberOfSections).index {
//                    return self.groupAtIndex($0)?.isDefault ?? false
//                } ?? 0
//                // 检查有没有子组
//                var sidx = 0
//                var spidx = 0
//                if let group = self.groupAtIndex(idx), let subgroups = group.groups , !subgroups.isEmpty {
//                    var flag = false
//                    for sg in subgroups {
//                        if sg.isDefault {
//                            flag = true
//                            break
//                        }
//                        sidx += self._pages["\(group.identifier) => \(sg.identifier)"]?.count ?? 0
//                        spidx += 1
//                    }
//                    sidx = flag ? sidx : 0
//                }
//                
//                self._pageControl.tag = idx
//                self._pageControl.reloadData()
//                self._pageControl.currentPage = IndexPath(item: 0, section: spidx)
//                self._contentView.scrollToItem(at: IndexPath(item: sidx, section: idx),
//                    at: UICollectionViewScrollPosition(),
//                    animated: false)
//            }
//        }
//    }
//    
//    private lazy var _tabBar: SIMChatInputPanelTabBar = {
//        let view = SIMChatInputPanelTabBar()
//        view.backgroundColor = UIColor(rgb: 0xF8F8F8)
//        view.delegate = self
//        view.dataSource = self
//        view.scrollsToTop = false
//        return view
//    }()
//    private lazy var _preview: SIMChatInputPanelEmoticonPreview = {
//        let view = SIMChatInputPanelEmoticonPreview()
//        view.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
//        view.isHidden = true
//        return view
//    }()
//    private lazy var _sendButton: UIButton = {
//        let view = UIButton(type: .system)
//        view.tintColor = UIColor.white
//        view.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16)
//        view.setTitle("发送", for: UIControlState())
//        view.setBackgroundImage(UIImage(named: "tabwithinpage_cursor"), for: UIControlState())
//        view.addTarget(self, action: #selector(type(of: self).onReturnPress(_:)), for: .touchUpInside)
//        return view
//    }()
//    private lazy var _pageControl: SIMChatInputPanelPageControl = {
//        let view = SIMChatInputPanelPageControl()
//        view.delegate = self
//        view.pageIndicatorTintColor = UIColor.gray
//        view.currentPageIndicatorTintColor = UIColor.darkGray
////        view.hidesForSinglePage = true
//        view.isUserInteractionEnabled = false
//        return view
//    }()
//    private lazy var _contentView: UICollectionView = {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsetsZero
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
//        view.showsHorizontalScrollIndicator = false
//        view.showsVerticalScrollIndicator = false
//        view.isPagingEnabled = true
//        view.dataSource = self
//        view.delegate = self
//        view.scrollsToTop = false
//        view.backgroundColor = UIColor.white
//        
//        view.register(SIMChatInputPanelEmoticonCell.self, forCellWithReuseIdentifier: "Emoticon")
//        
//        return view
//    }()
//    
//    private var _pages: Dictionary<String, Array<SIMChatInputPanelEmoticonPage>> = [:]
//    private var _lastIndexPath: IndexPath?
//    private lazy var _builtInGroups: Array<SIMChatEmoticonGroup> = SIMChatBaseEmoticonGroup.loadGroupWithBuiltIn()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//}
//
//
/////
///// 底部菜单栏
/////
//internal class SIMChatInputPanelTabBar: UICollectionView {
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.scrollDirection = .horizontal
//        layout.sectionInset = UIEdgeInsetsZero
//        layout.minimumLineSpacing = 0
//        layout.minimumInteritemSpacing = 0
//        layout.itemSize = CGSize(width: 50, height: 37)
//        super.init(frame: CGRect.zero, collectionViewLayout: layout)
//        register(SIMChatInputPanelTabBarCell.self, forCellWithReuseIdentifier: "Item")
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//    }
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: bounds.width, height: 37)
//    }
//}
//
/////
///// 底部菜单项
/////
//internal class SIMChatInputPanelTabBarCell: UICollectionViewCell {
//    lazy var button: UIButton = {
//        let view = UIButton()
//        view.frame = self.contentView.bounds
//        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        view.isUserInteractionEnabled = false
//        //view.contentMode = .Center
//        self.contentView.addSubview(view)
//        return view
//    }()
//}
//
/////
///// 页面控制视图
/////
//internal class SIMChatInputPanelPageControl: UIView {
//    
//    var hidesForSinglePage: Bool = false
//    
//    var pageIndicatorTintColor: UIColor? = UIColor.gray
//    var currentPageIndicatorTintColor: UIColor? = UIColor.darkGray
//    
//    var currentPage: IndexPath = IndexPath(item: 0, section: 0) {
//        didSet {
//            guard (oldValue as NSIndexPath).row != currentPage.row || (oldValue as NSIndexPath).section != currentPage.section else {
//                return
//            }
//            if (oldValue as NSIndexPath).section != currentPage.section {
//                reloadPages()
//            } else {
//                if (oldValue as NSIndexPath).row < _pages.count {
//                    _pages[(oldValue as NSIndexPath).row].backgroundColor = pageIndicatorTintColor
//                }
//                if currentPage.row < _pages.count {
//                    _pages[currentPage.row].backgroundColor = currentPageIndicatorTintColor
//                }
//            }
//        }
//    }
//    
//    var _groups: Array<UIImageView> = []
//    var _pages: Array<UIView> = []
//    
//    var _pageGap: CGFloat = 4
//    var _pageWH: CGFloat = 7
//    
//    override func sizeThatFits(_ size: CGSize) -> CGSize {
//        var width = CGFloat(_pages.count) * (_pageWH + _pageGap) - _pageGap
//        var height = CGFloat(_pageWH)
//        _groups.enumerated().forEach {
//            width += ($0.element.image?.size.width ?? 0) + _pageGap
//            height = max($0.element.image?.size.height ?? 0, height)
//        }
//        return CGSize(width: width - _pageGap, height: height)
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//    }
//    
//    func reloadData() {
//        reloadSections()
//    }
//    
//    func reloadPages() {
//        let count = delegate?.pageControl(self, numberOfPagesInSection: currentPage.section) ?? 0
//        var tmp = _pages
//        _pages.removeAll()
//        (0 ..< count).forEach {
//            let view = tmp.popLast() ?? UIView()
//            view.layer.cornerRadius = _pageWH / 2
//            view.layer.masksToBounds = true
//            if currentPage.row == $0 {
//                view.backgroundColor = currentPageIndicatorTintColor
//            } else {
//                view.backgroundColor = pageIndicatorTintColor
//            }
//            _pages.append(view)
//            addSubview(view)
//        }
//        tmp.forEach {
//            $0.removeFromSuperview()
//        }
//        
//        updateLayout()
//    }
//    func reloadSections() {
//        // 更新组
//        if let count = delegate?.numberOfSectionsInPageControl(self) , count > 1 {
//            var tmp = _groups
//            _groups.removeAll()
//            (0 ..< count).forEach {
//                let view = tmp.popLast() ?? UIImageView()
//                view.image = delegate?.pageControl(self, imageOfSection: $0)
//                _groups.append(view)
//                addSubview(view)
//            }
//            tmp.forEach {
//                $0.removeFromSuperview()
//            }
//        } else {
//            _groups.forEach {
//                $0.removeFromSuperview()
//            }
//            _groups.removeAll()
//        }
//        
//        reloadPages()
//    }
//    
//    func updateLayout() {
//        let width = sizeThatFits(CGSize.zero).width
//        var x = (bounds.width - width) / 2
//        
//        if _groups.isEmpty {
//            _pages.forEach {
//                let size = CGSize(width: _pageWH, height: _pageWH)
//                $0.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                x += size.width + _pageGap
//            }
//        } else {
//            _groups.enumerated().forEach {
//                let size = $0.element.image?.size ?? CGSize.zero
//                $0.element.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                if $0.offset == currentPage.section {
//                    _pages.forEach {
//                        let size = CGSize(width: _pageWH, height: _pageWH)
//                        $0.frame = CGRect(x: x, y: (bounds.height - size.height) / 2, width: size.width, height: size.height)
//                        x += size.width + _pageGap
//                    }
//                    $0.element.isHidden = true
//                } else {
//                    x += size.width + _pageGap
//                    $0.element.isHidden = false
//                }
//            }
//        }
//    }
//    
//    weak var delegate: SIMChatInputPanelPageControlDelegate?
//  
//    override var intrinsicContentSize: CGSize {
//        return CGSize(width: bounds.width, height: 25)
//    }
//}
//
/////
///// 页面控制视图代理
/////
//internal protocol SIMChatInputPanelPageControlDelegate: class {
//    func numberOfSectionsInPageControl(_ pageControl: SIMChatInputPanelPageControl) -> Int
//    func pageControl(_ pageControl: SIMChatInputPanelPageControl, numberOfPagesInSection section: Int) -> Int
//    func pageControl(_ pageControl: SIMChatInputPanelPageControl, imageOfSection section: Int) -> UIImage?
//}
//
/////
///// 表情预览视图
/////
//internal class SIMChatInputPanelEmoticonPreview: UIView {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//    private func build() {
//        layer.contents = SIMChatImageManager.images_face_preview?.cgImage
//    }
//    
//    var value: SIMChatEmoticon? {
//        didSet {
//            guard value !== oldValue else {
//                return
//            }
//            guard let value = self.value else {
//                return
//            }
//            
//            if value.type == 0 {
//                guard let image = value.png else {
//                    return
//                }
//                imageView.image = image
//                imageView.frame = CGRect(x: (bounds.width - image.size.width) / 2,
//                    y: (bounds.height - image.size.height) / 2 - 4,
//                    width: image.size.width,
//                    height: image.size.height)
//                if imageView.superview != self {
//                    addSubview(imageView)
//                }
//                label.removeFromSuperview()
//            } else {
//                label.text = value.code as String
//                label.frame = bounds
//                label.sizeToFit()
//                label.frame = CGRect(
//                    x: (bounds.width - label.bounds.width) / 2,
//                    y: (bounds.height - label.bounds.height) / 2 - 4,
//                    width: label.bounds.width,
//                    height: label.bounds.height)
//                if label.superview != self {
//                    addSubview(label)
//                }
//                imageView.removeFromSuperview()
//            }
//        }
//    }
//    
//    lazy var label: UILabel = {
//        let view = UILabel()
//        view.font = UIFont.systemFont(ofSize: 32)
//        return view
//    }()
//    lazy var imageView: UIImageView = {
//        let view = UIImageView()
//        return view
//    }()
//}
//
/////
///// 表情面板中的每一个表情视图
/////
//internal class SIMChatInputPanelEmoticonCell: UICollectionViewCell, UIGestureRecognizerDelegate {
//    
//    var page: SIMChatInputPanelEmoticonPage? {
//        didSet {
//            guard let page = self.page , oldValue !== page else {
//                return
//            }
//            DispatchQueue.global(attributes: DispatchQueue.GlobalAttributes(rawValue: UInt64(0))).async {
//                let image = page.content ?? self.drawToImage()
//                DispatchQueue.main.async {
//                    guard self.page === page else {
//                        return
//                    }
//                    self.page?.content = image
//                    self.contentView.layer.contents = image?.cgImage
//                }
//            }
//        }
//    }
//    
//    
//    @inline(__always) func build() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(type(of: self).onItemPress(_:)))
//        tap.delegate = self
//        gestureRecognizer.delegate = self
//        
//        contentView.addGestureRecognizer(tap)
//        contentView.addGestureRecognizer(gestureRecognizer)
//    }
//    
//    /// 代理
//    weak var preview: SIMChatInputPanelEmoticonPreview?
//    weak var delegate: SIMChatInputPanelEmoticonCellDelegate?
//    
//    var maximumItemCount: Int = 7
//    var maximumLineCount: Int = 3
//    var contentInset: UIEdgeInsets = UIEdgeInsetsMake(12, 10, 42, 10)
//    
//    /// 布局发生改变
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        
//        let size = itemSize
//        var frame = CGRect.zero
//        
//        frame.origin.x = contentInset.left + CGFloat(maximumItemCount - 1) * size.width
//        frame.origin.y = contentInset.top + CGFloat(maximumLineCount - 1) * size.height
//        frame.size.width = size.width
//        frame.size.height = size.height
//        
//        backspaceButton.frame = frame
//        
//        if backspaceButton.superview != contentView {
//            contentView.addSubview(backspaceButton)
//        }
//    }
//    
//    // 绘制为图片
//    @inline(__always) func drawToImage() -> UIImage? {
//        guard let page = self.page else {
//            return nil
//        }
//        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
//        defer { UIGraphicsEndImageContext() }
//        
//        let size = itemSize
//        let config = [
//            NSFontAttributeName: UIFont.systemFont(ofSize: 32)
//        ]
//        page.emoticons.enumerated().forEach {
//            guard page === self.page else {
//                return
//            }
//            let row = $0.offset / maximumItemCount
//            let col = $0.offset % maximumItemCount
//            
//            if $0.element.type == 0 {
//                guard let image = $0.element.png else {
//                    return
//                }
//                var frame = CGRect.zero
//                
//                frame.origin.x = contentInset.left + CGFloat(col) * size.width
//                frame.origin.y = contentInset.top + CGFloat(row) * size.height
//                
//                frame.size = image.size
//                frame.origin.x += (size.width - frame.size.width) / 2
//                frame.origin.y += (size.height - frame.size.height) / 2
//                
//                image.draw(in: frame)
//            } else {
//                let value = $0.element.code as NSString
//                var frame = CGRect.zero
//                
//                frame.origin.x = contentInset.left + CGFloat(col) * size.width
//                frame.origin.y = contentInset.top + CGFloat(row) * size.height
//                
//                frame.size = value.size(attributes: config)
//                frame.origin.x += (size.width - frame.size.width) / 2
//                frame.origin.y += (size.height - frame.size.height) / 2
//                
//                value.draw(in: frame, withAttributes: config)
//            }
//        }
//        guard page === self.page else {
//            return nil
//        }
//        return UIGraphicsGetImageFromCurrentImageContext()
//    }
//    
//    // 计算index
//    func indexAtPoint(_ pt: CGPoint) -> Int? {
//        let x = pt.x - contentInset.left
//        let y = pt.y - contentInset.right
//        let width = bounds.width - contentInset.left - contentInset.right
//        let height = bounds.height - contentInset.top - contentInset.bottom
//        let size = itemSize
//        guard x >= 0 && x <= width && y >= 0 && y <= height else {
//            return nil
//        }
//        let row = Int(y / size.height)
//        let column = Int(x / size.width)
//        return row * maximumItemCount + column
//    }
//    
//    /// 点击事件
//    dynamic func onItemPress(_ sender: UITapGestureRecognizer) {
//        guard sender.state == .ended else {
//            return
//        }
//        guard let index = indexAtPoint(sender.location(in: self)) , index < (page?.emoticons.count)! else {
//            return
//        }
//        guard let item = page?.emoticons[index] else {
//            return
//        }
//        SIMLog.trace("index: \(index), value: \(item.code)")
//        if delegate?.emoticonCell(self, shouldSelectItem: item) ?? true {
//            delegate?.emoticonCell(self, didSelectItem: item)
//        }
//    }
//    /// 长按事件
//    dynamic func onItemLongPress(_ sender: UILongPressGestureRecognizer) {
//        guard let preview = self.preview else {
//            return
//        }
//        let pt = sender.location(in: self)
//        // 开始的时候, 计算一下选择的是那一个.
//        if sender.state == .began {
//            guard let index = indexAtPoint(pt) , index < (page?.emoticons.count)! else {
//                return
//            }
//            guard let item = page?.emoticons[index] else {
//                return
//            }
//            
//            let size = itemSize
//            let row = index / maximumItemCount
//            let column = index % maximumItemCount
//            
//            SIMLog.trace("index: \(index), value: \(item.code)")
//            
//            selectedPoint = CGPoint(
//                x: contentInset.left + CGFloat(column) * size.width,
//                y: contentInset.top + CGFloat(row) * size.height)
//            
//            preview.value = item
//            preview.isHidden = false
//        }
//        /// 事件结束的时候检查区域
//        if sender.state == .ended || sender.state == .cancelled || sender.state == .failed {
//            guard let selected = selectedPoint else {
//                return
//            }
//            guard let item = preview.value, let index = page?.emoticons.index(where: { $0.code == item.code }) else {
//                preview.isHidden = true
//                return
//            }
//            
//            // 计算距离, sqr(x^2 + y^2)
//            let distance = fabs(sqrt(pow(preview.frame.midX - selected.x, 2) + pow(preview.frame.maxY - selected.y, 2)))
//            let size = itemSize
//            
//            SIMLog.trace("index: \(index), value: \(item.code), distance: \(Int(distance))")
//            // 只有正常结束的时候少有效
//            if sender.state == .ended && CGRect(x: selected.x, y: selected.y, width: size.width, height: size.height).contains(pt) {
//                if delegate?.emoticonCell(self, shouldSelectItem: item) ?? true {
//                    delegate?.emoticonCell(self, didSelectItem: item)
//                }
//            }
//            
//            UIView.animate(withDuration: 0.25 * max(Double(distance / 100), 1),
//                animations: {
//                    var frame = preview.frame
//                    frame.origin.x = (selected.x + size.width / 2) - frame.width / 2
//                    frame.origin.y = (selected.y + 12) - frame.height
//                    preview.frame = frame
//                },
//                completion: { b in
//                    preview.isHidden = true
//            })
//            selectedPoint = nil
//        }
//        if selectedPoint != nil {
//            var frame = preview.frame
//            frame.origin.x = pt.x - frame.width / 2
//            frame.origin.y = pt.y - frame.height
//            preview.frame = frame
//        }
//    }
//    /// 删除事件
//    dynamic func onBackspacePress(_ sender: AnyObject) {
//        SIMLog.trace()
//        if delegate?.emoticonCellShouldBackspace(self) ?? true {
//            delegate?.emoticonCellDidBackspace(self)
//        }
//    }
//    
//    @objc override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
//        let pt = gestureRecognizer.location(in: contentView)
//        // 在区域内
//        let x = contentInset.left
//        let y = contentInset.right
//        let width = bounds.width - contentInset.left - contentInset.right
//        let height = bounds.height - contentInset.top - contentInset.bottom
//        if !CGRect(x: x, y: y, width: width, height: height).contains(pt) {
//            return false
//        }
//        return !backspaceButton.frame.contains(pt)
//    }
//    
//    var selectedPoint: CGPoint?
//    var itemSize: CGSize {
//        let width = bounds.width - contentInset.left - contentInset.right
//        let height = bounds.height - contentInset.top - contentInset.bottom
//        return CGSize(width: width / CGFloat(maximumItemCount), height: height / CGFloat(maximumLineCount))
//    }
//    lazy var backspaceButton: UIButton = {
//        let view = UIButton()
//        view.addTarget(self, action: #selector(SIMChatInputPanelEmoticonCell.onBackspacePress(_:)), for: .touchUpInside)
//        
//        view.setImage(SIMChatImageManager.images_face_delete_nor, for: UIControlState())
//        view.setImage(SIMChatImageManager.images_face_delete_press, for: .highlighted)
//        return view
//    }()
//    private lazy var gestureRecognizer: UIGestureRecognizer = {
//        let recognzer = UILongPressGestureRecognizer(target: self, action: #selector(type(of: self).onItemLongPress(_:)))
//        recognzer.minimumPressDuration = 0.25
//        return recognzer
//    }()
//    
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        build()
//    }
//}
//
/////
///// 表情面板中的每一个表情视图代理
/////
//internal protocol SIMChatInputPanelEmoticonCellDelegate: class {
//    
//    func emoticonCell(_ emoticonCell: UIView, shouldSelectItem item: SIMChatEmoticon) -> Bool
//    func emoticonCell(_ emoticonCell: UIView, didSelectItem item: SIMChatEmoticon)
//    
//    func emoticonCellShouldBackspace(_ emoticonCell: UIView) -> Bool
//    func emoticonCellDidBackspace(_ emoticonCell: UIView)
//}
//
/////
///// 一页表情(为提高速度, 整页生成)
/////
//internal class SIMChatInputPanelEmoticonPage {
//    ///
//    /// 把Group转为Page
//    ///
//    static func makeWithGroup(_ group: SIMChatEmoticonGroup) -> Array<SIMChatInputPanelEmoticonPage> {
//        return makeWithEmoticons(group.emoticons).map {
//            $0.group = group
//            return $0
//        }
//    }
//    ///
//    /// 使用表情
//    ///
//    static func makeWithEmoticons(_ emoticons: Array<SIMChatEmoticon>) -> Array<SIMChatInputPanelEmoticonPage> {
//        let count = emoticons.count
//        let maxCount = (3 * 7) - 1
//        
//        return (0 ..< (emoticons.count + maxCount - 1) / maxCount).map {
//            let beg = $0 * maxCount
//            let end = min(($0 + 1) * maxCount, count)
//            let page = SIMChatInputPanelEmoticonPage()
//            page.emoticons = Array(emoticons[beg ..< end])
//            return page
//        }
//    }
//    
//    var content: UIImage?
//    var group: SIMChatEmoticonGroup?
//    
//    lazy var emoticons: Array<SIMChatEmoticon> = []
//}
//
//extension SIMChatInputPanelEmoticonView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, SIMChatInputPanelPageControlDelegate, SIMChatInputPanelEmoticonCellDelegate {
//    
//    /// 点击返回
//    dynamic func onReturnPress(_ sender: AnyObject) {
//        if (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanelShouldReturn(self) ?? true {
//            // nothing
//        }
//    }
//    
//    /// 获取一组表情
//    @inline(__always) func groupAtIndex(_ index: Int) -> SIMChatEmoticonGroup? {
//        if index < _builtInGroups.count {
//            return _builtInGroups[index]
//        }
//        return (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanel(self, emoticonGroupAtIndex: index - _builtInGroups.count)
//    }
//    
//    // MARK: SIMChatInputPanelEmoticonCellDelegate
//    
//    /// 将要选择表情
//    func emoticonCell(_ emoticonCell: UIView, shouldSelectItem item: SIMChatEmoticon) -> Bool {
//        return (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanel(self, shouldSelectEmoticon: item) ?? true
//    }
//    /// 选择了表情
//    func emoticonCell(_ emoticonCell: UIView, didSelectItem item: SIMChatEmoticon) {
//        (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanel(self, didSelectEmoticon: item)
//    }
//    /// 将要退格
//    func emoticonCellShouldBackspace(_ emoticonCell: UIView) -> Bool {
//        return (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.inputPanelShouldBackspace(self) ?? true
//    }
//    /// 退格
//    func emoticonCellDidBackspace(_ emoticonCell: UIView) {
//        // nothing
//    }
//    
//    // MARK: SIMChatInputPanelPageControlDelegate
//    
//    /// 子组数量
//    func numberOfSectionsInPageControl(_ pageControl: SIMChatInputPanelPageControl) -> Int {
//        let v = max(groupAtIndex(pageControl.tag)?.groups?.count ?? 0, 1)
//        return v
//    }
//    
//    /// 每组的数量
//    func pageControl(_ pageControl: SIMChatInputPanelPageControl, numberOfPagesInSection section: Int) -> Int {
//        guard let group = groupAtIndex(pageControl.tag) else {
//            return 0
//        }
//        // 存在子组
//        if section < (group.groups?.count)! {
//            if let sg = group.groups?[section] {
//                return _pages["\(group.identifier) => \(sg.identifier)"]?.count ?? 0
//            }
//        }
//        return _pages[group.identifier]?.count ?? 0
//    }
//    
//    /// 每组的图标
//    func pageControl(_ pageControl: SIMChatInputPanelPageControl, imageOfSection section: Int) -> UIImage? {
//        guard let group = groupAtIndex(pageControl.tag) , section < (group.groups?.count)! else {
//            return nil
//        }
//        return group.groups?[section].icon
//    }
//    
//    // MARK: UIScrollViewDelegate
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        if scrollView is SIMChatInputPanelTabBar {
//            return
//        }
//        
//        let pt = CGPoint(x: scrollView.contentOffset.x + scrollView.frame.width / 2, y: scrollView.contentOffset.y)
//        if let indexPath = _contentView.indexPathForItem(at: pt) , _lastIndexPath?.item != (indexPath as NSIndexPath).item || _lastIndexPath?.section != (indexPath as NSIndexPath).section {
//            let page = (indexPath as NSIndexPath).item
//            if _pageControl.tag != (indexPath as NSIndexPath).section {
//                _pageControl.tag = (indexPath as NSIndexPath).section
//                _pageControl.reloadData()
//            }
//            var idx = page
//            var pidx = 0
//            if let group = groupAtIndex((indexPath as NSIndexPath).section), let subgroups = group.groups {
//                for sg in subgroups {
//                    let count = _pages["\(group.identifier) => \(sg.identifier)"]?.count ?? 0
//                    if idx < count {
//                        break
//                    }
//                    idx -= count
//                    pidx += 1
//                }
//            }
//            SIMLog.debug("\((indexPath as NSIndexPath).row) => \((indexPath as NSIndexPath).section) | \(idx) => \(pidx)")
//            
//            _pageControl.currentPage = IndexPath(item: idx, section: pidx)
//            _lastIndexPath = indexPath
//        }
//    }
//    
//    // MARK: UICollectionViewDataSource
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        let count = (delegate as? SIMChatInputPanelEmoticonViewDelegate)?.numberOfGroupsInInputPanelEmoticon(self) ?? 0
//        return _builtInGroups.count + count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if collectionView is SIMChatInputPanelTabBar {
//            return 1
//        }
//        guard let group = groupAtIndex(section) else {
//            return 0
//        }
//        let count = _pages[group.identifier]?.count ?? {
//            // 存在子组
//            if let subgroups = group.groups , !subgroups.isEmpty {
//                var pages: Array<SIMChatInputPanelEmoticonPage> = []
//                subgroups.forEach {
//                    // 转化为page
//                    var ps = SIMChatInputPanelEmoticonPage.makeWithGroup($0)
//                    if pages.isEmpty && group.isDefault && !$0.isDefault {
//                        // 如果是第一个, 反转
//                        ps = ps.reversed()
//                    }
//                    _pages["\(group.identifier) => \($0.identifier)"] = ps
//                    pages.append(contentsOf: ps)
//                }
//                _pages[group.identifier] = pages
//                return pages.count
//            }
//            // 转化为page
//            let pages = SIMChatInputPanelEmoticonPage.makeWithGroup(group)
//            _pages[group.identifier] = pages
//            return pages.count
//        }()
//        return count
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        if collectionView is SIMChatInputPanelTabBar {
//            return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
//        }
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "Emoticon", for: indexPath)
//    }
//    
//    // MARK: UICollectionViewDelegateFlowLayout
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        if collectionView is SIMChatInputPanelTabBar {
//            return CGSize(width: 50, height: collectionView.bounds.height)
//        }
//        return collectionView.bounds.size
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let group = groupAtIndex((indexPath as NSIndexPath).section) else {
//            return
//        }
//        if let cell = cell as? SIMChatInputPanelEmoticonCell {
//            cell.page = _pages[group.identifier]?[(indexPath as NSIndexPath).row]
//            cell.preview = _preview
//            cell.delegate = self
//        }
//        if let cell = cell as? SIMChatInputPanelTabBarCell {
//            cell.button.setTitle(group.name, for: UIControlState())
//            cell.button.setImage(group.icon, for: UIControlState())
//            cell.backgroundColor = UIColor(rgb: 0xe4e4e4)
//        }
//    }
//}
