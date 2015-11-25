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
        self.defaultIndex = def
        super.init(nibName: nil, bundle: nil)
        self.dataSource = dataSource
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Title"
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
        
        dispatch_async(dispatch_get_main_queue()) {
            self.browseView.setCurrentIndex(self.defaultIndex, animated: false)
        }
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
        return navigationController?.toolbarHidden ??  super.prefersStatusBarHidden()
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
    
    /// 数据源
    weak var dataSource: SIMChatPhotoBrowseDataSource? {
        set { return browseView.dataSource = newValue }
        get { return browseView.dataSource }
    }
    
    /// 默认值
    var defaultIndex: Int = 0
    
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
}

// MARK: - Event
extension SIMChatPhotoPickerPreviews {
    /// 标记
    private dynamic func onSelectItem(sender: AnyObject) {
        SIMLog.trace()
        selected = !selected
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