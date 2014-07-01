//
//  SwiftTestUtilities.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/7/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

func assertNil<T where T: Equatable>(expression: T?) -> () {
    XCTAssertTrue(expression == nil)
}
