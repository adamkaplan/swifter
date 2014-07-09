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
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = $0.isSuccess()
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue())
        
        exec.executeWithValue(.Success([10]))
        do {} while !onComplete
    }
    
}

class OnceExecutableTests: XCTestCase {
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = $0.isSuccess()
        }
        let exec = OnceExecutable<Int>(task: task, thread: NSOperationQueue())
        
        exec.executeWithValue(.Success([10]))
        do {} while !onComplete
        // TODO EXCEPTIONS
    }

}
