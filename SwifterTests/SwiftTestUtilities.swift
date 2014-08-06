//
//  SwiftTestUtilities.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/7/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

let STALL = Int.max/100

//let mainRunLoop = NSRunLoop.mainRunLoop()

func assertNil<T>(expression: T?, _ message: String = "") -> () {
    let isSome = expression ? true : false
    XCTAssertFalse(isSome, message)
}

func assertArraysEqual<T: Equatable>(one: [T], two: [T]) -> () {
    XCTAssertTrue(one ==== two)
} 

operator infix ==== {}
public func ==== <T: Equatable> (left: Array<T>, right: Array<T>) -> Bool {
    return left.reduce((left.count == right.count, 0)) {
        (acc: (Bool, Int), leftElem: T) in
        let (eq, id) = acc
        let rightElem = right[id]
        return (eq && (leftElem == rightElem), id + 1)
        }.0
}

class UtilitiesTests: XCTestCase {
    
    func testAssertNil1() -> () {
        let nilInt: Int? = nil
        assertNil(nilInt)
    }
    
//    func testAssertNil2() -> () {
//        assertNil(5)
//    }
    
    func testAssertEqualArrays1() -> () {
        assertArraysEqual([1], [1])
    }
    
//    func testAssertEqualArrays2() -> () {
//        assertArraysEqual([1], [1,2])
//    }
//    
//    func testAssertEqualArrays3() -> () {
//        assertArraysEqual([1,3],[1,2])
//    }
    
}
