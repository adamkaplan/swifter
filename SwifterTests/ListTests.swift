//
//  ListTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

private let l0 = List<Int>()
private let l1 = List(1, l0)
private let l2 = List(2, l1)
private let l3 = List(3, l1)
private let l4 = List(4, l3)

class ListTests: XCTestCase {
    
    func testLeftFold() -> () {
        let fold: List<Int> -> Int = { $0.leftFold(0, { NSLog("(\($0.acc), \($0.elem), \(-$0.acc + $0.elem))"); return -$0.acc + $0.elem } ) }
        XCTAssertEqual(fold(l0), 00)
        XCTAssertEqual(fold(l1), 01)
        XCTAssertEqual(fold(l2), -1)
        XCTAssertEqual(fold(l3), -2)
        XCTAssertEqual(fold(l4), 02)
    }
    
    func testRightFold() -> () {
        let fold: List<Int> -> Int = { $0.leftFold(0, { -$0.elem + $0.acc } ) }
        XCTAssertEqual(fold(l0), 00)
        XCTAssertEqual(fold(l1), -1)
        XCTAssertEqual(fold(l2), -3)
        XCTAssertEqual(fold(l3), -4)
        XCTAssertEqual(fold(l4), -8)
    }
    
    func testHead() -> () {
        assertNil(l0.head())
        XCTAssertEqual(l1.head()!, 1)
        XCTAssertEqual(l2.head()!, 2)
        XCTAssertEqual(l3.head()!, 3)
        XCTAssertEqual(l4.head()!, 4)
    }
    
    func testTail() -> () {
        assertNil(l0.tail())
        assertNil(l1.tail()!.head())
        XCTAssertEqual(l2.tail()!.head()!, 1)
        XCTAssertEqual(l3.tail()!.head()!, 1)
        XCTAssertEqual(l4.tail()!.head()!, 3)
    }
    
    func testIsEmpty() -> () {
        XCTAssertTrue(l0.isEmpty())
        XCTAssertFalse(l1.isEmpty())
        XCTAssertFalse(l2.isEmpty())
        XCTAssertFalse(l3.isEmpty())
        XCTAssertFalse(l4.isEmpty())
    }
    
    func testReverse() -> () {
        XCTAssertTrue(l0.reverse().equal(l0, ==))
        XCTAssertTrue(l1.reverse().equal(l1, ==))
        XCTAssertTrue(l2.reverse().equal(1^^2, ==))
        XCTAssertTrue(l3.reverse().equal(1^^3, ==))
        XCTAssertTrue(l4.reverse().equal(1^^3^^4, ==))
    }
    
    func testReverseMap() -> () {
        XCTAssertTrue(l0.reverseMap { $0 * 10 }.equal(l0, ==))
        XCTAssertTrue(l1.reverseMap { $0 * 10 }.equal(10^^l0, ==))
        XCTAssertTrue(l2.reverseMap { $0 * 10 }.equal(10^^20, ==))
        XCTAssertTrue(l3.reverseMap { $0 * 10 }.equal(10^^30, ==))
        XCTAssertTrue(l4.reverseMap { $0 * 10 }.equal(10^^30^^40, ==))
    }
    
    func testMap() -> () {
        XCTAssertTrue(l0.map { $0 * 10 }.equal(l0, ==))
        XCTAssertTrue(l1.map { $0 * 10 }.equal(10^^l0, ==))
        XCTAssertTrue(l2.map { $0 * 10 }.equal(20^^10, ==))
        XCTAssertTrue(l3.map { $0 * 10 }.equal(30^^10, ==))
        XCTAssertTrue(l4.map { $0 * 10 }.equal(40^^30^^10, ==))
    }
    
    func testReverseFilter() -> () {
        XCTAssertTrue(l0.reverseFilter { _ in true }.equal(l0, eq: ==))
        XCTAssertTrue(l1.reverseFilter { $0 % 2 == 0 }.equal(l0, eq: ==))
        XCTAssertTrue(l1.reverseFilter { $0 % 2 == 1 }.equal(^[1], eq: ==))
        XCTAssertTrue(l2.reverseFilter { $0 % 2 == 0 }.equal(^[2], eq: ==))
        XCTAssertTrue(l2.reverseFilter { $0 % 2 == 1 }.equal(^[1], eq: ==))
        XCTAssertEqual(l2.reverseFilter { $0 % 2 == 0 }.length(), 1)
        XCTAssertTrue(l3.reverseFilter { $0 % 2 == 1 }.equal(^[1, 3], eq: ==))
        XCTAssertEqual(l3.reverseFilter { $0 % 2 == 1 }.length(), 2)
    }
    
    func testFilter() -> () {
        XCTAssertTrue(l0.filter { _ in true }.equal(l0, eq: ==))
        XCTAssertTrue(l1.filter { $0 % 2 == 0 }.equal(l0, eq: ==))
        XCTAssertTrue(l1.filter { $0 % 2 == 1 }.equal(^[1], eq: ==))
        XCTAssertTrue(l2.filter { $0 % 2 == 0 }.equal(^[2], eq: ==))
        XCTAssertTrue(l2.filter { $0 % 2 == 1 }.equal(^[1], eq: ==))
        XCTAssertEqual(l2.filter { $0 % 2 == 0 }.length(), 1)
        XCTAssertTrue(l3.filter { $0 % 2 == 1 }.equal(^[3, 1], eq: ==))
        XCTAssertEqual(l3.filter { $0 % 2 == 1 }.length(), 2)
    }
    
    func testAppend() -> () {
        let l5 = l1.append(l4)
        let l6 = l5.append(l5)
        let l7 = l6.append(l5)
        let l8 = l7.append(l7)
        let l9 = l5.append(l5).append(l5)
        let l10 = l6.append(l5).append(l5).append(l6)
        let l11 = l6.append(l6).append(l6).append(l6)
        
        XCTAssertEqual(l5.leftFold(0, +), 9)
        XCTAssertEqual(l5.head()!, 1)
        XCTAssertEqual(l5.last()!, 1)
        XCTAssertEqual(l5.nth(1)!, 4)
        XCTAssertEqual(l6.leftFold(0, +), 18)
        XCTAssertEqual(l6.length(), 8)
        XCTAssertTrue(l6.equal(1^^4^^3^^1^^1^^4^^3^^1, ==))
        XCTAssertTrue(l7.equal(l9, ==))
        XCTAssertTrue(l8.equal(l10, ==))
        XCTAssertFalse(l8.equal(l11, ==))
    }
    
    func testContains() -> () {
        XCTAssertFalse(l0.contains(1, ==))
        XCTAssertFalse(l1.contains(2, ==))
        XCTAssertTrue(l1.contains(1, ==))
    }
    
    func testNth() -> () {
        assertNil(l0.nth(0))
        assertNil(l0.nth(1))
        XCTAssertEqual(l1.nth(0)!, 1)
        assertNil(l1.nth(1))
        XCTAssertEqual(l4.nth(0)!, 4)
        XCTAssertEqual(l4.nth(2)!, 1)
    }
    
    func testLength() -> () {
        XCTAssertEqual(l0.length(), 0)
        XCTAssertEqual(l1.length(), 1)
        XCTAssertEqual(l2.length(), 2)
        XCTAssertEqual(l3.length(), 2)
        XCTAssertEqual(l4.length(), 3)
    }
    
    func testLast() -> () {
        assertNil(l0.last())
        XCTAssertEqual(l1.last()!, 1)
        XCTAssertEqual(l2.last()!, 1)
        XCTAssertEqual(l3.last()!, 1)
        XCTAssertEqual(l4.last()!, 1)
    }
    
    func testEqual() -> () {
        XCTAssertFalse(l0.equal(l1, ==))
        XCTAssertTrue(l0.equal(l0, ==))
        XCTAssertTrue(l2.equal(l2, ==))
        XCTAssertFalse(l3.equal(l4, ==))
        XCTAssertTrue(l3.equal(l4.tail()!, ==))
    }
    
    func testReversePartition() -> () {
        let (l0trues, l0falses) = l0.reversePartition { $0 % 2 == 0 }
        let (l1trues, l1falses) = l1.reversePartition { $0 % 2 == 0 }
        let (l2trues, l2falses) = l2.reversePartition { $0 % 2 == 0 }
        let (l3trues, l3falses) = l3.reversePartition { $0 % 2 == 0 }
        let (l4trues, l4falses) = l4.reversePartition { $0 % 2 == 0 }
        
        XCTAssertTrue(l0trues.isEmpty())
        XCTAssertTrue(l0falses.isEmpty())
        XCTAssertTrue(l1trues.isEmpty())
        XCTAssertTrue(l1falses.equal(l1, ==))
        XCTAssertEqual(l2trues.nth(0)!, 2)
        XCTAssertEqual(l2trues.length(), 1)
        XCTAssertTrue(l2falses.equal(l1, ==))
        XCTAssertTrue(l4trues.equal(^[4], ==))
        XCTAssertTrue(l4falses.equal(1^^3, ==))
    }
    
    func testPartition() -> () {
        let (l0trues, l0falses) = l0.partition { $0 % 2 == 0 }
        let (l1trues, l1falses) = l1.partition { $0 % 2 == 0 }
        let (l2trues, l2falses) = l2.partition { $0 % 2 == 0 }
        let (l3trues, l3falses) = l3.partition { $0 % 2 == 0 }
        let (l4trues, l4falses) = l4.partition { $0 % 2 == 0 }
        
        XCTAssertTrue(l0trues.isEmpty())
        XCTAssertTrue(l0falses.isEmpty())
        XCTAssertTrue(l1trues.isEmpty())
        XCTAssertTrue(l1falses.equal(l1, ==))
        XCTAssertEqual(l2trues.nth(0)!, 2)
        XCTAssertEqual(l2trues.length(), 1)
        XCTAssertTrue(l2falses.equal(l1, ==))
        XCTAssertTrue(l4trues.equal(^[4], ==))
        XCTAssertTrue(l4falses.equal(3^^1, ==))
    }

}
