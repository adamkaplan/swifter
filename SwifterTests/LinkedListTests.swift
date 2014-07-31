//
//  LinkedListTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/26/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class LinkedListTests: XCTestCase {

    func testInit() {
        let l1 = LinkedList(this: 10)
        XCTAssertEqual(l1.this!, 10)
        assertNil(l1.next)
        assertNil(l1.prev)
    }
    
    func testPush() {
        let l1 = LinkedList(this: "Cat")
        l1.push("Kitten")
        XCTAssertEqual(l1.this!, "Kitten")
        XCTAssertEqual(l1.next!.this!, "Cat")
        XCTAssertEqual(l1.next!.prev!.this!, "Kitten")
        assertNil(l1.next!.next)
        assertNil(l1.prev)
    }
    
    func testPop() {
        let l1 = LinkedList(this: "Cat")
        l1.push("Kitten")
        l1.push("Kitty")
        XCTAssertEqual(l1.pop()!, "Kitty")
        XCTAssertEqual(l1.next!.prev!.this!, "Kitten")
        XCTAssertEqual(l1.this!, "Kitten")
        XCTAssertEqual(l1.next!.this!, "Cat")
        assertNil(l1.next!.next)
        assertNil(l1.prev)
    }
    
    func testAppend1() -> () {
        let l1 = LinkedList(this: "Cat")
        let l2 = LinkedList(this: "Kitty")
        l2.append("Kitten")
        XCTAssertEqual(l2.this!, "Kitty")
        XCTAssertEqual(l2.next!.this!, "Kitten")
        XCTAssertEqual(l2.next!.prev!.this!, "Kitty")
        l1.append(l2)
        XCTAssertEqual(l1.this!, "Cat")
        XCTAssertEqual(l1.next!.this!, "Kitty")
        XCTAssertEqual(l1.next!.prev!.this!, "Cat")
        XCTAssertEqual(l1.next!.next!.this!, "Kitten")
        assertNil(l1.next!.next!.next)
    }
    
    func testIsEmpty() {
        let l1 = LinkedList<Int>()
        XCTAssertTrue(l1.isEmpty())
        
        let l2 = LinkedList(this: 10)
        XCTAssertFalse(l2.isEmpty())
        l2.pop()
        XCTAssertTrue(l2.isEmpty())
    }
    
    func testSequence() {
        let l1 = LinkedList<Int>()
        l1.push(3)
        l1.push(2)
        l1.push(1)
        l1.push(0)
        
        var counter = 0
        for i in l1 {
            XCTAssertEqual(i, counter++)
        }
        
        XCTAssertEqual(l1.pop()!, 0)
        XCTAssertEqual(l1.pop()!, 1)
        XCTAssertEqual(l1.pop()!, 2)
        XCTAssertEqual(l1.pop()!, 3)
        XCTAssertTrue(l1.isEmpty())
    }

}
