//
//  PromiseTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class PromiseTests: XCTestCase {

    func testInit() -> () {
        let promise1 = Promise<Int>()
        switch promise1.state {
        case .Fulfilled(_):
            XCTFail("Promise initialized without a value is .Fulfilled", file: "PromiseTests.swift", line: 17)
        default:
            ()
        }
        
        let promise2 = Promise<Int>(value: .Success([10]))
        switch promise2.state {
        case .Fulfilled(.Success([10])):
            ()
        default:
            XCTFail("Promise is not .Fulfilled(.Success([10]))", file: "PromiseTests.swift", line: 27)
        }
        
        let promise3 = Promise<Int>(value: .Failure(NSException()))
        switch promise3.state {
        case .Fulfilled(.Failure(_)):
            ()
        default:
            XCTFail("Promise is not .Fulfilled(.Failure(NSException))", file: "PromiseTests.swift", line: 35)
        }
    }
    
    func testFold() -> () {
        var onPending: Bool = false
        var onFulfilled: Bool = false
        
        let promise1 = Promise<Int>()
        promise1.fold({ _ in onFulfilled = true }, { _ in onPending = true })
        XCTAssertTrue(onPending)
        XCTAssertFalse(onFulfilled)
        
        let promise2 = Promise<String>(value: .Success(["Hello"]))
        promise2.fold({ _ in onFulfilled = true }, { _ in onPending = false })
        XCTAssertTrue(onPending)
        XCTAssertTrue(onFulfilled)
    }
    
    func testTryFulfill() -> () {
        let promise1 = Promise<Int>()
        XCTAssertTrue(promise1.tryFulfill(.Success([10])))
        XCTAssertEqual(promise1.value!.toOption()!, 10)
        XCTAssertFalse(promise1.tryFulfill(.Success([11])))
        XCTAssertEqual(promise1.value!.toOption()!, 10)
    
        let promise2 = Promise<String>(value: .Success(["Hello"]))
        XCTAssertFalse(promise2.tryFulfill(.Success(["Goodbye"])))
        XCTAssertEqualObjects(promise2.value!.toOption()!, "Hello")
    }
    
    func testIsFulfilled() -> () {
        let promise1 = Promise<Int>()
        XCTAssertFalse(promise1.isFulfilled())
        
        let promise2 = Promise<String>(value: .Success(["Hello"]))
        XCTAssertTrue(promise2.isFulfilled())
    }
    
    func testAlsoFulfill() -> () {
        // func alsoFulfill(promise: Promise<T>) -> ()
        
        let promise1 = Promise<Int>()
        let promise2 = Promise<Int>()
        promise1.alsoFulfill(promise2)
        promise1.tryFulfill(.Success([10]))
        XCTAssertEqual(promise1.value!.toOption()!, 10)
        do {} while !promise2.value
        XCTAssertEqual(promise2.value!.toOption()!, 10)
        
        let promise3 = Promise<String>(value: .Success(["Hello"]))
        let promise4 = Promise<String>()
        promise3.alsoFulfill(promise4)
        XCTAssertEqualObjects(promise3.value!.toOption()!, "Hello")
        do {} while !promise4.value
        XCTAssertEqualObjects(promise4.value!.toOption()!, "Hello")
    }
    
    func testExecuteOrMap() -> () {
        var finishedExecuting: Bool = false
        var j: Int = 0
        let promise1 = Promise<Int>()
        let exec1: Executable<Int> = Executable<Int>(task: {
            (ti: Try<Int>) -> () in
            var i = ti.toOption()!
            do { j++ } while i++ < STALL
            finishedExecuting = true
            }, thread: NSOperationQueue())//, observed: promise1)
        promise1.executeOrMap(exec1)
        promise1.tryFulfill(.Success([0]))
        while (j < STALL/2) {
            XCTAssertFalse(finishedExecuting)
        }
        while (true) {
            if (j == STALL) {
                XCTAssertTrue(finishedExecuting)
                break
            }
        }
        
        j = 0
        let promise2 = Promise<Int>(value: .Success([0]))
        let exec2: Executable<Int> = Executable<Int>(task: {
            (ti: Try<Int>) -> () in
            var i = ti.toOption()!
            do { j++ } while i++ < STALL
            finishedExecuting = true
            }, thread: NSOperationQueue())
        promise2.tryFulfill(.Success([0]))
        promise2.executeOrMap(exec2)
        while (true) {
            if (j == STALL) {
                XCTAssertTrue(finishedExecuting)
                break
            }
        }
    }

    func testOnComplete() -> () {
        var onComplete: Bool = false
        let promise1 = Promise<Int>()
        promise1.onComplete { _ in onComplete = true }
        XCTAssertFalse(onComplete)
        promise1.tryFulfill(.Success([10]))
        do {} while !onComplete
        
        onComplete = false
        let promise2 = Promise<Int>(value: .Success([10]))
        promise2.onComplete { _ in onComplete = true }
        do {} while !onComplete
    }
    

    
    func testAwait() -> () {
        var finishedExecuting: Bool = false
        let promise1 = Promise<Int>()
        let promise2 = Promise<Int>()
        let exec1: Executable<Int> = Executable<Int>(task: {
            (ti: Try<Int>) -> () in
            var i = ti.toOption()!
            do {} while ++i < STALL
            finishedExecuting = true
            promise2.tryFulfill(.Success([i]))
            }, thread: NSOperationQueue())
        promise1.executeOrMap(exec1)
        promise1.fulfill(.Success([0]))
        promise2.await()
        XCTAssertTrue(finishedExecuting)
        XCTAssertEqual(promise2.value!.toOption()!, STALL)
        
        let promise3 = Promise<Int>()
        promise3.DAwait(0)
        XCTAssertTrue(promise3.value!.isFailure())
    }
}

extension Promise {
    
    func DAwait(time: NSTimeInterval) -> () {
        self.timeout(time)
        while !self.isComplete() {
            NSRunLoop.mainRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
    }
    
}
