//
//  ListTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

private let l0 = List<Int>()
private let l1 = List<Int>(1, l0)
private let l2 = List<Int>(2, l1)
private let l3 = List<Int>(3, l1)
private let l4 = List<Int>(4, l3)

class ListTests: XCTestCase {
    
    func testLeftFold() -> () {
        let fold = l4.leftFold(0) {
            (fold: Int, elem: Int) -> Int in
            return -fold + elem
        }
        XCTAssertEqual(fold, 2)
    }
    
    func testRightFold() -> () {
        let fold = l4.rightFold(0) {
            (elem: Int, fold: Int) -> Int in
            return -elem + fold
        }
        XCTAssertEqual(fold, -8)
    }
    
    func testHead() -> () {
        assertNil(l0.head())
        XCTAssertEqual(l3.head()!, 3)
    }
    
    func testTail() -> () {
        assertNil(l0.tail())
        XCTAssertEqual(l4.tail()!.head()!, l3.head()!)
    }
    
    func testIsEmpty() -> () {
        XCTAssertTrue(l0.isEmpty())
        XCTAssertFalse(l2.isEmpty())
    }
    
    func testReverse() -> () {
        assertNil(l0.reverse().head())
        XCTAssertEqual(l1.reverse().head()!, 1)
        XCTAssertEqual(l3.reverse().head()!, 1)
    }
    
    func testReverseMap() -> () {
        assertNil(l0.reverseMap { $0 * 10 }.head())
        XCTAssertEqual(l1.reverseMap { $0 * 10 }.head()!, 10)
        XCTAssertEqual(l3.reverseMap { $0 * 10 }.head()!, 10)
    }
    
    func testMap() -> () {
        assertNil(l0.map { $0 * 10 }.head())
        XCTAssertEqual(l1.map { $0 * 10 }.head()!, 10)
        XCTAssertEqual(l3.map { $0 * 10 }.head()!, 30)
        let sum: List<Int> -> Int = { $0.leftFold(0, +) }
        XCTAssertEqual(sum(l2.map { $0 * 10}), 10 * sum(l2))
    }
    
    func testReverseFilter() -> () {
        assertNil(l0.reverseFilter { _ in true }.head())
        assertNil(l1.reverseFilter { $0 % 2 == 0 }.head())
        XCTAssertEqual(l1.reverseFilter { $0 % 2 == 1 }.head()!, 1)
        XCTAssertEqual(l2.reverseFilter { $0 % 2 == 0 }.head()!, 2)
        XCTAssertEqual(l2.reverseFilter { $0 % 2 == 1 }.head()!, 1)
        XCTAssertEqual(l2.reverseFilter { $0 % 2 == 0 }.length(), 1)
        XCTAssertEqual(l3.reverseFilter { $0 % 2 == 1 }.head()!, 1)
        XCTAssertEqual(l3.reverseFilter { $0 % 2 == 1 }.length(), 2)
    }
    
    func testFilter() -> () {
        assertNil(l0.filter { _ in true }.head())
        assertNil(l1.filter { $0 % 2 == 0 }.head())
        XCTAssertEqual(l1.filter { $0 % 2 == 1 }.head()!, 1)
        XCTAssertEqual(l2.filter { $0 % 2 == 0 }.head()!, 2)
        XCTAssertEqual(l2.filter { $0 % 2 == 1 }.head()!, 1)
        XCTAssertEqual(l2.filter { $0 % 2 == 0 }.length(), 1)
        XCTAssertEqual(l3.filter { $0 % 2 == 1 }.head()!, 3)
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
        XCTAssertTrue(l4trues.equal(List(4, List()), ==))
        XCTAssertTrue(l4falses.equal(List(3, List(1, List())), ==))
    }

}
