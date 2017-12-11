//
//  ChatViewController.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class ChatViewController: UIViewController {
    
    open override func loadView() {
        super.loadView()
   

        let chatViewLayout = ChatViewLayout()
        let chatView = ChatView(frame: view.bounds, collectionViewLayout: chatViewLayout)
        
        chatViewLayout.minimumLineSpacing = 0
        chatViewLayout.minimumInteritemSpacing = 0
        
        chatView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chatView.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
        chatView.register(ChatViewCell.self, forCellWithReuseIdentifier: "Test")
        chatView.delegate = _presenter
        chatView.dataSource = _presenter
        
        view.backgroundColor = .white
        view.addSubview(chatView)
        
        title = "Chat"
    }
    
    
    private lazy var _presenter: ChatViewPresenter = .init()
}
