//
//  ExecutableTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/2/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

let canExecuteNotification = "CanExecuteNotification"
let notificationCenter = NSNotificationCenter.defaultCenter()

class ExecutableTests: XCTestCase {
    
    func testReceiveNotification() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max
            onComplete = true
            XCTAssertEqual($0.unwrap(), 10)
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: self)
        
        notificationCenter.postNotification(CallbackNotification(value: 10))
        do {} while !onComplete
    }
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        let task: (Any -> ()) = {
            _ in
            var j: Int = 0;
            do {} while j++ < Int.max
            onComplete = true
        }
        let exec = Executable<Any>(task: task, thread: NSOperationQueue(), observed: nil)
        
        exec.executeWithValue(.Success(10))
        do {} while !onComplete
    }
    
}

class OnceExecutableTests: XCTestCase {
    
    func testReceiveNotification() -> () {
        var onComplete: Bool = false
        let task: (Try<Int> -> ()) = {
            var j: Int = 0;
            do {} while j++ < Int.max
            onComplete = true
            XCTAssertEqual($0.unwrap(), 10)
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: self)
        
        notificationCenter.postNotification(CallbackNotification(value: 10))
        do {} while !onComplete
        notificationCenter.postNotification(CallbackNotification(value: 10))
    }
    
    func testExecuteWithValue() -> () {
        var onComplete: Bool = false
        let task: (Any -> ()) = {
            _ in
            var j: Int = 0;
            do {} while j++ < Int.max
            onComplete = true
        }
        let exec = Executable<Int>(task: task, thread: NSOperationQueue(), observed: nil)
        
        exec.executeWithValue(.Success(10))
        do {} while !onComplete
        // Test exception TODO
    }
    
}
