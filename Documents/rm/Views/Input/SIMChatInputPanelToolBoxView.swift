//
//  SIMChatInputPanelToolBoxView.swift
//  SIMChat
//
//  Created by sagesse on 1/22/16.
//  Copyright © 2016 Sagesse. All rights reserved.
//

import UIKit

// TODO: 暂未支持横屏

/////
///// 每一个工具
/////
//public class SIMChatInputToolBoxItem: SIMChatInputItemProtocol {
//    
//    public init(_ identifier: String, _ name: String, _ image: UIImage?, _ selectImage: UIImage? = nil) {
//        itemIdentifier = identifier
//        itemName = name
//        
//        itemImage = image
//        itemSelectImage = selectImage
//    }
//    
//    @objc public var itemIdentifier: String
//    @objc public var itemName: String?
//    
//    @objc public var itemImage: UIImage?
//    @objc public var itemSelectImage: UIImage?
//}
//
/////
///// 工具箱面板
/////
//internal class SIMChatInputPanelToolBoxView: UIView, SIMChatInputPanelProtocol {
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
//        let item = SIMChatBaseInputItem("kb:toolbox", R("chat_bottom_more_nor"), R("chat_bottom_more_press"))
//        SIMChatInputPanelContainer.registerClass(self.self, byItem: item)
//        return item
//    }
//    
//    @inline(__always) private func build() {
//        backgroundColor = UIColor.white//UIColor(argb: 0xFFEBECEE)
//        _contentView.backgroundColor = backgroundColor
//        
//        addSubview(_contentView)
//        addSubview(_pageControl)
//        
//        SIMChatLayout.make(_contentView)
//            .top.equ(self).top
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(_pageControl).top
//            .submit()
//        
//        SIMChatLayout.make(_pageControl)
//            .left.equ(self).left
//            .right.equ(self).right
//            .bottom.equ(self).bottom(15)
//            .height.equ(20)
//            .submit()
//    }
//    
//    private lazy var _pageControl: UIPageControl = {
//        let view = UIPageControl()
//        view.numberOfPages = 8
//        view.hidesForSinglePage = true
//        view.pageIndicatorTintColor = UIColor.gray
//        view.currentPageIndicatorTintColor = UIColor.darkGray
//        view.addTarget(self, action: #selector(type(of: self).onPageChanged(_:)), for: .valueChanged)
//        return view
//    }()
//    private lazy var _contentView: UICollectionView = {
//        let layout = SIMChatInputPanelToolBoxLayout()
//        let view = UICollectionView(frame: self.bounds, collectionViewLayout: layout)
//        view.delegate = self
//        view.dataSource = self
//        view.scrollsToTop = false
//        view.isPagingEnabled = true
//        view.delaysContentTouches = false
//        view.showsVerticalScrollIndicator = false
//        view.showsHorizontalScrollIndicator = false
//        view.register(SIMChatInputPanelToolBoxCell.self, forCellWithReuseIdentifier: "Item")
//        return view
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
///// 工具箱面板代理
/////
//internal protocol SIMChatInputPanelToolBoxDelegate: SIMChatInputPanelDelegate {
//    ///
//    /// 将要选择工具, 返回false表示拦截接下来的操作
//    ///
//    func inputPanel(_ inputPanel: UIView, shouldSelectToolBoxItem item: SIMChatInputItemProtocol) -> Bool
//    ///
//    /// 选择工具
//    ///
//    func inputPanel(_ inputPanel: UIView, didSelectToolBoxItem item: SIMChatInputItemProtocol)
//    
//    ///
//    /// 获取工具箱中的工具数量
//    ///
//    func numberOfItemsInInputPanelToolBox(_ inputPanel: UIView) -> Int
//    ///
//    /// 获取工具箱中的每一个工具
//    ///
//    func inputPanel(_ inputPanel: UIView, toolBoxItemAtIndex index: Int) -> SIMChatInputItemProtocol?
//}
//
/////
///// 工具箱中的每一个选项的视图
/////
//internal class SIMChatInputPanelToolBoxCell: UICollectionViewCell {
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        self.build()
//    }
//    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
//        self.build()
//    }
//    /// 构建
//    func build() {
//        
//        let vs = ["t" : titleLabel,
//            "c" : contentView2] as [String : Any]
//        
//        // config
//        titleLabel.font = UIFont.systemFont(ofSize: 12)
//        titleLabel.textAlignment = .center
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        titleLabel.isOpaque = true
//        
//        contentView2.translatesAutoresizingMaskIntoConstraints = false
//        
//        // add views
//        addSubview(contentView2)
//        addSubview(titleLabel)
//        
//        // add constrait
//        addConstraints(NSLayoutConstraintMake("H:|-(0)-[c]-(0)-|", views: vs as [String : AnyObject]))
//        addConstraints(NSLayoutConstraintMake("H:|-(0)-[t]-(0)-|", views: vs as [String : AnyObject]))
//        addConstraints(NSLayoutConstraintMake("V:|-(0)-[c]-(0)-[t(20)]-(0)-|", views: vs as [String : AnyObject]))
//        
//        // add events
//        contentView2.addTarget(self, action: #selector(type(of: self).onItemPress(_:)), for: .touchUpInside)
//    }
//    
//    /// 关联的item
//    var item: SIMChatInputItemProtocol? {
//        willSet {
//            titleLabel.text = newValue?.itemName
//            contentView2.setBackgroundImage(newValue?.itemImage, for: UIControlState())
//        }
//    }
//    /// item代理
//    weak var delegate: SIMChatInputItemProtocolDelegate?
//    
//    /// 选择了该择
//    dynamic func onItemPress(_ sender: AnyObject) {
//        guard let item = item else {
//            return
//        }
//        if  delegate?.itemShouldSelect(item) ?? true {
//            delegate?.itemDidSelect(item)
//        }
//    }
//    
//    private(set) lazy var titleLabel = UILabel()
//    private(set) lazy var contentView2 = UIButton()
//}
//
/////
///// 工具箱的布局
/////
//internal class SIMChatInputPanelToolBoxLayout: UICollectionViewLayout {
//    
//    var row = 2
//    var column = 4
//    /// t.
//    override func collectionViewContentSize() -> CGSize {
//        
//        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
//        let page = (count + (row * column - 1)) / (row * column)
//        let frame = self.collectionView?.frame ?? CGRect.zero
//        
//        return CGSize(width: frame.width * CGFloat(page), height: 0)
//    }
//    /// s.
//    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//        var ats = [UICollectionViewLayoutAttributes]()
//        // 生成
//        let frame = self.collectionView?.bounds ?? CGRect.zero
//        let count = self.collectionView?.numberOfItems(inSection: 0) ?? 0
//        // config
//        let w: CGFloat = 50
//        let h: CGFloat = 70
//        let yg: CGFloat = 28
//        let xg: CGFloat = (frame.width - w * CGFloat(self.column)) / CGFloat(self.column + 1)
//        // fill
//        for i in 0 ..< count {
//            // 计算。
//            let r = CGFloat((i / self.column) % self.row)
//            let c = CGFloat((i % self.column))
//            let idx = IndexPath(item: i, section: 0)
//            let page = CGFloat(i / (row * column))
//            
//            let a = self.layoutAttributesForItem(at: idx) ?? UICollectionViewLayoutAttributes(forCellWith: idx)
//            a.frame = CGRect(x: xg + c * (w + xg) + page * frame.width, y: yg + r * (h + yg), width: w, height: h)
//            // o
//            ats.append(a)
//        }
//        return ats
//    }
//}
//
//// MARK: - UICollectionViewDataSource & UICollectionViewDelegate
//
//extension SIMChatInputPanelToolBoxView: UICollectionViewDataSource, UICollectionViewDelegate {
//    
//    /// 滚动时改变page
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        _pageControl.currentPage = Int(round(scrollView.contentOffset.x / scrollView.frame.width))
//    }
//    
//    /// 计算数量
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        let count = (delegate as? SIMChatInputPanelToolBoxDelegate)?.numberOfItemsInInputPanelToolBox(self) ?? 0
//        let page = (count + (8 - 1)) / 8
//        if _pageControl.numberOfPages != page {
//            _pageControl.numberOfPages = page
//        }
//        return count
//    }
//    
//    /// 创建
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        return collectionView.dequeueReusableCell(withReuseIdentifier: "Item", for: indexPath)
//    }
//    /// 更新
//    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//        guard let cell = cell as? SIMChatInputPanelToolBoxCell else {
//            return
//        }
//        cell.delegate = self
//        cell.item = (delegate as? SIMChatInputPanelToolBoxDelegate)?.inputPanel(self, toolBoxItemAtIndex: (indexPath as NSIndexPath).row)
//    }
//}
//
//// MARK: - SIMChatInputItemProtocolDelegate
//
//extension SIMChatInputPanelToolBoxView: SIMChatInputItemProtocolDelegate {
//    /// 将要选择选项
//    func itemShouldSelect(_ item: SIMChatInputItemProtocol) -> Bool {
//        return (delegate as? SIMChatInputPanelToolBoxDelegate)?.inputPanel(self, shouldSelectToolBoxItem: item) ?? true
//    }
//    /// 选择了选项
//    func itemDidSelect(_ item: SIMChatInputItemProtocol) {
//        (delegate as? SIMChatInputPanelToolBoxDelegate)?.inputPanel(self, didSelectToolBoxItem: item)
//    }
//    
//    // MARK: Event
//
//    /// 切换页面
//    func onPageChanged(_ sender: UIPageControl) {
//        _contentView.setContentOffset(CGPoint(x: _contentView.bounds.width * CGFloat(sender.currentPage), y: 0), animated: true)
//    }
//}
//
