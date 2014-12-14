//
//  PromiseTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class PromiseTests: XCTestCase {
    
    func testFold() -> () {
        var onFulfilled = false
        var onPending = false
        
        let p1 = Promise<Int>()
        p1.fold({ _ in onFulfilled = true }, { _ in onPending = true })
        XCTAssertFalse(onFulfilled)
        XCTAssertTrue(onPending)
        
        let p2 = Promise("Hello")
        p2.fold({ _ in onFulfilled = true }, { _ in onPending = false })
        XCTAssertTrue(onFulfilled)
        XCTAssertTrue(onPending)
    }
    
    func testTryFulfill() -> () {
        let p1 = Promise<Try<Int>>()
        XCTAssertTrue(p1.tryFulfill(.Success([10])))
        XCTAssertEqual(p1.value!.toOption()!, 10)
        XCTAssertFalse(p1.tryFulfill(.Success([11])))
        XCTAssertEqual(p1.value!.unwrap(), 10)
    
        let p2 = Promise("Hello")
        XCTAssertFalse(p2.tryFulfill("Goodbye"))
        XCTAssertEqual(p2.value!, "Hello")
    }
    
    func testIsFulfilled() -> () {
        let p1 = Promise<Int>()
        XCTAssertFalse(p1.isFulfilled())
        
        let p2 = Promise("Hello")
        XCTAssertTrue(p2.isFulfilled())
    }
    
    func testAlsoFulfill() -> () {        
        let p1 = Promise<Int>()
        let p2 = Promise<Int>()
        p1.alsoFulfill(p2)
        p1.tryFulfill(10)
        XCTAssertEqual(p1.value!, 10)
        do {} while p2.value == nil
        XCTAssertEqual(p2.value!, 10)
        
        let p3 = Promise<String>("Hello")
        let p4 = Promise<String>()
        p3.alsoFulfill(p4)
        XCTAssertEqual(p3.value!, "Hello")
        do {} while p4.value == nil
        XCTAssertEqual(p4.value!, "Hello")
    }
    
    func testExecuteOrMap() -> () {
        var finishedExecuting = false
        var j: Int = 0
        let p1 = Promise<Int>()
        let e1 = Executable<Int>(queue: NSOperationQueue()) {
            _ in
            sleep(1)
            finishedExecuting = true
        }
        p1.executeOrMap(e1)
        p1.tryFulfill(0)
        do {} while !finishedExecuting
        
        finishedExecuting = false
        let p2 = Promise(0)
        let e2 = Executable<Int>(queue: NSOperationQueue()) {
            _ in
            finishedExecuting = true
        }
        p2.executeOrMap(e2)
        do {} while !finishedExecuting
    }

    func testOnComplete() -> () {
        var onComplete = false
        let p1 = Promise<Int>()
        p1.onComplete { _ in onComplete = true }
        XCTAssertFalse(onComplete)
        p1.tryFulfill(10)
        do {} while !onComplete
        
        onComplete = false
        let p2 = Promise(10)
        p2.onComplete { _ in onComplete = true }
        do {} while !onComplete
    }
    
    func testAwait() -> () {
        var finishedExecuting = false
        let p1 = Promise<Int>()
        let p2 = Promise<Int>()
        let e1 = Executable<Int>(queue: NSOperationQueue()) {
            sleep(1)
            finishedExecuting = true
            _ = p2.tryFulfill($0 + 125)
        }
        p1.executeOrMap(e1)
        p1.tryFulfill(0)
        XCTAssertEqual(p2.await().value!, 125)
        XCTAssertTrue(finishedExecuting)
    }
}
