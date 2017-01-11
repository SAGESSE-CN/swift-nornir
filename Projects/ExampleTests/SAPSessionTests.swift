//
//  SAPSessionTests.swift
//  Example
//
//  Created by SAGESSE on 11/11/16.
//  Copyright © 2016-2017 SAGESSE. All rights reserved.
//

import UIKit
import XCTest
import Photos

import CoreGraphics

//@testable import SAPhotos
//
//class SAPSessionTests: XCTestCase {
//
//    override func setUp() {
//        super.setUp()
//        // Put setup code here. This method is called before the invocation of each test method in the class.
//        
//        let exp = self.expectation(description: "request authorization")
//        
//        SAPLibrary.shared.requestAuthorization { has in
//            XCTAssert(has, "request authorization")
//            exp.fulfill()
//        }
//        
//        self.session = SAPImageSession()
//        self.waitForExpectations(timeout: 100)
//    }
//    
//    override func tearDown() {
//        // Put teardown code here. This method is called after the invocation of each test method in the class.
//        super.tearDown()
//    }
//    
//    
//    func testReuqest() {
//        let asset: PHAsset! = SAPAlbum.albums.first?.fetchResult?.firstObject
//        
//        XCTAssert(asset != nil, "Not found asset")
//        
////        let exp = self.expectation(description: "request image task")
////        var count = 0
//        
//        let size = CGSize(width: asset.pixelWidth, height: asset.pixelWidth)
//        let request = SAPImageRequest(asset: asset, size: size, contentMode: .default)
//        
//        request.isNetworkAccessAllowed = true
//        request.isSynchronous = false
//        
////        let task = session.imageTask(with: request) 
////        self.waitForExpectations(timeout: 100)
////        print(task)
//    }
//    
//    var session: SAPImageSession!
//}
