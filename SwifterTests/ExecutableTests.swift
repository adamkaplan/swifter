//
//  ExecutableTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/2/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class ExecutableTests: XCTestCase {
    
    func testReceiveNotification() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = true
            XCTAssertEqual($0.unwrap(), 10)
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: self)
        let callbackValue = (Try<Int>.Success([10])).toObject()
        notificationCenter.postNotificationName(canExecuteNotification, object: self, userInfo: ["callbackValue" : callbackValue])
        do {} while !onComplete
    }
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = $0.isSuccess()
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: nil)
        
        exec.executeWithValue(.Success([10]))
        do {} while !onComplete
    }
    
}

class OnceExecutableTests: XCTestCase {
    
    func testReceiveNotification() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = true
            XCTAssertEqual($0.unwrap(), 10)
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: self)
        let callbackValue = (Try<Int>.Success([10])).toObject()
        notificationCenter.postNotificationName(canExecuteNotification, object: self, userInfo: ["callbackValue" : callbackValue])
        do {} while !onComplete
        notificationCenter.postNotificationName(canExecuteNotification, object: self, userInfo: ["callbackValue" : callbackValue])
    }
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = $0.isSuccess()
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: nil)
        
        exec.executeWithValue(.Success([10]))
        do {} while !onComplete
        // Test exception TODO
    }
 
    func test() -> () {
        measureBlock {
            var onComplete: Bool = false
            var j: Int = 0;
            do {} while j++ < Int.max/100
            onComplete = !onComplete
        }
    }
}
