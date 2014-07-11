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
