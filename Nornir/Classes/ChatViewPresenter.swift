//
//  ChatViewPresenter.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal protocol ChatViewPresenterDelegate: class {
    
    func chatView(_ chatView: ChatView, message: Message, identifier: String, sizeForProposed size: CGSize) -> CGSize
}


internal class ChatViewPresenter: NSObject, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    init(chatView: ChatView, chatViewLayout: ChatViewLayout) {
        self.chatView = chatView
        self.chatViewLayout = chatViewLayout
        super.init()
    }
    
    unowned(safe) let chatView: ChatView
    unowned(safe) let chatViewLayout: ChatViewLayout

    weak var delegate: ChatViewPresenterDelegate?
//    //
//    override init() {
//        super.init()
//
//        self.messages = (0 ..< 999).map { _ in
//            return NNMessage()
//        }
//    }
//
//    var messages: [Message] = []

    // func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {

    func preferredLayoutFitting(at indexPath: IndexPath) -> ComputedCustomLayout {
        
        
        return chatViewLayout.style(with: .prominent).compute(with: .init(width: chatView.frame.width, height: 0)) {
            return delegate?.chatView(chatView, message: NNMessage(), identifier: $0 ?? "", sizeForProposed: $1) ?? .zero
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 999//self.messages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Test", for: indexPath)
        (cell as? ChatViewCell)?.presenter = self
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.backgroundColor = .random
    }
}
