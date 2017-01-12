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
    
    
    func testIndex() {
        let m = SACMessage(content: SACMessageTextContent())
        let d = SACChatViewData()
        d._elements = [m,m,m]
        
        XCTAssert(d._convert(index: -5) == 0)
        XCTAssert(d._convert(index: -4) == 0)
        XCTAssert(d._convert(index: -3) == 1)
        XCTAssert(d._convert(index: -1) == 3)
        XCTAssert(d._convert(index: +0) == 0)
        XCTAssert(d._convert(index: +1) == 1)
        XCTAssert(d._convert(index: +3) == 3)
        XCTAssert(d._convert(index: +4) == 3)
        
        XCTAssert(d._convert(indexs: []) == [])
        XCTAssert(d._convert(indexs: [1]) == [1,1])
        XCTAssert(d._convert(indexs: [1,2,3]) == [1,3])
        XCTAssert(d._convert(indexs: [1,2,4]) == [1,2,4,4])
        XCTAssert(d._convert(indexs: [1,2,2,4]) == [1,2,4,4])
    }
    
    func testInsert() {
        
        // 初次添加
        let ad1 = SACChatViewData()
        ad1.insert(m1, at: 0)
        XCTAssert(ad1.count == 2, "insert or convert error")
        XCTAssert(ad1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad1._element(at: 1) === m1)
        
        let ad2 = SACChatViewData()
        ad2.insert(contentsOf: [m1, m2], at: 0)
        XCTAssert(ad2.count == 3, "insert or convert error")
        XCTAssert(ad2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad2._element(at: 1) === m1)
        XCTAssert(ad2._element(at: 2) === m2)
        
        let ad3 = SACChatViewData()
        ad3.insert(contentsOf: [m1, m3], at: 0)
        XCTAssert(ad3.count == 4, "insert is error")
        XCTAssert(ad3._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad3._element(at: 1) === m1)
        XCTAssert(ad3._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad3._element(at: 3) === m3)
        
        // 增量添加
        let ad4 = SACChatViewData()
        ad4.insert(contentsOf: [m1], at: 0)
        let ade4 = ad4._elements
        XCTAssert(ad4.count == 2, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m2], at: -1) // 普通插入(尾部)
        XCTAssert(ad4.count == 3, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m2], at: -1)
        XCTAssert(ad4.count == 3, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        ad4.insert(contentsOf: [m2], at: 2) // 普通插入(中间)
        XCTAssert(ad4.count == 4, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        XCTAssert(ad4._element(at: 3) === m2)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m2], at: 0) // 普通插入(头部)
        XCTAssert(ad4.count == 3, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m2)
        XCTAssert(ad4._element(at: 2) === m1)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m4], at: 0) // 自动添加TimeLine(头部)
        XCTAssert(ad4.count == 4, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m4)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m1)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m4], at: -1) // 自动添加TimeLine(尾部)
        XCTAssert(ad4.count == 4, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m4)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m3], at: 2)
        XCTAssert(ad4.count == 4, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m3)
        ad4.insert(contentsOf: [m2], at: 2) // 自动移除TimeLine(中间)
        XCTAssert(ad4.count == 4, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        XCTAssert(ad4._element(at: 3) === m3)
        
        ad4._elements = ade4
        ad4.insert(contentsOf: [m2], at: 2)
        XCTAssert(ad4.count == 3, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2) === m2)
        ad4.insert(contentsOf: [m3], at: 2) // 自动添加TimeLine(中间)
        XCTAssert(ad4.count == 5, "insert is error")
        XCTAssert(ad4._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 1) === m1)
        XCTAssert(ad4._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(ad4._element(at: 3) === m3)
        XCTAssert(ad4._element(at: 4) === m2)
    }
    func testRemove() {
        
        let rd1 = SACChatViewData()
        rd1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
        let rde1 = rd1._elements
        XCTAssert(rd1.count == 6, "insert is error")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        // 普通删除
        rd1._elements = rde1
        rd1.remove(at: 0) // 删除TimeLine(头部)
        XCTAssert(rd1.count == 6, "remove is error")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        
        rd1._elements = rde1
        rd1.remove(at: 4) // 删除TimeLine(尾部)
        XCTAssert(rd1.count == 6, "remove is error")
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        rd1._elements = rde1
        rd1.remove(at: 1) // 普通删除(头部)
        XCTAssert(rd1.count == 5, "remove is error")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m2)
        
        rd1._elements = rde1
        rd1.remove(at: 3) // 普通删除(中间)
        XCTAssert(rd1.count == 5, "remove is error")
        XCTAssert(rd1._element(at: 2) === m2)
        XCTAssert(rd1._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 4) === m4)
        
        rd1._elements = rde1
        rd1.remove(at: 2) // 普通删除(中间), 产生TimeLine
        XCTAssert(rd1.count == 6, "remove is error")
        XCTAssert(rd1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 1) === m1)
        XCTAssert(rd1._element(at: 2)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 3) === m3)
        XCTAssert(rd1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd1._element(at: 5) === m4)
        
        rd1._elements = rde1
        rd1.remove(at: 5) // 普通删除(尾部)
        XCTAssert(rd1.count == 4, "remove is error")
        XCTAssert(rd1._element(at: 3) === m3)
        
        let rd2 = SACChatViewData()
        rd2.insert(contentsOf: [m1,m1,m2,m2,m3,m3,m4,m4], at: 0)
        let rde2 = rd2._elements
        XCTAssert(rd2.count == 10, "insert is error")
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
        rd2._elements = rde2
        rd2.remove(contentsOf: [0,1,2,3,4]) // 连续删除(头)
        XCTAssert(rd2.count == 6, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m3)
        XCTAssert(rd2._element(at: 2) === m3)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m4)
        XCTAssert(rd2._element(at: 5) === m4)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [3,4]) // 连续删除(中), 自动添加TimeLine
        XCTAssert(rd2.count == 9, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 7) === m4)
        XCTAssert(rd2._element(at: 8) === m4)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [4,5]) // 连续删除(中)
        XCTAssert(rd2.count == 8, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 6) === m4)
        XCTAssert(rd2._element(at: 7) === m4)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [8,9]) // 连续删除(尾), 自动删除TimeLine
        XCTAssert(rd2.count == 7, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m2)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6) === m3)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [7,8,9]) // 连续删除(尾), 手动删除TimeLine
        XCTAssert(rd2.count == 7, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m2)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6) === m3)
        
        // 随机删除
        rd2._elements = rde2
        rd2.remove(contentsOf: [0,4]) // 随机删除(头)
        XCTAssert(rd2.count == 9, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3) === m2)
        XCTAssert(rd2._element(at: 4) === m3)
        XCTAssert(rd2._element(at: 5) === m3)
        XCTAssert(rd2._element(at: 6)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 7) === m4)
        XCTAssert(rd2._element(at: 8) === m4)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [1,2,6,7]) // 随机删除(中)
        XCTAssert(rd2.count == 7, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m2)
        XCTAssert(rd2._element(at: 2) === m2)
        XCTAssert(rd2._element(at: 3) === m3)
        XCTAssert(rd2._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 5) === m4)
        XCTAssert(rd2._element(at: 6) === m4)
        
        rd2._elements = rde2
        rd2.remove(contentsOf: [3,4,5,8,9]) // 随机删除(尾)
        XCTAssert(rd2.count == 5, "remove is error")
        XCTAssert(rd2._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 1) === m1)
        XCTAssert(rd2._element(at: 2) === m1)
        XCTAssert(rd2._element(at: 3)?.content is SACMessageTimeLineContent)
        XCTAssert(rd2._element(at: 4) === m3)
    }
    
    func testUpdate() {
        
        let ud1 = SACChatViewData()
        ud1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
        let ude1 = ud1._elements
        XCTAssert(ud1.count == 6, "insert is error")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m1)
        XCTAssert(ud1._element(at: 2) === m2)
        XCTAssert(ud1._element(at: 3) === m3)
        XCTAssert(ud1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 5) === m4)
        
        // 普通更新
        ud1._elements = ude1
        ud1.update(m2, at: 0) // 普通更新(头)
        XCTAssert(ud1.count == 7, "update is error")
        XCTAssert(ud1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 1) === m2)
        XCTAssert(ud1._element(at: 2) === m1)
        XCTAssert(ud1._element(at: 3) === m2)
        XCTAssert(ud1._element(at: 4) === m3)
        XCTAssert(ud1._element(at: 5)?.content is SACMessageTimeLineContent)
        XCTAssert(ud1._element(at: 6) === m4)
        
    }
    
    func testMove() {
        
        let md1 = SACChatViewData()
        md1.insert(contentsOf: [m1,m2,m3,m4], at: 0)
        let mde1 = md1._elements
        XCTAssert(md1.count == 6, "insert is error")
        XCTAssert(md1._element(at: 0)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 1) === m1)
        XCTAssert(md1._element(at: 2) === m2)
        XCTAssert(md1._element(at: 3) === m3)
        XCTAssert(md1._element(at: 4)?.content is SACMessageTimeLineContent)
        XCTAssert(md1._element(at: 5) === m4)
        
        // 普通移动
        md1._elements = mde1
    }
    
    let m1 = SACMessage(content: SACMessageTextContent(text: "m1"))
    let m2 = SACMessage(content: SACMessageTextContent(text: "m2"))
    let m3 = SACMessage(content: SACMessageTextContent(text: "m3"))
    let m4 = SACMessage(content: SACMessageTextContent(text: "m4"))
}
