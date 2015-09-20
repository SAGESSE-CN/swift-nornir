//
//  SIMChatViewController.swift
//  SIMChat
//
//  Created by sagesse on 9/19/15.
//  Copyright © 2015 Sagesse. All rights reserved.
//

import UIKit

class SIMChatViewController: SIMViewController {
    
    /// 构建
    override func build() {
        super.build()
    }

    /// 加载完成
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let vs = ["tf" : textField]
        
        
        // 设置背景
        view.backgroundColor = UIColor.clearColor()
        view.layer.contents =  SIMChatImageManager.defaultBackground?.CGImage
        view.layer.contentsGravity = kCAGravityResizeAspectFill//kCAGravityResize
        view.layer.masksToBounds = true
        // inputViewEx使用al
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.backgroundColor = UIColor(hex: 0xEBECEE)
        // tableView使用am
        tableView.frame = view.bounds
        tableView.autoresizingMask = .FlexibleWidth | .FlexibleHeight
        tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        tableView.backgroundColor = UIColor.clearColor()
        tableView.showsHorizontalScrollIndicator = false
        tableView.showsVerticalScrollIndicator = true
        tableView.rowHeight = 32
//        tableView.dataSource = self
//        tableView.delegate = self
        
        // add views
        
        // 第一个视图必须是tableView, addSubview(tableView)在ios7下有点bug?
        view.insertSubview(tableView, atIndex: 0)
        view.insertSubview(textField, aboveSubview: tableView)
        
        // add constraints
        view.addConstraints(NSLayoutConstraintMake("H:|[tf]|", views: vs))
        view.addConstraints(NSLayoutConstraintMake("V:[tf]|", views: vs))
    }
    
    private(set) lazy var tableView = UITableView()
    private(set) lazy var textField = SIMChatTextField(frame: CGRectZero)
}
