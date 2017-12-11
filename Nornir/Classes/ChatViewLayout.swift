//
//  ChatViewLayout.swift
//  Nornir
//
//  Created by sagesse on 11/12/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal class ChatViewLayout: UICollectionViewFlowLayout {
    
    override func prepare() {
        // The estimated item width automatic following view.
        self.collectionView.map {
            self.estimatedItemSize = .init(width: $0.frame.width, height: 80)
        }
        // Continue to prepare for the layout
        super.prepare()
    }

}


//guard let collectionView = collectionView, let delegate = collectionView.delegate as? SACChatViewLayoutDelegate, let message = _message(at: indexPath) else {
//    return nil
//}
//let size = CGSize(width: collectionView.frame.width, height: .greatestFiniteMagnitude)
//if let info = _allLayoutAttributesInfo[message.identifier] {
//    //logger.trace("\(indexPath) - hit cache - \(info.layoutedBoxRect(with: .all))")
//    return info
//}
//let options = message.options
//
//var allRect: CGRect = .zero
//var allBoxRect: CGRect = .zero
//
//var cardRect: CGRect = .zero
//var cardBoxRect: CGRect = .zero
//
//var avatarRect: CGRect = .zero
//var avatarBoxRect: CGRect = .zero
//
//var bubbleRect: CGRect = .zero
//var bubbleBoxRect: CGRect = .zero
//
//var contentRect: CGRect = .zero
//var contentBoxRect: CGRect = .zero
//
//// 计算的时候以左对齐为基准
//
//// +---------------------------------------+ r0
//// |+---------------------------------+ r1 |
//// ||+---+ <NAME>                     |    |
//// ||| A | +---------------------\ r4 |    |
//// ||+---+ |+---------------+ r5 |    |    |
//// ||      ||    CONTENT    |    |    |    |
//// ||      |+---------------+    |    |    |
//// ||      \---------------------/    |    |
//// |+---------------------------------+    |
//// +---------------------------------------+
//
//let edg0 = _inset(with: options.style, for: .all)
//var r0 = CGRect(x: 0, y: 0, width: size.width, height: .greatestFiniteMagnitude)
//var r1 = UIEdgeInsetsInsetRect(r0, edg0)
//
//var x1 = r1.minX
//var y1 = r1.minY
//var x2 = r1.maxX
//var y2 = r1.maxY
//
//// add avatar if needed
//if options.showsAvatar {
//    let edg = _inset(with: options.style, for: .avatar)
//    let size = _size(with: options.style, for: .avatar)
//    //layoutSize(with: .avatar, size: .init(width: x2 - x1, height: y2 - y1))
//
//    let box = CGRect(x: x1, y: y1, width: edg.left + size.width + edg.right, height: edg.top + size.height + edg.bottom)
//    let rect = UIEdgeInsetsInsetRect(box, edg)
//
//    avatarRect = rect
//    avatarBoxRect = box
//
//    x1 = box.maxX
//}
//// add card if needed
//if options.showsCard {
//    let edg = _inset(with: options.style, for: .card)
//    let size = _size(with: options.style, for: .card)
//
//    let box = CGRect(x: x1, y: y1, width: x2 - x1, height: edg.top + size.height + edg.bottom)
//    let rect = UIEdgeInsetsInsetRect(box, edg)
//
//    cardRect = rect
//    cardBoxRect = box
//
//    y1 = box.maxY
//}
//// add bubble
//if options.showsBubble {
//    let edg = _inset(with: options.style, for: .bubble)
//
//    var box = CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
//    var rect = UIEdgeInsetsInsetRect(box, edg)
//
//    bubbleRect = rect
//    bubbleBoxRect = box
//
//    x1 = rect.minX
//    x2 = rect.maxX
//    y1 = rect.minY
//    y2 = rect.maxY
//}
//// add content
//if true {
//    let edg0 = _inset(with: options.style, for: .content)
//    let edg1 = message.content.layoutMargins
//    //
//    let edg = UIEdgeInsetsMake(edg0.top + edg1.top, edg0.left + edg1.left, edg0.bottom + edg1.bottom, edg0.right + edg1.right)
//
//    var box = CGRect(x: x1, y: y1, width: x2 - x1, height: y2 - y1)
//    var rect = UIEdgeInsetsInsetRect(box, edg)
//
//    // calc content size
//    let size = message.content.sizeThatFits(rect.size)
//
//    // restore offset
//    box.size.width = edg.left + size.width + edg.right
//    box.size.height = edg.top + size.height + edg.bottom
//    rect.size.width = size.width
//    rect.size.height = size.height
//
//    contentRect = rect
//    contentBoxRect = box
//
//    x1 = box.maxX
//    y1 = box.maxY
//}
//// adjust bubble
//if options.showsBubble {
//    let edg = _inset(with: options.style, for: .bubble)
//
//    bubbleRect.size.width = contentBoxRect.width
//    bubbleRect.size.height = contentBoxRect.height
//
//    bubbleBoxRect.size.width = edg.left + contentBoxRect.width + edg.right
//    bubbleBoxRect.size.height = edg.top + contentBoxRect.height + edg.bottom
//}
//
//// adjust
//r1.size.width = x1 - r1.minX
//r1.size.height = y1 - r1.minY
//r0.size.width = x1
//r0.size.height = y1 + edg0.bottom
//
//allRect = r1
//allBoxRect = r0
//
//// algin
//switch options.alignment {
//case .right:
//    // to right
//    allRect.origin.x = size.width - allRect.maxX
//    allBoxRect.origin.x = size.width - allBoxRect.maxX
//
//    cardRect.origin.x = size.width - cardRect.maxX
//    cardBoxRect.origin.x = size.width - cardBoxRect.maxX
//
//    avatarRect.origin.x = size.width - avatarRect.maxX
//    avatarBoxRect.origin.x = size.width - avatarBoxRect.maxX
//
//    bubbleRect.origin.x = size.width - bubbleRect.maxX
//    bubbleBoxRect.origin.x = size.width - bubbleBoxRect.maxX
//
//    contentRect.origin.x = size.width - contentRect.maxX
//    contentBoxRect.origin.x = size.width - contentBoxRect.maxX
//
//case .center:
//    // to center
//    allRect.origin.x = (size.width - allRect.width) / 2
//    allBoxRect.origin.x = (size.width - allBoxRect.width) / 2
//
//    bubbleRect.origin.x = (size.width - bubbleRect.width) / 2
//    bubbleBoxRect.origin.x = (size.width - bubbleBoxRect.width) / 2
//
//    contentRect.origin.x = (size.width - contentRect.width) / 2
//    contentBoxRect.origin.x = (size.width - contentBoxRect.width) / 2
//
//case .left:
//    // to left, nothing doing
//    break
//}
//// save
//let rects: [SACChatViewLayoutItem: CGRect] = [
//    .all: allRect,
//    .card: cardRect,
//    .avatar: avatarRect,
//    .bubble: bubbleRect,
//    .content: contentRect
//]
//let boxRects: [SACChatViewLayoutItem: CGRect] = [
//    .all: allBoxRect,
//    .card: cardBoxRect,
//    .avatar: avatarBoxRect,
//    .bubble: bubbleBoxRect,
//    .content: contentBoxRect
//]
//let info = SACChatViewLayoutAttributesInfo(message: message, size: size, rects: rects, boxRects: boxRects)
//_allLayoutAttributesInfo[message.identifier] = info
//logger.trace("complute: \(indexPath), result: \(info.layoutedBoxRect(with: .all))")
//return info

