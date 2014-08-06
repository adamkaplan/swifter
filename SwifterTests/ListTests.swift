////
////  ListTests.swift
////  Swifter
////
////  Created by Daniel Hanggi on 7/17/14.
////  Copyright (c) 2014 Yahoo!. All rights reserved.
////
//
//import XCTest
//
//class ListTests: XCTestCase {
//
//    func testHead() -> () {
//        let list: List<Int> = List.cons(10, List.cons(20, List.Nil))
//        let it: Int = List.head(list)
//        XCTAssertEqual(it, 10)
//    }
//    
//    func testTail() -> () {
//        let list: List<Int> = 10 ++ 20 ++ .Nil
//        let its: List<Int> = List.tail(list)
//        let it: Int = List.head(its)
//        XCTAssertEqual(it, 20)
//    }
//    
//    func testReverse() -> () {
//        let list: List<Int> = 10 ++ 20 ++ .Nil
//        let listRev: List<Int> = List.reverse(list)
//        XCTAssertEqual(List.head(list)!, List.head(List.tail(listRev)!)!)
//        XCTAssertEqual(List.head(List.tail(list)!)!, List.head(listRev)!)
//    }
//    
//    func testMember() -> () {
//        let list: List<Int> = 10 ++ 20 ++ .Nil
//        XCTAssertTrue(List.member(list, 10))
//        XCTAssertFalse(List.member(list, 11))
//    }
//    
//    func testNth() -> () {
//        let list: List<Int> = 10 ++ 20 ++ .Nil
//        XCTAssertEqual(List.nth(0, list)!, 10)
//        XCTAssertEqual(List.nth(1, list)!, 20)
//        assertNil(List.nth(2, list))
//    }
//    
//    func testLength() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        XCTAssertEqual(List.length(list), 2)
//        XCTAssertEqual(List.length(.Nil), 0)
//    }
//    
//    func testLast() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        XCTAssertEqual(last(list)!, 20)
//    }
//    
//    func testPartition() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        let (let15, gt15) = partition(list) { $0 <= 15 }
//        XCTAssertEqual(List.head(let15)!, 10)
//        XCTAssertEqual(List.head(gt15)!, 20)
//    }
//    
//    func testMap() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        let listMap = map(list) { -$0 }
//        XCTAssertEqual(List.head(listMap)!, -10)
//        XCTAssertEqual(List.head(List.tail(listMap)!)!, -20)
//    }
//    
//    func testReverseMap() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        let listRevMap = List.reverseMap(list) { -$0 }
//        XCTAssertEqual(List.head(listRevMap)!, -20)
//        XCTAssertEqual(List.head(List.tail(listRevMap)!)!, -10)
//    }
//    
//    func testReverseFilter() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        let listFilter1 = List.filter(list) { $0 > 15 }
//        XCTAssertEqual(List.head(listFilter1)!, 20)
//        assertNil(List.head(List.tail(listFilter1)!)!)
//    }
//    
//    func testFilter() -> () {}
//    
//    func testUpdate() -> () {
//        let list = List.cons(10, List.cons(20, .Nil))
//        let listUpdate = List.update(0, 30, list)
//        XCTAssertEqual(List.head(listUpdate)!, 30)
//        XCTAssertEqual(List.head(List.tail(listUpdate)!)!, 20)
//    }
//    
//}
