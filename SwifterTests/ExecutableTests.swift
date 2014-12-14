//
//  ExecutableTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/2/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class ExecutableTests: XCTestCase {
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        Executable(queue: NSOperationQueue()) {
            sleep(1)
            onComplete = $0
        }.executeWithValue(true)
        do {} while !onComplete
    }
    
}
