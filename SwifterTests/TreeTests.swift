//
//  TreeTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/23/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

private let t0: Tree<Int> = Leaf()
private let t1: Tree<Int> = Node(t0, 1, t0)
private let t2: Tree<Int> = Node(t1, 2, t1)
private let t3: Tree<Int> = Node(t1, 3, t2)
private let t4: Tree<Int> = Node(t3, 4, Leaf())

class TreeTests: XCTestCase {

    func testFold() -> () {
        let fold = t4.fold(1) {
            (left: Int, node: Int, right: Int) -> Int in
            return -node + left * right
        }
        XCTAssertEqual(fold, -7)
    }
    
    func testNode() -> () {
        assertNil(t0.node())
        XCTAssertEqual(t3.node()!, 3)
    }
    
    func testIsEmpty() -> () {
        XCTAssertTrue(t0.isEmpty())
        XCTAssertFalse(t2.isEmpty())
    }
    
    func testMap() -> () {
        assertNil(t0.map { $0 * 10 }.node())
        XCTAssertEqual(t1.map { $0 * 10 }.node()!, 10)
        XCTAssertEqual(t3.map { $0 * 10 }.node()!, 30)
        let sum: Tree<Int> -> Int = { $0.fold(0) { $0 + $1 + $2 } }
        XCTAssertEqual(sum(t2.map { $0 * 10}), 10 * sum(t2))
    }
    
    func testContains() -> () {
        XCTAssertFalse(t0.contains(1, ==))
        XCTAssertFalse(t1.contains(2, ==))
        XCTAssertTrue(t1.contains(1, ==))
    }
    
    func testSize() -> () {
        XCTAssertEqual(t0.count(), 0)
        XCTAssertEqual(t1.count(), 1)
        XCTAssertEqual(t2.count(), 3)
        XCTAssertEqual(t3.count(), 5)
        XCTAssertEqual(t4.count(), 6)
    }
    
    func testEqual() -> () {
        XCTAssertFalse(t0.equal(t1, ==))
        XCTAssertTrue(t0.equal(t0, ==))
        XCTAssertTrue(t2.equal(t2, ==))
        XCTAssertFalse(t3.equal(t4, ==))
        XCTAssertTrue(t3.equal(t4.leftSubtree()!, ==))
    }

}
