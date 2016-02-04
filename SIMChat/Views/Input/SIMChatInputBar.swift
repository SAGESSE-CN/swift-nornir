//
//  SIMChatInputBar.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

//
// +---+------+---+---+
// | Y |      | @ | + |
// +---+------+---+---+
// +------------------+
//                  

/// 输入栏大小发生改变
public let SIMChatInputBarFrameDidChangeNotification = "SIMChatInputBarFrameDidChangeNotification"

///
/// 聊天输入栏
///
public class SIMChatInputBar: UIView {
    
    /// 初始化
    @inline(__always) private func build() {
        backgroundColor = UIColor(argb: 0xFFECEDF1)
        textView.delegate = self
        
        _lineView.backgroundColor = UIColor(argb: 0x4D000000)
        
        // 背景
        addSubview(backgroundView)
        addSubview(_lineView)
        // 核心
        addSubview(textView)
        // 额外选项
        addSubview(leftBarButtonItemsView)
        addSubview(rightBarButtonItemsView)
        addSubview(bottomBarButtonItemsView)
        
        // add layout
        
        SIMChatLayout.make(_lineView)
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).top
            .height.equ(1 / UIScreen.mainScreen().scale)
            .submit()
        
        SIMChatLayout.make(backgroundView)
            .top.equ(self).top(5)
            .submit()
        
        SIMChatLayout.make(leftBarButtonItemsView)
            .left.equ(self).left(5)
            .right.equ(backgroundView).left(-5)
            .bottom.equ(bottomBarButtonItemsView).top(-1)
            .submit()
        
        SIMChatLayout.make(rightBarButtonItemsView)
            .left.equ(backgroundView).right(-5)
            .right.equ(self).right(5)
            .bottom.equ(bottomBarButtonItemsView).top(-1)
            .submit()
        
        SIMChatLayout.make(textView)
            .top.equ(backgroundView).top
            .left.equ(backgroundView).left
            .right.equ(backgroundView).right
            .bottom.equ(backgroundView).bottom
            .submit()
        
        SIMChatLayout.make(bottomBarButtonItemsView)
            .top.equ(backgroundView).bottom
            .left.equ(self).left
            .right.equ(self).right
            .bottom.equ(self).bottom
            .height.gte(5)
            .submit()
    }
    
    /// 开关
    public var enabled: Bool = true {
        willSet {
            // TODO: 未实现的开关
        }
    }
    
    /// 内容
    public var text: String? {
        set { return textView.text = newValue }
        get { return textView.text }
    }
    /// 当前选择的选项
    public var selectedBarButtonItem: SIMChatInputItem? {
        return _selectedAccessoryButton?.item
        
    }
    /// 代理
    public weak var delegate: SIMChatInputBarDelegate? {
        set { return _delegate = newValue }
        get { return _delegate }
    }
    /// 输入框
    public var textView: UITextView { return _textView }
    /// 额外选项
    public var leftBarButtonItemsView: UIView { return _leftBarButtonItemsView }
    public var rightBarButtonItemsView: UIView { return _rightBarButtonItemsView }
    public var bottomBarButtonItemsView: UIView { return _bottomBarButtonItemsView }
    /// 背景
    public var backgroundView: UIView { return _backgroundView }
    /// 左侧菜单项
    public var leftBarButtonItems: [SIMChatInputItem]? {
        set { return _leftBarButtonItemsView.items = newValue }
        get { return _leftBarButtonItemsView.items }
    }
    /// 右侧菜单项
    public var rightBarButtonItems: [SIMChatInputItem]? {
        set { return _rightBarButtonItemsView.items = newValue }
        get { return _rightBarButtonItemsView.items }
    }
    /// 底部菜单项
    public var bottomBarButtonItems: [SIMChatInputItem]? {
        set {
            _bottomBarButtonItems = newValue
            _bottomBarButtonItemsView.hidden = newValue?.isEmpty ?? true
            _bottomBarButtonItemsView.reloadData()
        }
        get {
            return _bottomBarButtonItems
        }
    }
    
    public override func isFirstResponder() -> Bool {
        if _selectedAccessoryButton != nil {
            return true
        }
        if _textViewIsFristResponder {
            return true
        }
        return false
    }
    
    public override func canResignFirstResponder() -> Bool {
        if _selectedAccessoryButton != nil {
            return true
        }
        if _textViewIsFristResponder {
            return true
        }
        return super.canResignFirstResponder()
    }
    
    public override func resignFirstResponder() -> Bool {
        if textView.isFirstResponder() {
        textView.resignFirstResponder()
        }
        accessoryButtonDidDeselect()
        super.resignFirstResponder()
        
        return false
    }
    
    public override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    public override func becomeFirstResponder() -> Bool {
        return self.textView.becomeFirstResponder()
    }
    
    
    private lazy var _lineView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var _backgroundView: UIImageView = {
        let view =  UIImageView()
        view.image = SIMChatImageManager.defautlInputBackground
        return view
    }()
    private lazy var _textView: SIMChatInputBarTextView = {
        let view = SIMChatInputBarTextView()
        view.font = UIFont.systemFontOfSize(16)
        view.returnKeyType = .Send
        view.backgroundColor = UIColor.clearColor()
        view.scrollIndicatorInsets = UIEdgeInsetsMake(2, 0, 2, 0)
        return view
    }()
    
    private lazy var _leftBarButtonItemsView: SIMChatInputBarListEmbedView = {
        let view = SIMChatInputBarListEmbedView()
        view.delegate = self
        view.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, forAxis: .Horizontal)
        return view
    }()
    private lazy var _rightBarButtonItemsView: SIMChatInputBarListEmbedView = {
        let view = SIMChatInputBarListEmbedView()
        view.delegate = self
        view.setContentHuggingPriority(UILayoutPriorityDefaultLow + 1, forAxis: .Horizontal)
        return view
    }()
    private lazy var _bottomBarButtonItemsView: SIMChatInputBarListView = {
        let view = SIMChatInputBarListView(frame: self.bounds)
        view.hidden = true
        view.delegate = self
        view.dataSource = self
        view.backgroundColor = UIColor.clearColor()
        return view
    }()
    
    private weak var _delegate: SIMChatInputBarDelegate?
    
    /// 不使用系统的, 因为系统的isFristResponder更新速度太慢了
    private var _textViewIsFristResponder: Bool = false
    private var _bottomBarButtonItems: [SIMChatInputItem]?
    private var _selectedAccessoryButton: SIMChatInputBarButton? {
        didSet {
            guard _selectedAccessoryButton != oldValue else {
                return
            }
            oldValue?.selected = false
            if let btn = oldValue {
                let ani = CATransition()
                
                ani.duration = 0.25
                ani.fillMode = kCAFillModeBackwards
                ani.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                ani.type = kCATransitionFade
                ani.subtype = kCATransitionFromTop
                
                btn.layer.addAnimation(ani, forKey: "deselect")
            }
            _selectedAccessoryButton?.selected = true
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        SIMLog.trace()
        build()
    }
    override public init(frame: CGRect) {
        super.init(frame: frame)
        SIMLog.trace()
        build()
    }
    deinit {
        SIMLog.trace()
    }
}

// MARK: - Public Delegate

@objc public protocol SIMChatInputBarDelegate: NSObjectProtocol {
    
    optional func inputBarShouldBeginEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidBeginEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldEndEditing(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarDidEndEditing(inputBar: SIMChatInputBar)
    
    optional func inputBarShouldClear(inputBar: SIMChatInputBar) -> Bool
    optional func inputBarShouldReturn(inputBar: SIMChatInputBar) -> Bool
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
    
    optional func inputBarDidChange(inputBar: SIMChatInputBar)
    optional func inputBarDidChangeSelection(inputBar: SIMChatInputBar)
    
    optional func inputBar(inputBar: SIMChatInputBar, shouldSelectItem item: SIMChatInputItem) -> Bool
    optional func inputBar(inputBar: SIMChatInputBar, didSelectItem item: SIMChatInputItem)
    
    optional func inputBar(inputBar: SIMChatInputBar, willDeselectItem item: SIMChatInputItem)
    optional func inputBar(inputBar: SIMChatInputBar, didDeselectItem item: SIMChatInputItem)
}

// MARK: - Text View Delegate and Forward

extension SIMChatInputBar: UITextViewDelegate {
    /// 将要编辑文本
    public func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        guard delegate?.inputBarShouldBeginEditing?(self) ?? true else {
            return false
        }
        _textViewIsFristResponder = true
        return true
    }
    /// 己经开始编辑了
    public func textViewDidBeginEditing(textView: UITextView) {
        delegate?.inputBarDidBeginEditing?(self)
        accessoryButtonDidDeselect()
    }
    /// 将要结束
    public func textViewShouldEndEditing(textView: UITextView) -> Bool {
        guard delegate?.inputBarShouldEndEditing?(self) ?? true else {
            return false
        }
        _textViewIsFristResponder = false
        return true
    }
    /// 己经结束
    public func textViewDidEndEditing(textView: UITextView) {
        delegate?.inputBarDidEndEditing?(self)
    }
    /// 文本将要改变
    public func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard delegate?.inputBar?(self, shouldChangeCharactersInRange: range, replacementString: text) ?? true else {
            return false
        }
        // 这是换行
        if text == "\n" {
            return delegate?.inputBarShouldReturn?(self) ?? true
        }
        // 这是clear
        if text.isEmpty && range.location == 0 && range.length == (self.text as NSString?)?.length {
            return delegate?.inputBarShouldClear?(self) ?? true
        }
        
        return true
    }
    /// 文本己经改变.
    public func textViewDidChange(textView: UITextView) {
        delegate?.inputBarDidChange?(self)
    }
    /// 选择改变
    public func textViewDidChangeSelection(textView: UITextView) {
        delegate?.inputBarDidChangeSelection?(self)
    }
    
    /// 滚动到最后
    func scrollViewToBottom() {
        SIMLog.trace()
        // TODO: 未实现的滚动
//        let ch = textView.contentSize.height
//        let bh = textView.bounds.height
//        let py = textView.contentOffset.y
//        if ch - bh > py {
//            textView.setContentOffset(CGPointMake(0, ch - bh), animated: true)
//        }
    }
}

// MARK: - SIMChatInputItemViewDelegate

extension SIMChatInputBar: SIMChatInputBarButtonDelegate {
    /// 选择这个选项
    func inputBarButtonDidSelect(inputBarButton: SIMChatInputBarButton) {
        guard let accessory = inputBarButton.item where _selectedAccessoryButton != inputBarButton else {
            return
        }
        if delegate?.inputBar?(self, shouldSelectItem: accessory) ?? true {
            if let accessory = inputBarButton.item {
                delegate?.inputBar?(self, willDeselectItem: accessory)
            }
            
            let oldValue = _selectedAccessoryButton
            _selectedAccessoryButton = inputBarButton
            
            if textView.isFirstResponder() {
                textView.resignFirstResponder()
            }
            
            if let accessory = oldValue?.item {
                delegate?.inputBar?(self, didDeselectItem: accessory)
            }
            delegate?.inputBar?(self, didSelectItem: accessory)
        }
    }
    /// 取消选择
    private func accessoryButtonDidDeselect() {
        guard let accessoryButton = _selectedAccessoryButton else {
            return
        }
        _selectedAccessoryButton = nil
        if let accessory = accessoryButton.item {
            delegate?.inputBar?(self, didDeselectItem: accessory)
        }
    }
}

// MARK: - UICollectionViewDelegate & UICollectionViewDelegate

extension SIMChatInputBar: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return bottomBarButtonItems?.count ?? 0
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        guard let count = bottomBarButtonItems?.count where count > 0 else {
            return 0
        }
        var width = bounds.width
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            width -= layout.sectionInset.left + layout.sectionInset.right
            width -= layout.itemSize.width * CGFloat(min(count, 7))
        }
        return max(width / CGFloat(min(count, 7)), 10)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath)
    }
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        guard let cell = cell as? SIMChatInputBarCell, item = bottomBarButtonItems?[indexPath.row] else {
            return
        }
        cell.button.delegate = self
        cell.button.item = item
    }
}

///
///
///
internal class SIMChatInputBarButton: UIButton {
    private override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: "onClicked", forControlEvents: .TouchUpInside)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        addTarget(self, action: "onClicked", forControlEvents: .TouchUpInside)
    }
    
    /// 点击事件.
    private dynamic func onClicked() {
        delegate?.inputBarButtonDidSelect(self)
    }
    
    override var selected: Bool {
        set {
            guard selected != newValue else {
                return
            }
            if newValue {
                setImage(item?.itemSelectImage, forState: .Normal)
                setImage(item?.itemImage, forState: .Highlighted)
            } else {
                setImage(item?.itemImage, forState: .Normal)
                setImage(item?.itemSelectImage, forState: .Highlighted)
            }
            _selected = newValue
        }
        get {
            return _selected
        }
    }
    private var item: SIMChatInputItem? {
        didSet {
            _selected = true
            selected = false
        }
    }
    
    private var _selected: Bool = false
    private weak var delegate: SIMChatInputBarButtonDelegate?
}

internal class SIMChatInputBarCell: UICollectionViewCell {
    lazy var button: SIMChatInputBarButton = {
        let button = SIMChatInputBarButton()
        button.frame = self.bounds
        button.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        self.addSubview(button)
        return button
    }()
}

///
/// 自定义的输入框
///
internal class SIMChatInputBarTextView: UITextView {
    
    override var contentSize: CGSize {
        didSet {
            guard oldValue != contentSize && (oldValue.height <= maxHeight || contentSize.height <= maxHeight) else {
                return
            }
            invalidateIntrinsicContentSize()
            // 只有正在显示的时候才添加动画
            guard window != nil else {
                return
            }
            UIView.animateWithDuration(0.25) {
                // 必须在更新父视图之前
                self.layoutIfNeeded()
                // 必须显示父视图, 因为这个改变会导致父视图大小改变
                self.superview?.layoutIfNeeded()
            }
            SIMChatNotificationCenter.postNotificationName(SIMChatInputBarFrameDidChangeNotification, object: superview)
        }
    }
    
    override func intrinsicContentSize() -> CGSize {
        if contentSize.height > maxHeight {
            return CGSizeMake(contentSize.width, maxHeight)
        }
        return contentSize
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        // 如果是自定义菜单, 完全转发
        if SIMChatMenuController.sharedMenuController().isCustomMenu() {
            return SIMChatMenuController.sharedMenuController().canPerformAction(action, withSender: sender)
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override func forwardingTargetForSelector(aSelector: Selector) -> AnyObject? {
        // 如果是自定义菜单, 完全转发
        if SIMChatMenuController.sharedMenuController().isCustomMenu() {
            return SIMChatMenuController.sharedMenuController().forwardingTargetForSelector(aSelector)
        }
        return super.forwardingTargetForSelector(aSelector)
    }
    
    var maxHeight: CGFloat = 93
}

///
/// 自定义菜单栏(底部)
///
internal class SIMChatInputBarListView: UICollectionView {
    
    init(frame: CGRect) {
        let layout = UICollectionViewFlowLayout()
        
        layout.itemSize = CGSizeMake(34, 34)
        layout.sectionInset = UIEdgeInsetsMake(8, 10, 8, 10)
        
        super.init(frame: frame, collectionViewLayout: layout)
        
        scrollEnabled = false
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        registerClass(SIMChatInputBarCell.self, forCellWithReuseIdentifier: "Cell")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        collectionViewLayout.invalidateLayout()
    }
    override func intrinsicContentSize() -> CGSize {
        if numberOfItemsInSection(0) == 0 {
            return CGSizeMake(contentSize.width, 0)
        }
        return contentSize
    }
    
    override var contentSize: CGSize {
        didSet {
            if oldValue != contentSize {
                invalidateIntrinsicContentSize()
            }
        }
    }
}

///
/// 自定义菜单栏(嵌入)
///
internal class SIMChatInputBarListEmbedView: UIView {
        override func intrinsicContentSize() -> CGSize {
            return CGSizeMake(CGFloat(items?.count ?? 0) * (34 + 5) - 5, 34)
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            var x = CGFloat(0)
            buttons.forEach {
                let nframe = CGRectMake(x, 0, 34, 34)
                $0.frame = nframe
                x += nframe.width + 5
            }
        }
        
        /// 重新加载数据
        func reloadData() {
            var btns = buttons
            buttons = []
            items?.forEach { [weak self] in
                let btn = btns.isEmpty ? SIMChatInputBarButton() : btns.removeFirst()
                
                btn.item = $0
                btn.delegate = self?.delegate
                
                self?.addSubview(btn)
                self?.buttons.append(btn)
            }
            btns.forEach {
                $0.removeFromSuperview()
            }
            setNeedsLayout()
        }
        
        weak var delegate: SIMChatInputBarButtonDelegate?
        var buttons: [SIMChatInputBarButton] = []
        var items: [SIMChatInputItem]? {
            didSet {
                reloadData()
                guard items?.count != oldValue?.count else {
                    return
                }
                invalidateIntrinsicContentSize()
            }
        }
}

internal protocol SIMChatInputBarButtonDelegate: class {
    func inputBarButtonDidSelect(inputBarButton: SIMChatInputBarButton)
}

// MARK: - Notification

