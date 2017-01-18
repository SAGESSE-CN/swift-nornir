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

class SACChatViewDataTests: XCTestCase {
    
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
    
    func testInsert() {
        
        // 初次添加
        let ad1 = SACChatViewData()
        let ade1 = ad1._elements
        let up1 = SACChatViewUpdate(model: ad1)
        
        // head
        ad1._elements = ade1
        up1._computeItemUpdates([
            .insert(m1, at: 0),
        ])
        XCTAssert(ad1.count == 2, "insert error")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        
        // mid
        ad1._elements = ade1
        up1._computeItemUpdates([
            .insert(m1, at: 0),
            .insert(m2, at: 0),
        ])
        XCTAssert(ad1.count == 3, "insert error")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        XCTAssert(ad1._element(at: 2) === m2)
        
        // last
        ad1._elements = ade1
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
        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m2, at: ad4.count),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        
        ad4._elements = ade4
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
        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m2, at: 0),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m2)
        XCTAssert(ad4._element(at: 2) === m1)
        
        // 自动添加TimeLine(头部)
        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m4, at: 0),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m4)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m1)
        
        // 自动添加TimeLine(尾部)
        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m4, at: ad4.count),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m4)
        
        ad4._elements = ade4
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
        
        ad4._elements = ade4
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
        rd1._elements = rde1
        up1._computeItemUpdates([
            .remove(at: 0)
        ])
        XCTAssert(rd1.count == 6, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        
        // 删除TimeLine(尾部)
        rd1._elements = rde1
        up1._computeItemUpdates([
            .remove(at: 4)
        ])
        XCTAssert(rd1.count == 6, "remove error!")
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        // 普通删除(头部)
        rd1._elements = rde1
        up1._computeItemUpdates([
            .remove(at: 1)
        ])
        XCTAssert(rd1.count == 5, "remove error!")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m2)
        
        // 普通删除(中间)
        rd1._elements = rde1
        up1._computeItemUpdates([
            .remove(at: 3)
        ])
        XCTAssert(rd1.count == 5, "remove error!")
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 4) === m4)
        
        // 普通删除(中间), 产生TimeLine
        rd1._elements = rde1
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
        rd1._elements = rde1
        up1._computeItemUpdates([
            .remove(at: 5)
        ])
        XCTAssert(rd1.count == 4, "remove error!")
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        rd2._elements = rde2
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
        ud1._elements = ude1
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
        ud1._elements = ude1
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
        ud1._elements = ude1
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        ud2._elements = ude2
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
        md1._elements = mde1
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
        md1._elements = mde1
        up1._computeItemUpdates([
            .move(at: 0, to: 2),
        ])
        XCTAssert(md1.count == 6, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        
        // 普通移动(头)
        md1._elements = mde1
        up1._computeItemUpdates([
            .move(at: 1, to: 3),
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
        md1._elements = mde1
        up1._computeItemUpdates([
            .move(at: 2, to: 4),
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
        md1._elements = mde1
        up1._computeItemUpdates([
            .move(at: 5, to: 3),
        ])
        XCTAssert(md1.count == 7, "move error!")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 4) === m4)
        XCTAssert(md1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 6) === m3)
    }
    
    func testOther() {
        // 初次添加
        let ad1 = SACChatViewData()
        let up1 = SACChatViewUpdate(model: ad1)
        
        up1._computeItemUpdates([
            .insert(m1, at: 0)
        ])
        up1._computeItemUpdates([
            .insert(m3, at: 1)
        ])
        up1._computeItemUpdates([
            .insert(m2, at: 2)
        ])
    }
    
//    func testBatchUpdates() {
//        
//        let bd1 = SACChatViewData()
//        bd1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
//        let bde1 = bd1._elements
//        XCTAssert(bd1.count == 6, "insert error!")
//        XCTAssert(bd1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(bd1._element(at: 1) === m1)
//        XCTAssert(bd1._element(at: 2) === m2)
//        XCTAssert(bd1._element(at: 3) === m3)
//        XCTAssert(bd1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(bd1._element(at: 5) === m4)
//        
//        // no imp
//        bd1._elements = bde1
////        bd1.performBatchUpdates({
////            // 移动
////            bd1.remove(at: 1)
////            bd1.insert(self.m1, at: 6)
////        })
////        XCTAssert(bd1.count == 7, "insert error!")
////        XCTAssert(bd1._element(at: 0)?.content is SACMessageTimeLineContent)
////        XCTAssert(bd1._element(at: 1) === m2)
////        XCTAssert(bd1._element(at: 2) === m3)
////        XCTAssert(bd1._element(at: 3)?.content is SACMessageTimeLineContent)
////        XCTAssert(bd1._element(at: 4) === m4)
////        XCTAssert(bd1._element(at: 5)?.content is SACMessageTimeLineContent)
////        XCTAssert(bd1._element(at: 6) === m1)
//    }
    
    let m1 = SACMessage(content: SACMessageTextContent(text: "m1"))
    let m2 = SACMessage(content: SACMessageTextContent(text: "m2"))
    let m3 = SACMessage(content: SACMessageTextContent(text: "m3"))
    let m4 = SACMessage(content: SACMessageTextContent(text: "m4"))
}
