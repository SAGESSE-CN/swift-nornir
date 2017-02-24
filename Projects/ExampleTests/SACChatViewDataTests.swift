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
        guard index >= 0 && index < self.elements.count else {
            return nil
        }
        return self.elements[index]
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
        let cd2 = SACChatViewData()
        let cp1 = SACChatViewUpdate(newData: cd1, oldData: cd2, updateItems: [])
       
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
    }
    
    func testInsert() {
        
        let d1 = SACChatViewData()
        let d2 = SACChatViewData()
        let u1 = SACChatViewUpdate(newData: d2, oldData: d1, updateItems: [])
        
        let test = { (updateItems: Array<SACChatViewUpdateItem>) -> Array<SACMessageType> in
            d1.elements = self._reset(elements: d1.elements)
            _ = u1._computeItemUpdates(d2, d1, updateItems)
            return d2.elements
        }
        
        // insert for head
        XCTAssert(_equal(test([ .insert(m1, at: 0) ]), [tt,m1]))
        // insert for mid
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m2, at: 0) ]), [tt,m1,m2]))
        // insert for last
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m3, at: 0) ]), [tt,m1,tt,m3]))
        
        // incremental insert for generation template
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m2, at: 0) ]), [tt,m1,m2]))
        d1.elements = d2.elements // apply
        
        // incremental insert for tail
        XCTAssert(_equal(test([ .insert(m2, at: d1.count) ]), [tt,m1,m2,m2]))
        XCTAssert(_equal(test([ .insert(m4, at: d1.count) ]), [tt,m1,m2,tt,m4]))
        // incremental insert for mid
        XCTAssert(_equal(test([ .insert(m1, at: 2) ]), [tt,m1,m1,m2]))
        XCTAssert(_equal(test([ .insert(m4, at: 2) ]), [tt,m1,tt,m4,tt,m2]))
        // incremental insert for head
        XCTAssert(_equal(test([ .insert(m2, at: 0) ]), [tt,m2,m1,m2]))
        XCTAssert(_equal(test([ .insert(m4, at: 0) ]), [tt,m4,tt,m1,m2]))
        
        // incremental insert for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m3, at: 0) ]), [tt,m1,tt,m3]))
        d1.elements = d2.elements // apply
        
        // incremental insert for mid(auto remove time line)
        XCTAssert(_equal(test([ .insert(m2, at: 2) ]), [tt,m1,m2,m3]))
    }
    
    func testRemove() {
        
        let d1 = SACChatViewData()
        let d2 = SACChatViewData()
        let u1 = SACChatViewUpdate(newData: d2, oldData: d1, updateItems: [])
        
        let test = { (updateItems: Array<SACChatViewUpdateItem>) -> Array<SACMessageType> in
            d1.elements = self._reset(elements: d1.elements)
            _ = u1._computeItemUpdates(d2, d1, updateItems)
            return d2.elements
        }
        
        // remove for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m2, at: 0),
                                .insert(m3, at: 0),
                                .insert(m4, at: 0)]), [tt,m1,m2,m3,tt,m4]))
        d1.elements = d2.elements // apply
        
        // remove for head
        XCTAssert(_equal(test([ .remove(at: 0) ]), [tt,m1,m2,m3,tt,m4])) // remove time line
        XCTAssert(_equal(test([ .remove(at: 1) ]), [tt,m2,m3,tt,m4]))
        // remove for mid
        XCTAssert(_equal(test([ .remove(at: 3) ]), [tt,m1,m2,tt,m4]))
        XCTAssert(_equal(test([ .remove(at: 2) ]), [tt,m1,tt,m3,tt,m4])) // generation time line
        // remove for tail
        XCTAssert(_equal(test([ .remove(at: 4) ]), [tt,m1,m2,m3,tt,m4])) // remove time line(ignore)
        XCTAssert(_equal(test([ .remove(at: 5) ]), [tt,m1,m2,m3])) // remove time line(ignore)
        
        // continuum remove for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m1, at: 0),
                                .insert(m2, at: 0),
                                .insert(m2, at: 0),
                                .insert(m3, at: 0),
                                .insert(m3, at: 0),
                                .insert(m4, at: 0),
                                .insert(m4, at: 0)]), [tt,m1,m1,m2,m2,m3,m3,tt,m4,m4]))
        d1.elements = d2.elements // apply
        
        // continuum remove for head
        XCTAssert(_equal(test([ .remove(at: 0),
                                .remove(at: 1),
                                .remove(at: 2),
                                .remove(at: 3),
                                .remove(at: 4)]), [tt,m3,m3,tt,m4,m4]))
        // continuum remove for mid
        XCTAssert(_equal(test([ .remove(at: 3),
                                .remove(at: 4)]), [tt,m1,m1,tt,m3,m3,tt,m4,m4])) // add time line
        XCTAssert(_equal(test([ .remove(at: 4),
                                .remove(at: 5)]), [tt,m1,m1,m2,m3,tt,m4,m4]))
        // continuum remove for tail
        XCTAssert(_equal(test([ .remove(at: 8),
                                .remove(at: 9)]), [tt,m1,m1,m2,m2,m3,m3]))
        XCTAssert(_equal(test([ .remove(at: 7),
                                .remove(at: 8),
                                .remove(at: 9)]), [tt,m1,m1,m2,m2,m3,m3]))
        
        // rand remove for head
        XCTAssert(_equal(test([ .remove(at: 0),
                                .remove(at: 4)]), [tt,m1,m1,m2,m3,m3,tt,m4,m4]))
        // rand remove for mid
        XCTAssert(_equal(test([ .remove(at: 1),
                                .remove(at: 2),
                                .remove(at: 6),
                                .remove(at: 7)]), [tt,m2,m2,m3,tt,m4,m4]))
        // rand remove for tail
        XCTAssert(_equal(test([ .remove(at: 3),
                                .remove(at: 4),
                                .remove(at: 5),
                                .remove(at: 8),
                                .remove(at: 9)]), [tt,m1,m1,tt,m3]))
    }
    
    func testUpdate() {
        
        let d1 = SACChatViewData()
        let d2 = SACChatViewData()
        let u1 = SACChatViewUpdate(newData: d2, oldData: d1, updateItems: [])
        
        let test = { (updateItems: Array<SACChatViewUpdateItem>) -> Array<SACMessageType> in
            d1.elements = self._reset(elements: d1.elements)
            _ = u1._computeItemUpdates(d2, d1, updateItems)
            return d2.elements
        }
        
        // update for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m2, at: 0),
                                .insert(m3, at: 0),
                                .insert(m4, at: 0)]), [tt,m1,m2,m3,tt,m4]))
        d1.elements = d2.elements // apply
        
        // update for head
        XCTAssert(_equal(test([ .update(m2, at: 0)]), [tt,m2,m1,m2,m3,tt,m4]))
        // update for mid
        XCTAssert(_equal(test([ .update(m4, at: 2)]), [tt,m1,tt,m4,tt,m3,tt,m4]))
        // update for tail
        XCTAssert(_equal(test([ .update(m3, at: 5)]), [tt,m1,m2,m3,m3]))
        
        // continuum update for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m1, at: 0),
                                .insert(m2, at: 0),
                                .insert(m2, at: 0),
                                .insert(m3, at: 0),
                                .insert(m3, at: 0),
                                .insert(m4, at: 0),
                                .insert(m4, at: 0)]), [tt,m1,m1,m2,m2,m3,m3,tt,m4,m4]))
        d1.elements = d2.elements // apply
        
        // continuum update for empty
        XCTAssert(_equal(test([ ]), [tt,m1,m1,m2,m2,m3,m3,tt,m4,m4]))
        // continuum update for head
        XCTAssert(_equal(test([ .update(m4, at: 0),
                                .update(m4, at: 1),
                                .update(m4, at: 2)]), [tt,m4,m4,m4,tt,m2,m2,m3,m3,tt,m4,m4]))
        // continuum update for mid
        XCTAssert(_equal(test([ .update(m4, at: 2),
                                .update(m4, at: 3),
                                .update(m4, at: 4),
                                .update(m4, at: 5)]), [tt,m1,tt,m4,m4,m4,m4,tt,m3,tt,m4,m4]))
        // continuum update for tail
        XCTAssert(_equal(test([ .update(m1, at: 6),
                                .update(m1, at: 7),
                                .update(m1, at: 8),
                                .update(m1, at: 9)]), [tt,m1,m1,m2,m2,m3,tt,m1,m1,m1,m1]))
        
        // random update for head
        XCTAssert(_equal(test([ .update(m4, at: 0),
                                .update(m4, at: 3),
                                .update(m4, at: 4)]), [tt,m4,tt,m1,m1,tt,m4,m4,tt,m3,m3,tt,m4,m4]))
        // random update for mid
        XCTAssert(_equal(test([ .update(m3, at: 2),
                                .update(m3, at: 3),
                                .update(m3, at: 6),
                                .update(m3, at: 7)]), [tt,m1,tt,m3,m3,m2,m3,m3,m3,tt,m4,m4]))
        // random update for tail
        XCTAssert(_equal(test([ .update(m4, at: 4),
                                .update(m4, at: 5),
                                .update(m3, at: 8),
                                .update(m3, at: 9)]), [tt,m1,m1,m2,tt,m4,m4,tt,m3,m3,m3]))
    }
    
    func testMove() {
        
        let d1 = SACChatViewData()
        let d2 = SACChatViewData()
        let u1 = SACChatViewUpdate(newData: d2, oldData: d1, updateItems: [])
        
        let test = { (updateItems: Array<SACChatViewUpdateItem>) -> Array<SACMessageType> in
            d1.elements = self._reset(elements: d1.elements)
            _ = u1._computeItemUpdates(d2, d1, updateItems)
            return d2.elements
        }
        
        // move for generation template
        d1.elements = [] // clear
        XCTAssert(_equal(test([ .insert(m1, at: 0),
                                .insert(m2, at: 0),
                                .insert(m3, at: 0),
                                .insert(m4, at: 0)]), [tt,m1,m2,m3,tt,m4]))
        d1.elements = d2.elements // apply
        
        // move for empty
        XCTAssert(_equal(test([ .move(at: 0, to: 0)]), [tt,m1,m2,m3,tt,m4]))
        // move for invalid
        XCTAssert(_equal(test([ .move(at: 0, to: 1)]), [tt,m1,m2,m3,tt,m4]))
        
        // move for head
        XCTAssert(_equal(test([ .move(at: 1, to: 2)]), [tt,m2,m1,tt,m3,tt,m4]))
        // move for mid
        XCTAssert(_equal(test([ .move(at: 2, to: 3)]), [tt,m1,tt,m3,m2,tt,m4]))
        // move for tail
        XCTAssert(_equal(test([ .move(at: 5, to: 2)]), [tt,m1,m2,tt,m4,tt,m3]))
        XCTAssert(_equal(test([ .move(at: 2, to: 5)]), [tt,m1,tt,m3,tt,m4,tt,m2]))
    }
    
    let tt = SACMessage(content: SACMessageTimeLineContent(date: .init()))
 
    let m1 = SACMessage(content: SACMessageTextContent(text: "m1"))
    let m2 = SACMessage(content: SACMessageTextContent(text: "m2"))
    let m3 = SACMessage(content: SACMessageTextContent(text: "m3"))
    let m4 = SACMessage(content: SACMessageTextContent(text: "m4"))
}
