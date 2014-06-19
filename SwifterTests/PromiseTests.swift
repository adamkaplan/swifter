//
//  PromiseTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class PromiseTests: XCTestCase {
    
    func testFill() -> () {
        let p: Promise<Int> = Promise()
        
        p.fill(5)
        
        if let r = p.peek() as? Int {
            XCTAssertEqualObjects(r, 5)
        }
    }
    
    func testIsFulfilled() -> () {
        let p: Promise<Int> = Promise()
        
        if p.isFulfilled() {
            XCTFail()
        }
        
        p.fill(5)
        
        if !p.isFulfilled() {
            XCTFail()
        }
    }

}
