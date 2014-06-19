//
//  FutureTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class FutureTests: XCTestCase {

    func testWaitFor() {
        NSLog("Beginning of testWaitFor()")
        var result: Int?
        
        let c: (() -> ()) = { _ in
            var x: Int = 5
            var y: Int = 0;
            var z: Int = Int.max/100
            while (z-- > 0) {}
            while x > 0 {
                y += x--
            }
            result = y
        }
        
        let f = Future(c)
        
        NSLog("This is a test of the concurrency.")
        
        XCTAssertNil(result)
        f.waitFor()
        XCTAssertEqualObjects(result!, 15)
        
        NSLog("Ending of testWaitFor()")
    }
    
    func testMap() {
        NSLog("Beginning of testMap()")
        
        let c: (() -> Int) = { _ in
            var x: Int = 5
            var y: Int = 0;
            var z: Int = Int.max/100
            while (z-- > 0) {}
            while x > 0 {
                y += x--
            }
            return y
        }
        
        let f = Future(function:c)
        
        f
        >=> { NSLog("This is \($0)") }
        >=> { _ in NSLog("These tests are finished!") }
        
        f
            >=> { _ in 1 }
            >=> { 10 * $0 }
            >=> { NSLog("%d", $0) }
        
        NSLog("After Future is created.")
        
        f.waitFor()
        
        NSLog("The Future is Now")
    }
}
