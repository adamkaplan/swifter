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
        let li = LinkedList<Int>(this: 10)
        XCTAssertEqualObjects(li.this!, 10)
        assertNil(li.next)
        assertNil(li.prev)
    }
    
    func testPush() {
        let ls = LinkedList<String>(this: "Cat")
        ls.push("Kitten")
        XCTAssertEqualObjects(ls.this!, "Kitten")
        XCTAssertEqualObjects(ls.next!.this!, "Cat")
        XCTAssertEqualObjects(ls.next!.prev!.this, "Kitten")
        assertNil(ls.next!.next)
        assertNil(ls.prev)
    }
    
    func testPop() {
        let ls = LinkedList<String>(this: "Cat")
        ls.push("Kitten")
        ls.push("Kitty")
        XCTAssertEqualObjects(ls.pop(), "Kitty")
        XCTAssertEqualObjects(ls.next!.prev!.this, "Kitten")
        XCTAssertEqualObjects(ls.this!, "Kitten")
        XCTAssertEqualObjects(ls.next!.this!, "Cat")
        assertNil(ls.next!.next)
        assertNil(ls.prev)
    }
    
    func testIsEmpty() {
        let l1 = LinkedList<Int>()
        XCTAssertTrue(l1.isEmpty())
        
        let l2 = LinkedList<Int>(this: 10)
        XCTAssertFalse(l2.isEmpty())
        l2.pop()
        XCTAssertTrue(l2.isEmpty())
    }

}
