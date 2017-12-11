//
//  SIMChatPhotoPicker+Previews.swift
//  SIMChat
//
//  Created by sagesse on 11/22/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

internal class SIMChatPhotoPickerPreviews: UIViewController {
    
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
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "\(currentShowIndex + 1)/\(dataSource?.count ?? 0)"
        
        let i4 = UIBarButtonItem(title: "发送", style: .done, target: self, action: #selector(type(of: self).onSend(_:)))
        
        if picker?.allowsMultipleSelection ?? false {
            let s1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
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
        browseView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        browseView.dataSource = self.dataSource
        
        view.backgroundColor = UIColor.black
        view.addSubview(browseView)
        
        if currentShowIndex == 0 {
            // 如果是0， 手动调一下
            dataSource?.fetch(0) { [weak self] ele in
                guard let s = self, let ele = ele , s.browseView.currentShowIndex == 0 else {
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
        NotificationCenter.default.addObserver(self, selector: #selector(type(of: self).onSelectedCountChangedNTF(_:)), name: NSNotification.Name(rawValue: SIMChatPhotoPickerCountDidChangedNotification), object: nil)
    }
    
    /// 视图将要显示
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SIMLog.trace()
        // 开启工具栏
        navigationController?.setToolbarHidden(!(picker?.allowsMultipleSelection ?? false), animated: animated)
        onOrigin(nil)
    }
    
    /// 视图将要消失
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SIMLog.trace()
        // 恢复侧滑手势
        navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        SIMLog.trace()
        // 临时关闭侧滑手势
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SIMLog.trace()
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden: Bool {
        return toolbarHidden
    }
    
    func setSelected(_ selected: Bool, animated: Bool) {
        self.selected = selected
        if animated {
            // 选中时, 加点特效
            let a = CAKeyframeAnimation(keyPath: "transform.scale")
            
            a.values = [0.8, 1.2, 1]
            a.duration = 0.25
            a.calculationMode = kCAAnimationCubic
            
            selectedButton.layer.add(a, forKey: "v")
        }
    }
    
    /// 选中的按钮
    private lazy var selectedButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(SIMChatPhotoLibrary.Images.markDeselect, for:  UIControlState())
        //btn.setImage(img2, forState:  .Highlighted)
        btn.sizeToFit()
        
        btn.addTarget(self, action: #selector(type(of: self).onSelectItem(_:)), for: .touchUpInside)
        
        return btn
    }()
    private lazy var originButton: UIButton = {
        let btn = UIButton(type: .system)
        
        btn.setImage(SIMChatPhotoLibrary.Images.markDeselectSmall, for:  UIControlState())
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 17)
        btn.setTitle("原图", for: UIControlState())
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0)
        btn.sizeToFit()
        btn.frame = CGRect(x: 0, y: 0, width: btn.bounds.width + 8, height: btn.bounds.height)
        
        btn.addTarget(self, action: #selector(type(of: self).onOrigin(_:)), for: .touchUpInside)
        
        return btn
    }()
    
    private var selected: Bool = false {
        didSet {
            guard selected != oldValue else {
                return
            }
            
            if selected {
                selectedButton.setImage(SIMChatPhotoLibrary.Images.markSelect, for:  UIControlState())
            } else {
                selectedButton.setImage(SIMChatPhotoLibrary.Images.markDeselect, for:  UIControlState())
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
    let browseView = SIMChatPhotoBrowseView(frame: CGRect.zero)
}

// MARK: - SIMChatPhotoBrowseDelegate
extension SIMChatPhotoPickerPreviews : SIMChatPhotoBrowseDelegate {
    ///
    /// 点击(单击)
    ///
    func browseViewDidClick(_ browseView: SIMChatPhotoBrowseView) {
        let hidden = toolbarHidden
        
        DispatchQueue.main.async {
            self.navigationController?.setNavigationBarHidden(!hidden, animated: true)
            if self.picker?.allowsMultipleSelection ?? false {
                self.navigationController?.setToolbarHidden(!hidden, animated: true)
            }
            UIView.animate(withDuration: 0.5, animations: {}) { b in
                self.toolbarHidden = !hidden
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    ///
    /// 将要显示
    ///
    func browseView(_ browseView: SIMChatPhotoBrowseView, willDisplayElement element: SIMChatPhotoBrowseElement) {
        SIMLog.trace("index: \(browseView.currentShowIndex) view: \(element)")
        
        // 更新标题
        title = "\(browseView.currentShowIndex + 1)/\(dataSource?.count ?? 0)"
        // 更新选中状态
        selected = self.picker?.checkItem(element as? SIMChatPhotoAsset) ?? false
        currentShowIndex = browseView.currentShowIndex
        
        // 检查是否允许选择
        let enable = self.picker?.canSelectItem(element as? SIMChatPhotoAsset) ?? true
        navigationItem.rightBarButtonItem?.isEnabled = enable
    }
}

// MARK: - Event
extension SIMChatPhotoPickerPreviews {
    ///
    /// 数量改变
    ///
    @inline(__always) private func selectedCountChanged(_ count: Int) {
        if let it = toolbarItems?.last as UIBarButtonItem? {
            let nmin = max(picker?.minimumNumberOfSelection ?? 0, 1)
            let nmax = picker?.maximumNumberOfSelection ?? 0 < nmin ? Int.max : picker?.maximumNumberOfSelection ?? 0
            
            it.isEnabled = count >= nmin && count <= nmax
            it.title = "发送(\(count))"
        }
        if let it = toolbarItems?.first as UIBarButtonItem? {
            it.isEnabled = count > 0
        }
    }
    ///
    /// 选择数量改变通知
    ///
    private dynamic func onSelectedCountChangedNTF(_ sender: Notification) {
        selectedCountChanged((sender.object as? Int) ?? 0)
    }
    ///
    /// 点击发送
    ///
    private dynamic func onSend(_ sender: AnyObject) {
        SIMLog.trace()
        picker?.confirm()
    }
    ///
    /// 更新原图选项
    ///
    private dynamic func onOrigin(_ sender: AnyObject?) {
        SIMLog.trace()
        
        // 按钮才改变
        if sender != nil {
           picker?.requireOrigin = !(picker?.requireOrigin ?? false)
        }
        
        if picker?.requireOrigin ?? false {
            originButton.setImage(SIMChatPhotoLibrary.Images.markSelectSmall, for: UIControlState())
        } else {
            originButton.setImage(SIMChatPhotoLibrary.Images.markDeselectSmall, for: UIControlState())
        }
    }
    ///
    /// 更新选择
    ///
    private dynamic func onSelectItem(_ sender: AnyObject) {
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
    public func fetch(_ index: Int, block: @escaping (SIMChatPhotoBrowseElement?) -> Void) {
        asset(index, complete: block)
    }
}
