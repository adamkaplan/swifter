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
        let ll1 = LinkedList<Int>(head: 10)
        XCTAssertEqual(ll1.head!.head, 10)
        XCTAssertNil(ll1.head!.next)
        XCTAssertTrue(ll1.head! === ll1.last)

        let ll2 = LinkedList<String>(head: "Cat", next: LinkedList<String>(head: "Kitten"))
        XCTAssertEqual(ll2.head!.head, "Cat")
        XCTAssertEqual(ll2.head!.next!.head, "Kitten")
        XCTAssertNil(ll2.head!.next!.next)
        XCTAssertTrue(ll2.head!.next! === ll2.last)
    }
    
    func testPush() {
        let ll = LinkedList<Int>(head: 10)
        ll.push(11)
        XCTAssertEqual(ll.head!.head, 11)
        XCTAssertEqual(ll.head!.next!.head, 10)
        XCTAssertNil(ll.head!.next!.next)
        XCTAssertTrue(ll.head!.next! === ll.last)
    }
    
    func testAdd() {
        let ll = LinkedList<Int>(head: 10)
        ll.add(11)
        XCTAssertEqual(ll.head!.head, 10)
        XCTAssertEqual(ll.head!.next!.head, 11)
        XCTAssertNil(ll.head!.next!.next)
        XCTAssertTrue(ll.head!.next! === ll.last)
    }
    
    func testPop() {
        let ll = LinkedList<Int>(head: 10)
        ll.push(11)
        ll.push(12)
        XCTAssertEqual(ll.pop()!, 12)
        XCTAssertEqual(ll.head!.head, 11)
        XCTAssertEqual(ll.head!.next!.head, 10)
        XCTAssertNil(ll.head!.next!.next)
        XCTAssertTrue(ll.head!.next! === ll.last)
        XCTAssertEqual(ll.pop()!, 11)
        XCTAssertEqual(ll.head!.head, 10)
        XCTAssertNil(ll.head!.next)
        XCTAssertTrue(ll.head! === ll.last)
        XCTAssertEqual(ll.pop()!, 10)
        XCTAssertNil(ll.head)
    }

}
