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
        XCTAssertEqual(li.this!, 10)
        assertNil(li.next)
        assertNil(li.prev)
    }
    
    func testPush() {
        let ls = LinkedList<String>(this: "Cat")
        ls.push("Kitten")
        XCTAssertEqual(ls.this!, "Kitten")
        XCTAssertEqual(ls.next!.this!, "Cat")
        XCTAssertEqual(ls.next!.prev!.this!, "Kitten")
        assertNil(ls.next!.next)
        assertNil(ls.prev)
    }
    
    func testPop() {
        let ls = LinkedList<String>(this: "Cat")
        ls.push("Kitten")
        ls.push("Kitty")
        XCTAssertEqual(ls.pop()!, "Kitty")
        XCTAssertEqual(ls.next!.prev!.this!, "Kitten")
        XCTAssertEqual(ls.this!, "Kitten")
        XCTAssertEqual(ls.next!.this!, "Cat")
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
    
    func testSequence() {
        let ll = LinkedList<Int>()
        ll.push(3)
        ll.push(2)
        ll.push(1)
        ll.push(0)
        
        var counter: Int = 0
        for i in ll {
            XCTAssertEqual(i, counter++)
        }
        
        XCTAssertEqual(ll.pop()!, 0)
        XCTAssertEqual(ll.pop()!, 1)
        XCTAssertEqual(ll.pop()!, 2)
        XCTAssertEqual(ll.pop()!, 3)
        XCTAssertTrue(ll.isEmpty())
    }

}
