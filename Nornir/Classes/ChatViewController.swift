//
//  ChatViewController.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

open class ChatViewController: UIViewController, ChatViewPresenterDelegate {
    
    public init(conversation: Conversation) {
        self.conversation = conversation
        
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder aDecoder: NSCoder) {
        fatalError()
    }
    
    public let conversation: Conversation
    
    open var chatView: ChatView {
        return _chatView
    }
    open var chatViewLayout: ChatViewLayout {
        return _chatViewLayout
    }
    internal var chatViewPresenter: ChatViewPresenter {
        return _chatViewPresenter
    }
    
    open override func loadView() {
        super.loadView()
   
        chatViewPresenter.delegate = self
        
        chatViewLayout.minimumLineSpacing = 0
        chatViewLayout.minimumInteritemSpacing = 0
        
        chatView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        chatView.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.9294117647, blue: 0.9450980392, alpha: 1)
        chatView.register(ChatViewCell.self, forCellWithReuseIdentifier: "Test")
        chatView.delegate = chatViewPresenter
        chatView.dataSource = chatViewPresenter
        
        view.backgroundColor = .white
        view.addSubview(chatView)
        
        title = "Chat"
    }
    
    // MARK:
    
    open func conversation(_ conversation: Conversation, didSend messages: Array<Message>) {
        logger.trace?.write()

    }
    
    open func conversation(_ conversation: Conversation, didReceive messages: Array<Message>) {
        logger.trace?.write()

    }
    
    open func conversation(_ conversation: Conversation, didRevoke messages: Array<Message>) {
        logger.trace?.write()

    }
    
    open func conversation(_ conversation: Conversation, didRemove messages: Array<Message>) {
        logger.trace?.write()
    }

    // MARK: Chat View Layout
    
    open func chatView(_ chatView: ChatView, message: Message, identifier: String, sizeForProposed size: CGSize) -> CGSize {
        switch identifier {
        case "<Card>":
            // The card for the prominent style message.
            return .init(width: size.width, height: 18)
            
        case "<Avatar>":
            // The avatar for the prominent & minimal style message.
            return .init(width: 39, height: 39)
            
        case "<Contents>":
            // The avatar for the prominent & minimal & notice style message.
            return .init(width: size.width, height: 18 * 4) // line height: 18
            
        default:
            // The item is custom, default is zero.
            // Please in subclasses implement this method.
            return .zero
        }
    }
    
    private lazy var _chatView: ChatView = ChatView(frame: self.view.bounds, collectionViewLayout: self.chatViewLayout)
    private lazy var _chatViewLayout: ChatViewLayout = ChatViewLayout()
    private lazy var _chatViewPresenter: ChatViewPresenter = ChatViewPresenter(chatView: self.chatView, chatViewLayout: self.chatViewLayout)
}
