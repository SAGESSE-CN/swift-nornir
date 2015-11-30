//
//  SIMChatPhotoPicker+Previews.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatPhotoPickerPreviews: UIViewController {
    
    init(_ dataSource: SIMChatPhotoBrowseDataSource?, _ picker: SIMChatPhotoPicker?, def: Int = 0) {
        self.picker = picker
        self.currentShowIndex = def
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    deinit {
        // 完成。清除他
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(currentShowIndex + 1)/\(dataSource?.count ?? 0)"
        
        let i4 = UIBarButtonItem(title: "发送", style: .Done, target: self, action: "onSend:")
        
        if picker?.allowsMultipleSelection ?? false {
            let s1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
            let i3 = UIBarButtonItem(customView: originButton)
            
            i4.width = 48
            
            toolbarItems = [i3, s1, i4]
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectedButton)
        } else {
            navigationItem.rightBarButtonItem = i4
        }
        
        // 禁止缩进
        automaticallyAdjustsScrollViewInsets = false
        
        browseView.frame = view.bounds
        browseView.delegate = self
        browseView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        browseView.dataSource = self.dataSource
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(browseView)
        
        if currentShowIndex == 0 {
            // 如果是0， 手动调一下
            dataSource?.fetch(0) { [weak self] ele in
                guard let s = self, let ele = ele where s.browseView.currentShowIndex == 0 else {
                    return
                }
                s.browseView(s.browseView, willDisplayElement: ele)
            }
        } else {
            self.browseView.setCurrentIndex(self.currentShowIndex, animated: false)
        }
        
        // 更新选中数量
        selectedCountChanged(picker?.selectedItems.count ?? 0)
        
        // 监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSelectedCountChangedNTF:", name: SIMChatPhotoPickerCountDidChangedNotification, object: nil)
    }
    
    /// 视图将要显示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        // 开启工具栏
        navigationController?.setToolbarHidden(!(picker?.allowsMultipleSelection ?? false), animated: animated)
        onOrigin(nil)
    }
    
    /// 视图将要消失
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        SIMLog.trace()
        // 恢复侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
        // 临时关闭侧滑手势
        navigationController?.interactivePopGestureRecognizer?.enabled = false
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        SIMLog.trace()
    }
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return toolbarHidden
    }
    
    func setSelected(selected: Bool, animated: Bool) {
        self.selected = selected
        if animated {
            // 选中时, 加点特效
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = kCAAnimationCubic
            
            selectedButton.layer.addAnimation(a, forKey: "v")
        }
    }
    
    /// 选中的按钮
    private lazy var selectedButton: UIButton = {
        let btn = UIButton(type: .System)
        
        btn.setImage(SIMChatPhotoLibrary.Images.markDeselect, forState:  .Normal)
        //btn.setImage(img2, forState:  .Highlighted)
        btn.sizeToFit()
        
        btn.addTarget(self, action: "onSelectItem:", forControlEvents: .TouchUpInside)
        
        return btn
    }()
    private lazy var originButton: UIButton = {
        let btn = UIButton(type: .System)
        
        btn.setImage(SIMChatPhotoLibrary.Images.markDeselectSmall, forState:  .Normal)
        btn.titleLabel?.font = UIFont.systemFontOfSize(17)
        btn.setTitle("原图", forState: .Normal)
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        btn.sizeToFit()
        btn.frame = CGRectMake(0, 0, btn.bounds.width + 8, btn.bounds.height)
        
        btn.addTarget(self, action: "onOrigin:", forControlEvents: .TouchUpInside)
        
        return btn
    }()
    
    private var selected: Bool = false {
        didSet {
            guard selected != oldValue else {
                return
            }
            
            if selected {
                selectedButton.setImage(SIMChatPhotoLibrary.Images.markSelect, forState:  .Normal)
            } else {
                selectedButton.setImage(SIMChatPhotoLibrary.Images.markDeselect, forState:  .Normal)
            }
            
        }
    }
    private var toolbarHidden = false
    
    /// 选择器
    weak var picker: SIMChatPhotoPicker?
    weak var previousViewController: SIMChatPhotoPickerAssets?
    
    /// 数据源
    var dataSource: SIMChatPhotoBrowseDataSource? {
        didSet { browseView.dataSource = dataSource }
    }
    
    /// 默认值
    var currentShowIndex: Int = 0 {
        didSet {
            previousViewController?.currentSelectedIndex = currentShowIndex
        }
    }
    
    /// 浏览控件
    let browseView = SIMChatPhotoBrowseView(frame: CGRectZero)
}

// MARK: - SIMChatPhotoBrowseDelegate
extension SIMChatPhotoPickerPreviews : SIMChatPhotoBrowseDelegate {
    ///
    /// 点击(单击)
    ///
    func browseViewDidClick(browseView: SIMChatPhotoBrowseView) {
        let hidden = toolbarHidden
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.setNavigationBarHidden(!hidden, animated: true)
            if self.picker?.allowsMultipleSelection ?? false {
                self.navigationController?.setToolbarHidden(!hidden, animated: true)
            }
            UIView.animateWithDuration(0.5, animations: {}) { b in
                self.toolbarHidden = !hidden
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    ///
    /// 将要显示
    ///
    func browseView(browseView: SIMChatPhotoBrowseView, willDisplayElement element: SIMChatPhotoBrowseElement) {
        SIMLog.trace("index: \(browseView.currentShowIndex) view: \(element)")
        
        // 更新标题
        title = "\(browseView.currentShowIndex + 1)/\(dataSource?.count ?? 0)"
        // 更新选中状态
        selected = self.picker?.checkItem(element as? SIMChatPhotoAsset) ?? false
        currentShowIndex = browseView.currentShowIndex
        
        // 检查是否允许选择
        let enable = self.picker?.canSelectItem(element as? SIMChatPhotoAsset) ?? true
        navigationItem.rightBarButtonItem?.enabled = enable
    }
}

// MARK: - Event
extension SIMChatPhotoPickerPreviews {
    ///
    /// 数量改变
    ///
    @inline(__always) private func selectedCountChanged(count: Int) {
        if let it = toolbarItems?.last as UIBarButtonItem? {
            let nmin = max(picker?.minimumNumberOfSelection ?? 0, 1)
            let nmax = picker?.maximumNumberOfSelection ?? 0 < nmin ? Int.max : picker?.maximumNumberOfSelection ?? 0
            
            it.enabled = count >= nmin && count <= nmax
            it.title = "发送(\(count))"
        }
        if let it = toolbarItems?.first as UIBarButtonItem? {
            it.enabled = count > 0
        }
    }
    ///
    /// 选择数量改变通知
    ///
    private dynamic func onSelectedCountChangedNTF(sender: NSNotification) {
        selectedCountChanged((sender.object as? Int) ?? 0)
    }
    ///
    /// 点击发送
    ///
    private dynamic func onSend(sender: AnyObject) {
        SIMLog.trace()
        picker?.confirm()
    }
    ///
    /// 更新原图选项
    ///
    private dynamic func onOrigin(sender: AnyObject?) {
        SIMLog.trace()
        
        // 按钮才改变
        if sender != nil {
           picker?.requireOrigin = !(picker?.requireOrigin ?? false)
        }
        
        if picker?.requireOrigin ?? false {
            originButton.setImage(SIMChatPhotoLibrary.Images.markSelectSmall, forState: .Normal)
        } else {
            originButton.setImage(SIMChatPhotoLibrary.Images.markDeselectSmall, forState: .Normal)
        }
    }
    ///
    /// 更新选择
    ///
    private dynamic func onSelectItem(sender: AnyObject) {
        SIMLog.trace()
        
        let index = browseView.currentShowIndex
        // :)
        if selected {
            dataSource?.fetch(index) { [weak self] ele in
                guard index == self?.browseView.currentShowIndex else {
                    return
                }
                // 取消
                self?.setSelected(false, animated: true)
                self?.picker?.deselectItem(ele as? SIMChatPhotoAsset)
            }
        } else {
            dataSource?.fetch(index) { [weak self] ele in
                guard index == self?.browseView.currentShowIndex else {
                    return
                }
                // 选中, 并检查是否成功
                let st = self?.picker?.selectItem(ele as? SIMChatPhotoAsset) ?? false
                self?.setSelected(st, animated: true)
            }
        }
    }
}

extension SIMChatPhotoAsset : SIMChatPhotoBrowseElement {
}
extension SIMChatPhotoAlbum : SIMChatPhotoBrowseDataSource {
    /// 获取对象
    public func fetch(index: Int, block: SIMChatPhotoBrowseElement? -> Void) {
        asset(index, complete: block)
    }
}