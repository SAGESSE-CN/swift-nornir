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
    
    
//    func testIndex() {
//        let m = SACMessage(content: SACMessageTextContent())
//        let d = SACChatViewData()
//        d._elements = [m,m,m]
//        
//        XCTAssert(d._convert(index: -5) == 0)
//        XCTAssert(d._convert(index: -4) == 0)
//        XCTAssert(d._convert(index: -3) == 1)
//        XCTAssert(d._convert(index: -1) == 3)
//        XCTAssert(d._convert(index: +0) == 0)
//        XCTAssert(d._convert(index: +1) == 1)
//        XCTAssert(d._convert(index: +3) == 3)
//        XCTAssert(d._convert(index: +4) == 3)
//        
//        XCTAssert(d._convert(indexs: []) == [])
//        XCTAssert(d._convert(indexs: [1]) == [1,1])
//        XCTAssert(d._convert(indexs: [1,2,3]) == [1,3])
//        XCTAssert(d._convert(indexs: [1,2,4]) == [1,2,4,4])
//        XCTAssert(d._convert(indexs: [1,2,2,4]) == [1,2,4,4])
//    }
    
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
        up4._computeItemUpdates([
            .insert(m2, at: 2),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        XCTAssert(ad4._element(at: 3) === m2)
        
        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m2, at: 0),
        ])
        XCTAssert(ad4.count == 3, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m2)
        XCTAssert(ad4._element(at: 2) === m1)

        ad4._elements = ade4
        up4._computeItemUpdates([
            .insert(m4, at: 0),
        ])
        XCTAssert(ad4.count == 4, "insert error!")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m4)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m1)
        
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
//    func testRemove() {
//        
//        let rd1 = SACChatViewData()
//        rd1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
//        let rde1 = rd1._elements
//        XCTAssert(rd1.count == 6, "insert error!")
//        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 1) === m1)
//        XCTAssert(rd1._element(at: 2) === m2)
//        XCTAssert(rd1._element(at: 3) === m3)
//        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 5) === m4)
//        
//        // 普通删除
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [0]) // 删除TimeLine(头部)
//        XCTAssert(rd1.count == 6, "remove error!")
//        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 1) === m1)
//        
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [4]) // 删除TimeLine(尾部)
//        XCTAssert(rd1.count == 6, "remove error!")
//        XCTAssert(rd1._element(at: 3) === m3)
//        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 5) === m4)
//        
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [1]) // 普通删除(头部)
//        XCTAssert(rd1.count == 5, "remove error!")
//        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 1) === m2)
//        
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [3]) // 普通删除(中间)
//        XCTAssert(rd1.count == 5, "remove error!")
//        XCTAssert(rd1._element(at: 2) === m2)
//        XCTAssert(rd1._element(at: 3)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 4) === m4)
//        
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [2]) // 普通删除(中间), 产生TimeLine
//        XCTAssert(rd1.count == 6, "remove error!")
//        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 1) === m1)
//        XCTAssert(rd1._element(at: 2)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 3) === m3)
//        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd1._element(at: 5) === m4)
//        
//        rd1._elements = rde1
//        rd1.remove(contentsOf: [5]) // 普通删除(尾部)
//        XCTAssert(rd1.count == 4, "remove error!")
//        XCTAssert(rd1._element(at: 3) === m3)
//        
//        let rd2 = SACChatViewData()
//        rd2.insert(contentsOf: [m1,m1,m2,m2,m3,m3,m4,m4], at: 0)
//        let rde2 = rd2._elements
//        XCTAssert(rd2.count == 10, "insert error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3) === m2)
//        XCTAssert(rd2._element(at: 4) === m2)
//        XCTAssert(rd2._element(at: 5) === m3)
//        XCTAssert(rd2._element(at: 6) === m3)
//        XCTAssert(rd2._element(at: 7)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 8) === m4)
//        XCTAssert(rd2._element(at: 9) === m4)
//
//        // 连续删除
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [0,1,2,3,4]) // 连续删除(头)
//        XCTAssert(rd2.count == 6, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m3)
//        XCTAssert(rd2._element(at: 2) === m3)
//        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 4) === m4)
//        XCTAssert(rd2._element(at: 5) === m4)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [3,4]) // 连续删除(中), 自动添加TimeLine
//        XCTAssert(rd2.count == 9, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 4) === m3)
//        XCTAssert(rd2._element(at: 5) === m3)
//        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 7) === m4)
//        XCTAssert(rd2._element(at: 8) === m4)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [4,5]) // 连续删除(中)
//        XCTAssert(rd2.count == 8, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3) === m2)
//        XCTAssert(rd2._element(at: 4) === m3)
//        XCTAssert(rd2._element(at: 5)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 6) === m4)
//        XCTAssert(rd2._element(at: 7) === m4)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [8,9]) // 连续删除(尾), 自动删除TimeLine
//        XCTAssert(rd2.count == 7, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3) === m2)
//        XCTAssert(rd2._element(at: 4) === m2)
//        XCTAssert(rd2._element(at: 5) === m3)
//        XCTAssert(rd2._element(at: 6) === m3)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [7,8,9]) // 连续删除(尾), 手动删除TimeLine
//        XCTAssert(rd2.count == 7, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3) === m2)
//        XCTAssert(rd2._element(at: 4) === m2)
//        XCTAssert(rd2._element(at: 5) === m3)
//        XCTAssert(rd2._element(at: 6) === m3)
//        
//        // 随机删除
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [0,4]) // 随机删除(头)
//        XCTAssert(rd2.count == 9, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3) === m2)
//        XCTAssert(rd2._element(at: 4) === m3)
//        XCTAssert(rd2._element(at: 5) === m3)
//        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 7) === m4)
//        XCTAssert(rd2._element(at: 8) === m4)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [1,2,6,7]) // 随机删除(中)
//        XCTAssert(rd2.count == 7, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m2)
//        XCTAssert(rd2._element(at: 2) === m2)
//        XCTAssert(rd2._element(at: 3) === m3)
//        XCTAssert(rd2._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 5) === m4)
//        XCTAssert(rd2._element(at: 6) === m4)
//        
//        rd2._elements = rde2
//        rd2.remove(contentsOf: [3,4,5,8,9]) // 随机删除(尾)
//        XCTAssert(rd2.count == 5, "remove error!")
//        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 1) === m1)
//        XCTAssert(rd2._element(at: 2) === m1)
//        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
//        XCTAssert(rd2._element(at: 4) === m3)
//    }
//    
//    func testUpdate() {
//        
//        let ud1 = SACChatViewData()
//        ud1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
//        let ude1 = ud1._elements
//        XCTAssert(ud1.count == 6, "insert error!")
//        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 1) === m1)
//        XCTAssert(ud1._element(at: 2) === m2)
//        XCTAssert(ud1._element(at: 3) === m3)
//        XCTAssert(ud1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 5) === m4)
//        
//        // 普通更新
//        ud1._elements = ude1
//        ud1.update(contentsOf: [m2], at: [0]) // 普通更新(头)
//        XCTAssert(ud1.count == 7, "update error!")
//        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 1) === m2)
//        XCTAssert(ud1._element(at: 2) === m1)
//        XCTAssert(ud1._element(at: 3) === m2)
//        XCTAssert(ud1._element(at: 4) === m3)
//        XCTAssert(ud1._element(at: 5)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 6) === m4)
//        
//        ud1._elements = ude1
//        ud1.update(contentsOf: [m4], at: [2]) // 普通更新(中)
//        XCTAssert(ud1.count == 8, "update error!")
//        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 1) === m1)
//        XCTAssert(ud1._element(at: 2)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 3) === m4)
//        XCTAssert(ud1._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 5) === m3)
//        XCTAssert(ud1._element(at: 6)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 7) === m4)
//        
//        ud1._elements = ude1
//        ud1.update(contentsOf: [m3], at: [5]) // 普通更新(尾)
//        XCTAssert(ud1.count == 5, "update error!")
//        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud1._element(at: 1) === m1)
//        XCTAssert(ud1._element(at: 2) === m2)
//        XCTAssert(ud1._element(at: 3) === m3)
//        XCTAssert(ud1._element(at: 4) === m3)
//        
//        let ud2 = SACChatViewData()
//        ud2.insert(contentsOf: [m1,m1,m2,m2,m3,m3,m4,m4], at: 0)
//        let ude2 = ud2._elements
//        XCTAssert(ud2.count == 10, "insert error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2) === m1)
//        XCTAssert(ud2._element(at: 3) === m2)
//        XCTAssert(ud2._element(at: 4) === m2)
//        XCTAssert(ud2._element(at: 5) === m3)
//        XCTAssert(ud2._element(at: 6) === m3)
//        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 8) === m4)
//        XCTAssert(ud2._element(at: 9) === m4)
//        
//        // 连续更新
//        ud2._elements = ude2
//        ud2.update(contentsOf: [], at: []) // 连续更新(空)
//        XCTAssert(ud2.count == 10, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2) === m1)
//        XCTAssert(ud2._element(at: 3) === m2)
//        XCTAssert(ud2._element(at: 4) === m2)
//        XCTAssert(ud2._element(at: 5) === m3)
//        XCTAssert(ud2._element(at: 6) === m3)
//        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 8) === m4)
//        XCTAssert(ud2._element(at: 9) === m4)
//        
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m4,m4,m4], at: [0,1,2]) // 连续更新(头)
//        XCTAssert(ud2.count == 12, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m4)
//        XCTAssert(ud2._element(at: 2) === m4)
//        XCTAssert(ud2._element(at: 3) === m4)
//        XCTAssert(ud2._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 5) === m2)
//        XCTAssert(ud2._element(at: 6) === m2)
//        XCTAssert(ud2._element(at: 7) === m3)
//        XCTAssert(ud2._element(at: 8) === m3)
//        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 10) === m4)
//        XCTAssert(ud2._element(at: 11) === m4)
//        
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m4,m4,m4,m4], at: [2,3,4,5]) // 连续更新(中)
//        XCTAssert(ud2.count == 12, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 3) === m4)
//        XCTAssert(ud2._element(at: 4) === m4)
//        XCTAssert(ud2._element(at: 5) === m4)
//        XCTAssert(ud2._element(at: 6) === m4)
//        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 8) === m3)
//        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 10) === m4)
//        XCTAssert(ud2._element(at: 11) === m4)
//       
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m1,m1,m1,m1], at: [6,7,8,9]) // 连续更新(尾)
//        XCTAssert(ud2.count == 11, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2) === m1)
//        XCTAssert(ud2._element(at: 3) === m2)
//        XCTAssert(ud2._element(at: 4) === m2)
//        XCTAssert(ud2._element(at: 5) === m3)
//        XCTAssert(ud2._element(at: 6)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 7) === m1)
//        XCTAssert(ud2._element(at: 8) === m1)
//        XCTAssert(ud2._element(at: 9) === m1)
//        XCTAssert(ud2._element(at: 10) === m1)
//        
//        // 随机更新
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m4,m4,m4], at: [0,3,4]) // 随机更新(头)
//        XCTAssert(ud2.count == 14, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m4)
//        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 3) === m1)
//        XCTAssert(ud2._element(at: 4) === m1)
//        XCTAssert(ud2._element(at: 5)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 6) === m4)
//        XCTAssert(ud2._element(at: 7) === m4)
//        XCTAssert(ud2._element(at: 8)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 9) === m3)
//        XCTAssert(ud2._element(at: 10) === m3)
//        XCTAssert(ud2._element(at: 11)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 12) === m4)
//        XCTAssert(ud2._element(at: 13) === m4)
//        
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m3,m3,m3,m3], at: [2,3,6,7]) // 随机更新(中)
//        XCTAssert(ud2.count == 12, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 3) === m3)
//        XCTAssert(ud2._element(at: 4) === m3)
//        XCTAssert(ud2._element(at: 5) === m2)
//        XCTAssert(ud2._element(at: 6) === m3)
//        XCTAssert(ud2._element(at: 7) === m3)
//        XCTAssert(ud2._element(at: 8) === m3)
//        XCTAssert(ud2._element(at: 9)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 10) === m4)
//        XCTAssert(ud2._element(at: 11) === m4)
//        
//        ud2._elements = ude2
//        ud2.update(contentsOf: [m4,m4,m3,m3], at: [4,5,8,9]) // 随机更新(尾)
//        XCTAssert(ud2.count == 11, "update error!")
//        XCTAssert(ud2._element(at: 0)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 1) === m1)
//        XCTAssert(ud2._element(at: 2) === m1)
//        XCTAssert(ud2._element(at: 3) === m2)
//        XCTAssert(ud2._element(at: 4)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 5) === m4)
//        XCTAssert(ud2._element(at: 6) === m4)
//        XCTAssert(ud2._element(at: 7)?.content is SACMessageTimeLineContent)
//        XCTAssert(ud2._element(at: 8) === m3)
//        XCTAssert(ud2._element(at: 9) === m3)
//        XCTAssert(ud2._element(at: 10) === m3)
//    }
//    
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
