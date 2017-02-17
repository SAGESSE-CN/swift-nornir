//
//  SACChatViewDataTests.swift
//  Example
//
//  Created by sagesse on 10/01/2017.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import XCTest
import Foundation

@testable import SAChat

extension SACChatViewData {
    func _element(at index: Int) -> SACMessageType? {
        guard index >= 0 && index < self._elements.count else {
            return nil
        }
        return self._elements[index]
    }
}


class SACChatViewDataTests: XCTestCase {
    
    func _reset(elements: Array<SACMessageType>) -> Array<SACMessageType> {
        _ = elements.reduce(nil) { (p:SACMessageType?, n:SACMessageType) -> SACMessageType? in
            if let content = p?.content as? SACMessageTimeLineContent {
                content.after = n
                content.date = n.date
            }
            if let content = n.content as? SACMessageTimeLineContent {
                content.before = p
            }
            return n
        }
        return elements
    }
    
    func _equal(_ lhs: [SACMessageType], _ rhs: [SACMessageType]) -> Bool {
        guard lhs.count == rhs.count else {
            print(lhs, rhs)
            return false
        }
        let b = lhs.elementsEqual(rhs) {
            guard $0.identifier != $1.identifier else {
                return true
            }
            guard $0.content is SACMessageTimeLineContent && $1.content is SACMessageTimeLineContent else {
                return false
            }
            return true
        }
        guard b else {
            print(lhs, rhs)
            return false
        }
        return true
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        m1.date = Date(timeIntervalSinceNow: 0)
        m2.date = Date(timeIntervalSinceNow: -60)
        m3.date = Date(timeIntervalSinceNow: -61)
        m4.date = Date(timeIntervalSinceNow: -122)
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testConvert() {
        let cd1 = SACChatViewData()
        let cp1 = SACChatViewUpdate(model: cd1)
       
        let m0 = SACMessage(content: SACMessageTextContent(text: "test0"))
        let m1 = SACMessage(content: SACMessageTextContent(text: "test1"))
        let m2 = SACMessage(content: SACMessageTextContent(text: "test2"))
        
        let t0 = SACMessage(content: SACMessageTimeLineContent(date: .init()))
        let t1 = SACMessage(content: SACMessageTimeLineContent(date: .init()))
        let t2 = SACMessage(content: SACMessageTimeLineContent(date: .init()))
        
        
        let reset = { () -> SACChatViewUpdate in
            m0.date = .init(timeIntervalSinceNow: 0)
            m1.date = .init(timeIntervalSinceNow: 60)
            m2.date = .init(timeIntervalSinceNow: 61)
            
            t0.date = .init(timeIntervalSinceNow: 0)
            t1.date = .init(timeIntervalSinceNow: 60)
            t2.date = .init(timeIntervalSinceNow: 61)
            
            (t0.content as? SACMessageTimeLineContent)?.after = m0
            (t0.content as? SACMessageTimeLineContent)?.before = m0
            (t1.content as? SACMessageTimeLineContent)?.after = m1
            (t1.content as? SACMessageTimeLineContent)?.before = m1
            (t2.content as? SACMessageTimeLineContent)?.after = m2
            (t2.content as? SACMessageTimeLineContent)?.before = m2
            
            return cp1
        }
        
        // case-h1: F=N, P=N, C=T, N=M, L=M
        XCTAssert(_equal(reset()._convert(message: t0, previous: nil, next: m0, first: nil, last: m0), [t0]))
        // case-h2: F=N, P=N, C=M, N=M, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: nil, next: m0, first: nil, last: m0), [t0,m0]))
        // case-h3: F=N, P=N, C=M, N=T, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: nil, next: t0, first: nil, last: m0), [t0,m0]))
        // case-h4: F=T, P=N, C=T, N=T, L=M
        XCTAssert(_equal(reset()._convert(message: t0, previous: nil, next: t0, first: t0, last: m0), []))
        // case-h5: F=M, P=N, C=M, N=T, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: nil, next: t0, first: m0, last: m0), [m0]))
        // case-m1: F=M, P=M, C=M, N=M, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: m0, next: m0, first: m0, last: m0), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: m0, next: m2, first: m0, last: m2), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: m0, next: m2, first: m0, last: m2), [t0,m2]))
        // case-m2: F=M, P=T, C=M, N=M, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: t0, next: m2, first: m0, last: m2), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: t0, next: m2, first: m0, last: m2), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: t0, next: m2, first: m0, last: m2), [m2]))
        // case-m3: F=M, P=T, C=M, N=T, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: t0, next: t2, first: m0, last: m2), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: t0, next: t2, first: m0, last: m2), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: t0, next: t2, first: m0, last: m2), [m2]))
        // case-m4: F=M, P=T, C=T, N=T, L=M
        XCTAssert(_equal(reset()._convert(message: t0, previous: t0, next: t2, first: m0, last: m2), []))
        XCTAssert(_equal(reset()._convert(message: t1, previous: t0, next: t2, first: m0, last: m2), []))
        XCTAssert(_equal(reset()._convert(message: t2, previous: t0, next: t2, first: m0, last: m2), []))
        // case-m5: F=M, P=N, C=T, N=M, L=N
        XCTAssert(_equal(reset()._convert(message: t0, previous: nil, next: m2, first: m0, last: nil), [t0]))
        // case-m6: F=M, P=N, C=M, N=M, L=N
        XCTAssert(_equal(reset()._convert(message: m0, previous: nil, next: m2, first: m0, last: nil), [m0]))
        // case-m7: F=M, P=M, C=M, N=N, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: m0, next: nil, first: m0, last: m0), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: m0, next: nil, first: m0, last: m1), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: m0, next: nil, first: m0, last: m2), [t0,m2]))
        // case-m8: F=M, P=M, C=T, N=N, L=T
        XCTAssert(_equal(reset()._convert(message: t0, previous: m0, next: nil, first: m0, last: t0), []))
        XCTAssert(_equal(reset()._convert(message: t1, previous: m0, next: nil, first: m0, last: t1), []))
        XCTAssert(_equal(reset()._convert(message: t2, previous: m0, next: nil, first: m0, last: t2), [t2]))
        // case-m9: F=M, P=T, C=M, N=N, L=M
        XCTAssert(_equal(reset()._convert(message: m0, previous: t0, next: nil, first: m0, last: m0), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: t0, next: nil, first: m0, last: m1), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: t0, next: nil, first: m0, last: m2), [m2])) // 上一个条己经有t了, 忽略t
        // case-ma: F=M, P=T, C=T, N=N, L=T
        XCTAssert(_equal(reset()._convert(message: t0, previous: t0, next: nil, first: m0, last: t0), []))
        XCTAssert(_equal(reset()._convert(message: t1, previous: t0, next: nil, first: m0, last: t1), []))
        XCTAssert(_equal(reset()._convert(message: t2, previous: t0, next: nil, first: m0, last: t2), []))
        // case-t1: F=M, P=M, C=T, N=N, L=N
        XCTAssert(_equal(reset()._convert(message: t0, previous: m0, next: nil, first: m0, last: nil), []))
        // case-t2: F=M, P=M, C=M, N=N, L=N
        XCTAssert(_equal(reset()._convert(message: m0, previous: m0, next: nil, first: m0, last: nil), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: m0, next: nil, first: m0, last: nil), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: m0, next: nil, first: m0, last: nil), [t2,m2]))
        // case-t3: F=M, P=T, C=M, N=N, L=N
        XCTAssert(_equal(reset()._convert(message: m0, previous: t0, next: nil, first: m0, last: nil), [m0]))
        XCTAssert(_equal(reset()._convert(message: m1, previous: t0, next: nil, first: m0, last: nil), [m1]))
        XCTAssert(_equal(reset()._convert(message: m2, previous: t0, next: nil, first: m0, last: nil), [m2]))
        // case-s1: F=N, P=N, C=T, N=N, L=N
        XCTAssert(_equal(reset()._convert(message: t0, previous: nil, next: nil, first: nil, last: nil), []))
        // case-s1: F=N, P=N, C=M, N=N, L=N
        XCTAssert(_equal(reset()._convert(message: m0, previous: nil, next: nil, first: nil, last: nil), [t0,m0]))
        
        // case-t1: F=T, P=N, C=T, N=M, L=M
    }
    
    func testInsert() {
        
        // 初次添加
        let ad1 = SACChatViewData()
        let ade1 = ad1._elements
        let up1 = SACChatViewUpdate(model: ad1)
        
        // head
        ad1._elements = _reset(elements: ade1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
        ])
        XCTAssert(ad1.count == 2, "insert error")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        
        // mid
        ad1._elements = _reset(elements: ade1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m2, at: 0),
        ])
        XCTAssert(ad1.count == 3, "insert error")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        XCTAssert(ad1._element(at: 2) === m2)
        
        // last
        ad1._elements = _reset(elements: ade1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m3, at: 0),
        ])
        XCTAssert(ad1.count == 4, "insert error!")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        XCTAssert(ad1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 3) === m3)
        
        // 增量添加
        let ad4 = SACChatViewData()
        let up4 = SACChatViewUpdate(model: ad4)
        up4._computeItemUpdates([
            .insert(m1, at: 0),
        ])
        let ade4 = ad4._elements
        XCTAssert(ad4.count == 2, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        
        // 普通插入(尾部)
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m2, at: ad4.count),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m2, at: ad4.count),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        
        // 普通插入(中间)
        up4._computeItemUpdates([
            .insert(m2, at: 2),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        XCTAssert(ad4._element(at: 3) === m2)
        
        // 普通插入(头部)
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m2, at: 0),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m2)
        XCTAssert(ad4._element(at: 2) === m1)
        
        // 自动添加TimeLine(头部)
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m4, at: 0),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m4)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m1)
        
        // 自动添加TimeLine(尾部)
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m4, at: ad4.count),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m4)
        
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m3, at: 2),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m3)
        
        // 自动移除TimeLine(中间)
        up4._computeItemUpdates([
            .insert(m2, at: 2),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        XCTAssert(ad4._element(at: 3) === m3)
        
        ad4._elements = _reset(elements: ade4)
        up4._computeItemUpdates([
            .insert(m2, at: 2),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        
        // 自动添加TimeLine(中间)
        up4._computeItemUpdates([
            .insert(m3, at: 2),
        ])
        XCTAssert(ad4.count == 5, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m3)
        XCTAssert(ad4._element(at: 4) === m2)
    }
    
    func testRemove() {
        
        let rd1 = SACChatViewData()
        let up1 = SACChatViewUpdate(model: rd1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m2, at: 0),
            .insert(m3, at: 0),
            .insert(m4, at: 0),
        ])
        
        
        let rde1 = rd1._elements
        XCTAssert(rd1.count == 6, "insert error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        // 普通删除
        // 删除TimeLine(头部)
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 0)
        ])
        XCTAssert(rd1.count == 6, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        
        // 删除TimeLine(尾部)
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 4)
        ])
        XCTAssert(rd1.count == 6, "remove error!")
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        // 普通删除(头部)
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 1)
        ])
        XCTAssert(rd1.count == 5, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m2)
        XCTAssert(rd1._element(at: 2) === m3)
        XCTAssert(rd1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 4) === m4)
        
        // 普通删除(中间)
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 3)
        ])
        XCTAssert(rd1.count == 5, "remove error!")
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 4) === m4)
        
        // 普通删除(中间), 产生TimeLine
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 2)
        ])
        XCTAssert(rd1.count == 6, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        XCTAssert(rd1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        // 普通删除(尾部)
        rd1._elements = _reset(elements: rde1)
        up1._computeItemUpdates([
            .remove(at: 5)
        ])
        XCTAssert(rd1.count == 4, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3) === m3)
        
        let rd2 = SACChatViewData()
        let up2 = SACChatViewUpdate(model: rd2)
        up2._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m1, at: 0),
            .insert(m2, at: 0),
            .insert(m2, at: 0),
            .insert(m3, at: 0),
            .insert(m3, at: 0),
            .insert(m4, at: 0),
            .insert(m4, at: 0),
        ])
        let rde2 = rd2._elements
        XCTAssert(rd2.count == 10, "insert error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m2)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6) === m3)
        XCTAssert(rd2._element(at: 7)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 8) === m4)
        XCTAssert(rd2._element(at: 9) === m4)

        // 连续删除
        // 连续删除(头)
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 0),
            .remove(at: 1),
            .remove(at: 2),
            .remove(at: 3),
            .remove(at: 4),
        ])
        XCTAssert(rd2.count == 6, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m3)
        XCTAssert(rd2._element(at: 2) === m3)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m4)
        XCTAssert(rd2._element(at: 5) === m4)
        
        // 连续删除(中), 自动添加TimeLine
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 3),
            .remove(at: 4),
        ])
        XCTAssert(rd2.count == 9, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 7) === m4)
        XCTAssert(rd2._element(at: 8) === m4)
        
        // 连续删除(中)
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 4),
            .remove(at: 5),
        ])
        XCTAssert(rd2.count == 8, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 6) === m4)
        XCTAssert(rd2._element(at: 7) === m4)
        
        // 连续删除(尾), 自动删除TimeLine
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 8),
            .remove(at: 9),
        ])
        XCTAssert(rd2.count == 7, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m2)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6) === m3)
        
        // 连续删除(尾), 手动删除TimeLine
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 7),
            .remove(at: 8),
            .remove(at: 9),
        ])
        XCTAssert(rd2.count == 7, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m2)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6) === m3)
        
        // 随机删除(头)
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 0),
            .remove(at: 4),
        ])
        XCTAssert(rd2.count == 9, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 7) === m4)
        XCTAssert(rd2._element(at: 8) === m4)
        
        // 随机删除(中)
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 1),
            .remove(at: 2),
            .remove(at: 6),
            .remove(at: 7),
        ])
        XCTAssert(rd2.count == 7, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m2)
        XCTAssert(rd2._element(at: 2) === m2)
        XCTAssert(rd2._element(at: 3) === m3)
        XCTAssert(rd2._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 5) === m4)
        XCTAssert(rd2._element(at: 6) === m4)
        
        // 随机删除(尾)
        rd2._elements = _reset(elements: rde2)
        up2._computeItemUpdates([
            .remove(at: 3),
            .remove(at: 4),
            .remove(at: 5),
            .remove(at: 8),
            .remove(at: 9),
        ])
        XCTAssert(rd2.count == 5, "remove error!")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m3)
    }
    
    func testUpdate() {
        
        let ud1 = SACChatViewData()
        let up1 = SACChatViewUpdate(model: ud1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m2, at: 0),
            .insert(m3, at: 0),
            .insert(m4, at: 0),
        ])
        let ude1 = ud1._elements
        XCTAssert(ud1.count == 6, "insert error!")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m1)
        XCTAssert(ud1._element(at: 2) === m2)
        XCTAssert(ud1._element(at: 3) === m3)
        XCTAssert(ud1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 5) === m4)
        
        // 普通更新(头)
        ud1._elements = _reset(elements: ude1)
        up1._computeItemUpdates([
            .update(m2, at: 0),
        ])
        XCTAssert(ud1.count == 7, "update error!")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m2)
        XCTAssert(ud1._element(at: 2) === m1)
        XCTAssert(ud1._element(at: 3) === m2)
        XCTAssert(ud1._element(at: 4) === m3)
        XCTAssert(ud1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 6) === m4)
        
        // 普通更新(中)
        ud1._elements = _reset(elements: ude1)
        up1._computeItemUpdates([
            .update(m4, at: 2),
        ])
        XCTAssert(ud1.count == 8, "update error!")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m1)
        XCTAssert(ud1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 3) === m4)
        XCTAssert(ud1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 5) === m3)
        XCTAssert(ud1._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 7) === m4)
        
        // 普通更新(尾)
        ud1._elements = _reset(elements: ude1)
        up1._computeItemUpdates([
            .update(m3, at: 5),
        ])
        XCTAssert(ud1.count == 5, "update error!")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m1)
        XCTAssert(ud1._element(at: 2) === m2)
        XCTAssert(ud1._element(at: 3) === m3)
        XCTAssert(ud1._element(at: 4) === m3)
        
        let ud2 = SACChatViewData()
        let up2 = SACChatViewUpdate(model: ud2)
        up2._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m1, at: 0),
            .insert(m2, at: 0),
            .insert(m2, at: 0),
            .insert(m3, at: 0),
            .insert(m3, at: 0),
            .insert(m4, at: 0),
            .insert(m4, at: 0),
        ])
        let ude2 = ud2._elements
        XCTAssert(ud2.count == 10, "insert error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2) === m1)
        XCTAssert(ud2._element(at: 3) === m2)
        XCTAssert(ud2._element(at: 4) === m2)
        XCTAssert(ud2._element(at: 5) === m3)
        XCTAssert(ud2._element(at: 6) === m3)
        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 8) === m4)
        XCTAssert(ud2._element(at: 9) === m4)
        
        // 连续更新
        // 连续更新(空)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
        ])
        XCTAssert(ud2.count == 10, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2) === m1)
        XCTAssert(ud2._element(at: 3) === m2)
        XCTAssert(ud2._element(at: 4) === m2)
        XCTAssert(ud2._element(at: 5) === m3)
        XCTAssert(ud2._element(at: 6) === m3)
        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 8) === m4)
        XCTAssert(ud2._element(at: 9) === m4)
        
        // 连续更新(头)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m4, at: 0),
            .update(m4, at: 1),
            .update(m4, at: 2),
        ])
        XCTAssert(ud2.count == 12, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m4)
        XCTAssert(ud2._element(at: 2) === m4)
        XCTAssert(ud2._element(at: 3) === m4)
        XCTAssert(ud2._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 5) === m2)
        XCTAssert(ud2._element(at: 6) === m2)
        XCTAssert(ud2._element(at: 7) === m3)
        XCTAssert(ud2._element(at: 8) === m3)
        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 10) === m4)
        XCTAssert(ud2._element(at: 11) === m4)
        
        // 连续更新(中)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m4, at: 2),
            .update(m4, at: 3),
            .update(m4, at: 4),
            .update(m4, at: 5),
        ])
        XCTAssert(ud2.count == 12, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 3) === m4)
        XCTAssert(ud2._element(at: 4) === m4)
        XCTAssert(ud2._element(at: 5) === m4)
        XCTAssert(ud2._element(at: 6) === m4)
        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 8) === m3)
        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 10) === m4)
        XCTAssert(ud2._element(at: 11) === m4)
       
        // 连续更新(尾)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m1, at: 6),
            .update(m1, at: 7),
            .update(m1, at: 8),
            .update(m1, at: 9),
        ])
        XCTAssert(ud2.count == 11, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2) === m1)
        XCTAssert(ud2._element(at: 3) === m2)
        XCTAssert(ud2._element(at: 4) === m2)
        XCTAssert(ud2._element(at: 5) === m3)
        XCTAssert(ud2._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 7) === m1)
        XCTAssert(ud2._element(at: 8) === m1)
        XCTAssert(ud2._element(at: 9) === m1)
        XCTAssert(ud2._element(at: 10) === m1)
        
        // 随机更新(头)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m4, at: 0),
            .update(m4, at: 3),
            .update(m4, at: 4),
        ])
        XCTAssert(ud2.count == 14, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m4)
        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 3) === m1)
        XCTAssert(ud2._element(at: 4) === m1)
        XCTAssert(ud2._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 6) === m4)
        XCTAssert(ud2._element(at: 7) === m4)
        XCTAssert(ud2._element(at: 8)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 9) === m3)
        XCTAssert(ud2._element(at: 10) === m3)
        XCTAssert(ud2._element(at: 11)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 12) === m4)
        XCTAssert(ud2._element(at: 13) === m4)
        
        // 随机更新(中)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m3, at: 2),
            .update(m3, at: 3),
            .update(m3, at: 6),
            .update(m3, at: 7),
        ])
        XCTAssert(ud2.count == 12, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 3) === m3)
        XCTAssert(ud2._element(at: 4) === m3)
        XCTAssert(ud2._element(at: 5) === m2)
        XCTAssert(ud2._element(at: 6) === m3)
        XCTAssert(ud2._element(at: 7) === m3)
        XCTAssert(ud2._element(at: 8) === m3)
        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 10) === m4)
        XCTAssert(ud2._element(at: 11) === m4)
        
        // 随机更新(尾)
        ud2._elements = _reset(elements: ude2)
        up2._computeItemUpdates([
            .update(m4, at: 4),
            .update(m4, at: 5),
            .update(m3, at: 8),
            .update(m3, at: 9),
        ])
        XCTAssert(ud2.count == 11, "update error!")
        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 1) === m1)
        XCTAssert(ud2._element(at: 2) === m1)
        XCTAssert(ud2._element(at: 3) === m2)
        XCTAssert(ud2._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 5) === m4)
        XCTAssert(ud2._element(at: 6) === m4)
        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
        XCTAssert(ud2._element(at: 8) === m3)
        XCTAssert(ud2._element(at: 9) === m3)
        XCTAssert(ud2._element(at: 10) === m3)
    }
    
    func testMove() {
        
        let md1 = SACChatViewData()
        let up1 = SACChatViewUpdate(model: md1)
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m2, at: 0),
            .insert(m3, at: 0),
            .insert(m4, at: 0),
        ])
        let mde1 = md1._elements
        XCTAssert(md1.count == 6, "insert error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        
        // 空移动
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 0, to: 0),
        ])
        XCTAssert(md1.count == 6, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        
        // 无效移动(TimeLine)
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 0, to: 1),
        ])
        XCTAssert(md1.count == 6, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        
        // 普通移动(头)
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 1, to: 2),
        ])
        XCTAssert(md1.count == 7, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m2)
        XCTAssert(md1._element(at: 2) === m1)
        XCTAssert(md1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 4) === m3)
        XCTAssert(md1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 6) === m4)
        
        // 普通移动(中间) - 交换位置
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 2, to: 3),
        ])
        XCTAssert(md1.count == 7, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4) === m2)
        XCTAssert(md1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 6) === m4)

        // 普通移动(尾)
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 5, to: 2),
        ])
        XCTAssert(md1.count == 7, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 4) === m4)
        XCTAssert(md1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 6) === m3)
        
        // ..
        md1._elements = _reset(elements: mde1)
        up1._computeItemUpdates([
            .move(at: 2, to: 5),
        ])
        XCTAssert(md1.count == 8, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        XCTAssert(md1._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 7) === m2)
    }
 
    let m1 = SACMessage(content: SACMessageTextContent(text: "m1"))
    let m2 = SACMessage(content: SACMessageTextContent(text: "m2"))
    let m3 = SACMessage(content: SACMessageTextContent(text: "m3"))
    let m4 = SACMessage(content: SACMessageTextContent(text: "m4"))
}
