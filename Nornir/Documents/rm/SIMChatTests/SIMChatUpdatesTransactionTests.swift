//
//  SIMChatUpdatesTransactionTests.swift
//  SIMChat
//
//  Created by sagesse on 2/21/16.
//  Copyright © 2016 sagesse. All rights reserved.
//

import XCTest
import SIMChat

class SIMChatUpdatesTransactionTests: XCTestCase {
    let updatesTransaction = UpdatesTransaction()
    
    class UpdatesTransaction: NSObject, UITableViewDataSource {
        override init() {
            super.init()
            view.dataSource = self
            view.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        }
        
        @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return datas.count
        }
        
        @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            return tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        }
        
        func resetData() {
            datas = ["t1","t2","t3","t4","t5","t6","t7"]
            view.reloadData()
        }
        
        var datas: Array<String> = []
        lazy var view: UITableView = UITableView()
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    // 插入测试
    func testUpdatesTransactionOfInsert() {
        updatesTransaction.datas = ["t1","t2","t3","t4"]
        updatesTransaction.view.reloadData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.insert("o1", atIndex: 0)
            $0.insert("o2", atIndex: 0)
            $0.insert("o3", atIndex: 1)
            $0.insert("o2", atIndex: 1)
            $0.insert("o5", atIndex: 3)
            $0.insert("o4", atIndex: 3)
            $0.insert("o6", atIndex: 4)
            $0.insert("o7", atIndex: 4)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "o1","o2","t1",
            "o3","o2","t2",
            "t3",
            "o5","o4","t4",
            "o6","o7"])
    }
    // 删除测试
    func testUpdatesTransactionOfRemove() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.removeAtIndex(0)
            $0.removeAtIndex(2)
            $0.removeAtIndex(4)
            $0.removeAtIndex(6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "t2","t4","t6"
            ])
    }
    // 移动测试
    func testUpdatesTransactionOfUpdate() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.reloadAtIndex(0)
            $0.reloadAtIndex(2)
            $0.reloadAtIndex(4)
            $0.reloadAtIndex(6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "t1","t2","t3","t4","t5","t6","t7"
            ])
    }
    // 移动测试
    func testUpdatesTransactionOfMove() {
        // 单个测试
        for x in [(0,1),(1,0),(5,6),(6,5),(2,4),(4,2),(0,6),(6,0),(0,0)] {
            updatesTransaction.resetData()
            var v = updatesTransaction.datas
            v.insert(v.removeAtIndex(x.0), atIndex: x.1)
            SIMLog.debug("B: \(updatesTransaction.datas)")
            SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
                $0.moveFromIndex(x.0, toIndex: x.1)
            }
            SIMLog.debug("E: \(updatesTransaction.datas)")
            SIMLog.debug("R: \(v)")
            SIMLog.debug("O: \(x)")
            XCTAssertEqual(updatesTransaction.datas, v)
        }
        // 多个测试
        for x in [[(6,0),(0,6)],[(2,4),(4,2)],[(0,1),(1,2)],[(0,6),(1,6)]] {
            updatesTransaction.resetData()
            var v = updatesTransaction.datas
            var v2 = v
            x.forEach {
                let d = v2[$0.0]
                if let idx = v.indexOf(d) {
                    v.removeAtIndex(idx)
                }
                v.insert(d, atIndex: $0.1)
            }
            SIMLog.debug("B: \(updatesTransaction.datas)")
            SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) { maker in
                x.forEach { maker.moveFromIndex($0.0, toIndex: $0.1) }
            }
            SIMLog.debug("E: \(updatesTransaction.datas)")
            SIMLog.debug("R: \(v)")
            SIMLog.debug("O: \(x)")
            
            //"t1","t2","t3","t4","t5","t6","t7"
            XCTAssertEqual(updatesTransaction.datas, v)
        }
    }
    // 综合测试: 插入和删除
    func testUpdatesTransactionOfInsertAndRemove() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.insert("o1", atIndex: 0)
            $0.insert("o2", atIndex: 0)
            $0.insert("o3", atIndex: 4)
            $0.insert("o4", atIndex: 4)
            $0.insert("o5", atIndex: 6)
            $0.insert("o6", atIndex: 6)
            $0.insert("o7", atIndex: 7)
            $0.insert("o8", atIndex: 7)
            $0.removeAtIndex(0)
            $0.removeAtIndex(4)
            $0.removeAtIndex(6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            // insert
            //"o1","o2","t1","t2","t3","t4","o3","o4","t5","t6","o5","o6","t7","o7","o8"
            // insert+remove
            "o1","o2","t2","t3","t4","o3","o4","t6","o5","o6","o7","o8"
            ])
        
    }
    // 综合测试: 插入和移动
    func testUpdatesTransactionOfInserAndMove() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.insert("o1", atIndex: 0)
            $0.insert("o2", atIndex: 4)
            $0.insert("o3", atIndex: 6)
            $0.insert("o4", atIndex: 7)
            $0.moveFromIndex(0, toIndex: 4)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            // insert
            //"o1","t1","t2","t3","t4","o2","t5","t6","o3","t7","o4"
            // insert+move
            "o1","t2","t3","t4","o2","t5","t1","t6","o3","t7","o4"
            ])
        
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.insert("--", atIndex: 7)
            $0.moveFromIndex(0, toIndex: 6)
            $0.insert("--", atIndex: 7)
            $0.moveFromIndex(1, toIndex: 6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "t3","t4","t5","t6","t7","--","t1","--","t2"
            ])
    }
    // 删除和移动
    func testUpdatesTransactionOfRemoveAndMove() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.removeAtIndex(6)
            $0.moveFromIndex(0, toIndex: 6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "t2","t3","t4","t5","t6","t1"
            ])
    }
    // 综合测试: 插入和删除和移动
    func testUpdatesTransactionOfAll() {
        updatesTransaction.resetData()
        SIMLog.debug("B: \(updatesTransaction.datas)")
        SIMChatUpdatesTransactionPerform(updatesTransaction.view, &updatesTransaction.datas, true) {
            $0.removeAtIndex(6)
            $0.insert("--", atIndex: 7)
            $0.moveFromIndex(0, toIndex: 6)
            $0.insert("--", atIndex: 7)
            $0.moveFromIndex(1, toIndex: 6)
        }
        SIMLog.debug("E: \(updatesTransaction.datas)")
        XCTAssertEqual(updatesTransaction.datas, [
            "t3","t4","t5","t6","--","t1","--","t2"
            ])
    }
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
}
