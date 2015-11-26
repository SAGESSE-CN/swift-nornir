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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: selectedButton)
        
        let s1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
//        let s2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
        let i3 = UIBarButtonItem(title: "原图", style: .Bordered, target: nil, action: "")
        let i4 = UIBarButtonItem(title: "发送(99)", style: .Done, target: nil, action: "")
        
        i4.width = 48
        
        //setToolbarHidden(false)
        toolbarItems = [i3, s1, i4]
        
        // 禁止缩进
        automaticallyAdjustsScrollViewInsets = false
        
        browseView.frame = view.bounds
        browseView.delegate = self
        browseView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        
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
        onSelectedCountChanged(picker?.selectedItems.count ?? 0)
        
        // 监听
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "onSelectedCountChangedNTF:", name: SIMChatPhotoPickerCountDidChangedNotification, object: nil)
    }
    
    /// 视图将要显示
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        // 开启工具栏
        navigationController?.setToolbarHidden(false, animated: animated)
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
        if let hidden = navigationController?.toolbarHidden where hidden {
            return hidden
        }
        return super.prefersStatusBarHidden()
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
        let btn = UIButton(type: .Custom)
        
        let img1 = SIMChatPhotoLibrary.sharedLibrary().deselectImage
        let img2 = SIMChatPhotoLibrary.sharedLibrary().selectImage
        
        btn.setImage(img1, forState:  .Normal)
        btn.setImage(img2, forState:  .Highlighted)
        btn.sizeToFit()
        
        btn.addTarget(self, action: "onSelectItem:", forControlEvents: .TouchUpInside)
        
        return btn
    }()
    private var selected: Bool = false {
        didSet {
            guard selected != oldValue else {
                return
            }
            
            let select = SIMChatPhotoLibrary.sharedLibrary().selectImage
            let deselect = SIMChatPhotoLibrary.sharedLibrary().deselectImage
            
            if selected {
                selectedButton.setImage(select, forState:  .Normal)
                selectedButton.setImage(deselect, forState:  .Highlighted)
            } else {
                selectedButton.setImage(deselect, forState:  .Normal)
                selectedButton.setImage(select, forState:  .Highlighted)
            }
            
        }
    }
    
    /// 选择器
    weak var picker: SIMChatPhotoPicker?
    weak var previousViewController: SIMChatPhotoPickerAssets?
    
    /// 数据源
    weak var dataSource: SIMChatPhotoBrowseDataSource? {
        set { return browseView.dataSource = newValue }
        get { return browseView.dataSource }
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
    /// 点击
    func browseViewDidClick(browseView: SIMChatPhotoBrowseView) {
        let hidden = navigationController?.toolbarHidden ?? true
        
        dispatch_async(dispatch_get_main_queue()) {
            self.navigationController?.setNavigationBarHidden(!hidden, animated: true)
            dispatch_async(dispatch_get_main_queue()) {
                self.navigationController?.setToolbarHidden(!hidden, animated: true)
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    /// 将要显示
    func browseView(browseView: SIMChatPhotoBrowseView, willDisplayElement element: SIMChatPhotoBrowseElement) {
        SIMLog.trace("index: \(browseView.currentShowIndex) view: \(element)")
        
        // 更新标题
        title = "\(browseView.currentShowIndex + 1)/\(dataSource?.count ?? 0)"
        // 更新选中状态
        selected = self.picker?.checkItem(element as? SIMChatPhotoAsset) ?? false
        currentShowIndex = browseView.currentShowIndex
    }
}

// MARK: - Event
extension SIMChatPhotoPickerPreviews {
    
    /// 数量改变
    @inline(__always) private func onSelectedCountChanged(count: Int) {
        if let it = toolbarItems?.last as UIBarButtonItem? {
            it.enabled = (count != 0)
            it.title = "发送(\(count))"
        }
    }
    private dynamic func onSelectedCountChangedNTF(sender: NSNotification) {
        onSelectedCountChanged((sender.object as? Int) ?? 0)
    }
    /// 标记
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
                // 选中
                self?.setSelected(true, animated: true)
                self?.picker?.selectItem(ele as? SIMChatPhotoAsset)
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