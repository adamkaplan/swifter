//
//  FutureTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class FutureTests: XCTestCase {

    func testValue() -> () {
        XCTAssertEqual(Future(10).value!, 10)
        
        var onComplete = false
        let f1 = Future<String> {
            sleep(1)
            onComplete = true
            return "f1 is finished"
        }
        while !onComplete {
            assertNil(f1.value)
        }
        do {} while !f1.value
        XCTAssertEqual(f1.value!, "f1 is finished")
        
        let p2 = Promise<Int>()
        let f2 = Future(linkedPromise: p2)
        assertNil(f2.value)
        p2.tryFulfill(25)
        do {} while !f2.value
        XCTAssertEqual(f2.value!, 25)
        
        let p3 = Promise<String>()
        let f3 = Future(copiedPromise: p3)
        XCTAssertFalse(p3 === f3.promise)
        p3.tryFulfill("Copy this.")
        do {} while !f3.value
        XCTAssertEqual(f3.value!, "Copy this.")
    }
    
    func testMap() -> () {
        let f1 = Future<String> {
            sleep(1)
            return "f1 is finished"
        }
        let f1m: Future<Bool> = f1.map {
            var result = false
            switch $0 {
            case "f1 is finished":
                result = true
            default:
                result = false
            }
            return result
        }
        do {} while !f1m.value
        XCTAssertTrue(f1m.value!)

        let p2 = Promise<Int>()
        let f2 = Future(linkedPromise: p2)
        let f2m = f2.map { "\($0)" }
        p2.tryFulfill(100)
        do {} while !f2m.value
        XCTAssertEqual(f2m.value!, "100")
    }

    func testBind() -> () {
        let f1 = Future<Int> {
            sleep(1)
            return 100
        }
        let f2: Future<Int> = f1.bind {
            sleep(1);
            return Future(-$0)
        }
        do {} while !f2.value
        XCTAssertEqual(f2.value!, -100)
    }
    
    func testOnComplete() -> () {
        var onSuccess = false
        var onFailure = false
        let pf: PartialFunction<Try<Int>,Try<Int>> =
            { $0.isSuccess() } =|= { _ in onSuccess = !onSuccess; return Try.Success([5]) } |
            { $0.isFailure() } =|= { _ in onFailure = !onFailure; return Try.Success([5]) }
        
        let p1 = Promise<Try<Int>>(.Success([100]))
        let f1 = Future(linkedPromise: p1)
        f1.onComplete(pf)
        do {} while !onSuccess
        do {} while onFailure
        
        let p2 = Promise<Try<Int>>(.Failure(NSException()))
        let f2 = Future<Try<Int>>(linkedPromise: p2)
        f2.onComplete(pf)
        do {} while !onSuccess
        do {} while !onFailure
    }
    
    func testAndThen() -> () {
        let pf: PartialFunction<Try<Int>,String> =
            { $0.toOption() ? $0.unwrap() > 25 : false } =|= { _ in "G" } |
            { $0.toOption() ? $0.unwrap() < 25 : false } =|= { _ in "L" } |
            { _ in true } =|= { _ in "Default" }
        
        let p1 = Promise<Try<Int>>(.Success([100]))
        let f1 = Future(linkedPromise: p1)
        let f1at = f1.andThen(pf)
        do {} while !f1at.value
        XCTAssertEqual(f1at.value!.unwrap(), "G")
        
        let p2 = Promise<Try<Int>>(.Success([20]))
        let f2 = Future(linkedPromise: p2)
        let f2at = f2.andThen(pf)
        do {} while !f2at.value
        XCTAssertEqual(f2at.value!.unwrap(), "L")
        
        let p3 = Promise<Try<Int>>(.Failure(NSException()))
        let f3 = Future(linkedPromise: p3)
        let f3at = f3.andThen(pf)
        do {} while !f3at.value
        XCTAssertEqual(f3at.value!.unwrap(), "Default")
    }

    func testAnd() -> () {
        let f1 = Future<Int> {
            sleep(1)
            return 100
        }
        let f2 = Future<String> {
            sleep(1)
            return "Hello"
        }
        let f3 = f1.and(f2)
        do {} while !f3.value
        let v1 = f3.value!
        XCTAssertEqual(v1.0, 100)
        XCTAssertEqual(v1.1, "Hello")
    }
    
    func testCompletedResult() -> () {
        let f1 = Future(10)
        XCTAssertEqual(f1.completedResult, 10)
    }
    
    func testIsComplete() -> () {
        let f1 = Future(10)
        XCTAssertTrue(f1.isComplete())
        XCTAssertEqual(f1.value!, 10)
        
        let f2 = Future<String> {
            sleep(1)
            return "Hello"
        }
        do {} while !f2.isComplete()
        XCTAssertEqual(f2.value!, "Hello")
    }
    
//    func testAwait() -> () { // TODO REMOVE WORKAR
//        let f1 = Future<String> {
//            sleep(1)
//            return "Hello"
//        }
//        XCTAssertEqual(f1.await().value!, "Hello")
//    }
    
}
