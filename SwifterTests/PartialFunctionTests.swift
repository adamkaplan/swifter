//
//  PartialFunctionTests.swift
//  Swifter
//
//  Created by Adam Kaplan on 6/5/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class PartialFunctionTests: XCTestCase {
    
    func testCheckOnly() -> () {
        var wasCheckOnly: Bool = false
        
        var reject = PartialFunction<Int, String> { (_, checkOnly: Bool) in
            wasCheckOnly = checkOnly
            return .Undefined
        }
        
        reject.isDefinedAt(0)
        XCTAssertTrue(wasCheckOnly, "isDefinedAt must set `checkOnly` flag")
    }
    
    func testAccept() -> () {
        var acceptEven = PartialFunction<Int, String> { (i: Int, _) in
            if i % 2 == 0 {
                return .Defined("even")
            } else {
                return .Undefined
            }
        }
        
        XCTAssertNil(acceptEven.apply(1), "1 is not even")
        XCTAssertEqual(acceptEven.apply(2)!, "even", "2 is even")
    }
    
    func testApplyOrElse() -> () {
        var pf1Called = false, pf2Called = false, pf1CalledBeforePf2 = false
        
        var reject = PartialFunction<Int, String> { _,_ in
            pf1Called = true
            return .Undefined
        }
        
        var accept = PartialFunction<Int, String> { _,_ in
            pf2Called = true
            pf1CalledBeforePf2 = pf1Called
            return .Defined("accepted")
        }
        
        let result1 = reject.applyOrElse(0, defaultPF: accept)
        XCTAssertTrue(pf1Called, "First partial function in applyOrElse was called")
        XCTAssertTrue(pf2Called, "Second partial function in applyOrElse was called")
        XCTAssertTrue(pf1CalledBeforePf2, "The first partial function must be called before the second in applyOrElse")
        XCTAssertEqual(result1!, "accepted", "The result should be `accept`")
        
        var acceptFirst = PartialFunction<Int, String> { (Int, Bool) in
            pf2Called = true
            pf1CalledBeforePf2 = pf1Called
            return .Defined("bam!")
        }
        
        let result2 = acceptFirst.applyOrElse(0, defaultPF: accept)
        XCTAssertEqual(result2!, "bam!", "The result should be `accept`")
    }
    
    func testOrElse() -> () {
        var firstCalled = false, secondCalled = false, firstCalledBeforeSecond = false
        var numCalls = 0
        
        var first = PartialFunction<Int, String> { _, _ in
            firstCalled = true
            firstCalledBeforeSecond = firstCalled
            numCalls++
            return .Undefined
        }
        
        var second = PartialFunction<Int, String> { _, _ in
            secondCalled = true
            firstCalledBeforeSecond = firstCalled
            return .Defined("second")
        }
        
        let right = first.orElse(second).apply(0)
        XCTAssertTrue(firstCalled, "First partial function in orElse was called")
        XCTAssertTrue(secondCalled, "Second partial function in orElse was called")
        XCTAssertTrue(firstCalledBeforeSecond, "The first partial function must be called before the second in orElse")
        XCTAssertEqual(right!, "second", "The result should be `second`")
        
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let left = second.orElse(first).apply(0)
        XCTAssertFalse(firstCalled, "First partial function should not be called")
        XCTAssertTrue(secondCalled, "Second partial function should be called")
        XCTAssertEqual(left!, "second", "The result should be `second`")
        
        numCalls = 0
        firstCalled = false
        secondCalled = false
        firstCalledBeforeSecond = false
        
        let none = first.orElse(first).apply(0)
        XCTAssertEqual(numCalls, 2, "First partial function should be called twice (not accepting)")
        XCTAssertNil(none, "The result should be nil when neither left or right accept")
        
    }
    
    func testAndThen() -> () {
        var firstCalled = false, secondCalled = false, firstCalledBeforeSecond = false, rejectCalled = false
        
        var reject = PartialFunction<Int, Int> { _,_ in
            rejectCalled = true
            return .Undefined
        }
        
        var first = PartialFunction<Int, String> { _,_ in
            firstCalled = true
            return .Defined("first")
        }
        
        var second = PartialFunction<String, String> { (s: String, Bool) in
            secondCalled = true
            firstCalledBeforeSecond = firstCalled
            if s == "first" {
                return .Defined("second")
            } else {
                return .Undefined
            }
        }
        
        let test1 = first.andThen(second)
        let success = test1.apply(0)
        XCTAssertTrue(firstCalled, "First partial function in applyOrElse was called")
        XCTAssertTrue(secondCalled, "Second partial function in applyOrElse was called")
        XCTAssertTrue(firstCalledBeforeSecond, "The first partial function should be called before the second in applyOrElse")
        XCTAssertEqual(success!, "second", "The result should be `second`")
        
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
    
    func testPatternMatch1() -> () {
        // match with
        // | n when n % 2 == 0 && n <= 10 -> Some +n
        // | n when n % 2 != 0 && n <= 10 -> Some -n
        // | _ -> None
        let patternMatch: PartialFunction<Int,Int> =
            PartialFunction<Int,Int>( {
                (i: Int, _) in
                if i % 2 == 0 && i <= 10 {
                    return .Defined(+i)
                } else {
                    return .Undefined
                }
                }) |
            PartialFunction<Int,Int>( {
                (i: Int, _) in
                if i % 2 != 0 && i <= 10 {
                    return .Defined(-i)
                } else {
                    return .Undefined
                }
                }) //| // TODO REMOVE WORKAROUND
//            ({ $0 % 2 == 0 && $0 <= 10 } >< { +$0 }) |
//            ({ $0 % 2 != 0 && $0 <= 10 } >< { -$0 })

        XCTAssertEqual(match(-5) { patternMatch }!, 05, "Second case")
        XCTAssertEqual(match(04) { patternMatch }!, 04, "First case")
        XCTAssertEqual(match(10) { patternMatch }!, 10, "First case")
        XCTAssertNil(match(11) { patternMatch})
    }
    
    func testPatternMatch2() -> () {
         // match with
         // | 1::2::_ -> Some "Hello"
         // | 0::1::_ -> Some "Goodbye"
         // | [3, a, 5] -> Some (string_of_int (5 * a))
         // | _ -> None
        let case1: PartialFunction<[Int],String> = { $0[0] == 1 && $0[1] == 2 && $0.count >= 3 } >< { _ in "Hello" }
        let case2: PartialFunction<[Int],String> = { $0[0] == 0 && $0[1] == 1 && $0.count >= 3 } >< { _ in "Goodbye" }
        let case3: PartialFunction<[Int],String> = { $0[0] == 3 && $0[2] == 5 && $0.count == 3 } >< { "\(5 * $0[1])" }
        let patternMatch: PartialFunction<[Int],String> =
            case1 |
            case2 |
            case3 //| // TODO REMOVE WORKAROUND
//            { $0[0] == 1 && $0[1] == 2 && $0.count >= 3 } >< { _ in "Hello" } |
//            { $0[0] == 0 && $0[1] == 1 && $0.count >= 3 } >< { _ in "Goodbye" } |
//            { $0[0] == 3 && $0[2] == 5 && $0.count == 3 } >< { "\(5 * $0[1])" }
        
        XCTAssertNil(match([1, 2]) { patternMatch })
        XCTAssertEqual(match([1, 2, 3]) { patternMatch }!, "Hello")
        XCTAssertEqual(match([0, 1, 2, 3, 4, 5]) { patternMatch }!, "Goodbye")
        XCTAssertEqual(match([3, 20, 5]) { patternMatch }!, "100")
        XCTAssertEqual(match([3, 0, 5]) { patternMatch }!, "0")
        XCTAssertNil(match([3, 4, 5, 6]) { patternMatch })
    }
    
}
