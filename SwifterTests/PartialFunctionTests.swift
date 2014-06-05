//
//  PartialFunctionTests.swift
//  Swifter
//
//  Created by Adam Kaplan on 6/5/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class PartialFunctionTests: XCTestCase {
    
    /*override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }*/

    func testCheckOnly() {
        var wasCheckOnly: Bool = false
        
        var reject = PartialFunction<Int, String> { (_, checkOnly: Bool) in
            wasCheckOnly = checkOnly
            return .NoMatch
        }
        
        reject.isDefinedAt(0)
        XCTAssertTrue(wasCheckOnly, "isDefinedAt must set `checkOnly` flag")
    }
    
    func testAccept() {
        var acceptEven = PartialFunction<Int, String> { (i: Int, _) in
            if i % 2 == 0 {
                return .Match("even")
            } else {
                return .NoMatch
            }
        }
        
        XCTAssertNil(acceptEven.apply(1), "1 is not even")
        XCTAssertEqualObjects(acceptEven.apply(2), "even", "2 is even")
    }
    
    func testApplyOrElse() {
        var pf1Called = false, pf2Called = false, pf1CalledBeforePf2 = false
        
        var reject = PartialFunction<Int, String> { _,_ in
            pf1Called = true
            return .NoMatch
        }
        
        var accept = PartialFunction<Int, String> { _,_ in
            pf2Called = true
            pf1CalledBeforePf2 = pf1Called
            return .Match("accepted")
        }
        
        let result1 = reject.applyOrElse(0, defaultFun: accept)
        XCTAssertTrue(pf1Called, "First partial function in applyOrElse was called")
        XCTAssertTrue(pf2Called, "Second partial function in applyOrElse was called")
        XCTAssertTrue(pf1CalledBeforePf2, "The first partial function must be called before the second in applyOrElse")
        XCTAssertEqualObjects(result1, "accepted", "The result should be `accept`")
        
        var acceptFirst = PartialFunction<Int, String> { (Int, Bool) in
            pf2Called = true
            pf1CalledBeforePf2 = pf1Called
            return .Match("bam!")
        }

        let result2 = acceptFirst.applyOrElse(0, defaultFun: accept)
        XCTAssertEqualObjects(result2, "bam!", "The result should be `accept`")
    }
    
    func testAndThen() {
        var firstCalled = false, secondCalled = false, firstCalledBeforeSecond = false, rejectCalled = false
        
        var reject = PartialFunction<Int, Int> { _,_ in
            rejectCalled = true
            return .NoMatch
        }
        
        var first = PartialFunction<Int, String> { _,_ in
            firstCalled = true
            return .Match("first")
        }
        
        var second = PartialFunction<String, String> { (s: String, Bool) in
            secondCalled = true
            firstCalledBeforeSecond = firstCalled
            if s == "first" {
                return .Match("second")
            } else {
                return .NoMatch
            }
        }
        
        let test1 = first.andThen(second)
        let success = test1.apply(0)
        XCTAssertTrue(firstCalled, "First partial function in applyOrElse was called")
        XCTAssertTrue(secondCalled, "Second partial function in applyOrElse was called")
        XCTAssertTrue(firstCalledBeforeSecond, "The first partial function should be called before the second in applyOrElse")
        XCTAssertEqualObjects(success, "second", "The result should be `second`")
        
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let fail = reject.andThen(test1).apply(0)
        XCTAssertTrue(rejectCalled, "Reject partial function should be called")
        XCTAssertFalse(firstCalled, "First partial function should not be called")
        XCTAssertFalse(secondCalled, "Second partial function should not be called")
        XCTAssertNil(fail, "Reject should not accept")
        
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let failTwice = reject.andThen(reject).apply(0)
        XCTAssertTrue(rejectCalled, "Reject partial function should be called")
        XCTAssertNil(failTwice, "Reject should not accept")
    }
    
    func testOrElse() {
        var firstCalled = false, secondCalled = false, firstCalledBeforeSecond = false
        var numCalls = 0
        
        var first = PartialFunction<Int, String> { _, _ in
            firstCalled = true
            firstCalledBeforeSecond = firstCalled
            numCalls++
            return .NoMatch
        }
        
        var second = PartialFunction<Int, String> { _, _ in
            secondCalled = true
            firstCalledBeforeSecond = firstCalled
            return .Match("second")
        }

        let right = first.orElse(second).apply(0)
        XCTAssertTrue(firstCalled, "First partial function in orElse was called")
        XCTAssertTrue(secondCalled, "Second partial function in orElse was called")
        XCTAssertTrue(firstCalledBeforeSecond, "The first partial function must be called before the second in orElse")
        XCTAssertEqualObjects(right, "second", "The result should be `second`")
        
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let left = second.orElse(first).apply(0)
        XCTAssertFalse(firstCalled, "First partial function should not be called")
        XCTAssertTrue(secondCalled, "Second partial function should be called")
        XCTAssertEqualObjects(left, "second", "The result should be `second`")
        
        numCalls = 0
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let none = first.orElse(first).apply(0)
        XCTAssertEqual(numCalls, 2, "First partial function should be called twice (not accepting)")
        XCTAssertNil(none, "The result should be nil when neither left or right accept")

    }
    
    /*func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }*/
}
