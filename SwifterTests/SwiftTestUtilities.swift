//
//  SwiftTestUtilities.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/7/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

func assertNil<T>(expression: T?, _ message: String = "") -> () {
    if expression {
        XCTFail("assertNil: expression is not nil")
    }
}

func assertArraysEqual<T: Equatable>(one: [T], two: [T]) -> () {
    let initEq = (one.count - two.count) == 0
    XCTAssertTrue(one.reduce((initEq, 0)) {
        (acc: (Bool, Int), fstElem: T) in
        let (eq, id) = acc
        let sndElem = two[id]
        return (eq && (fstElem == sndElem), id + 1)
        }.0)
}
