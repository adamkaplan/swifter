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
        let f1 = Future<Int>(value: 10)
        XCTAssertEqual(f1.value!.unwrap(), 10)
        
        var onComplete: Bool = false
        let f2 = Future<String>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            onComplete = true;
            return "f2 is finished"
            })
        while !onComplete {
            assertNil(f2.value)
        }
        do {} while !f2.value
        XCTAssertEqualObjects(f2.value!.unwrap(), "f2 is finished")
        
        let p1 = Promise<Int>()
        let f3 = Future<Int>(linkedPromise: p1)
        assertNil(f3.value)
        p1.trySuccess(25)
        do {} while !f3.value
        XCTAssertEqual(f3.value!.unwrap(), 25)
        
        let p2 = Promise<String>()
        let f4 = Future<String>(copiedPromise: p2)
        assertNil(f4.value)
        p2.trySuccess("Copy this.")
        do {} while !f4.value
        XCTAssertEqualObjects(f4.value!.unwrap(), "Copy this.")
    }
    
    func testFold() -> () {
        var onComplete: Bool = false
        let f1 = Future<String>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return "f1 is finished"
            })
        let f1f: Future<Int> = f1.fold({
            var result: Try<Int>! = nil
            switch $0 {
            case .Success(["f1 is finished"]):
                result = Try.Success([10])
            default:
                result = Try.Failure(NSException(name: "IncorrectFuture", reason: "f1 not correctly fulfilled", userInfo: nil))
            }
            onComplete = true
            return result
            })
        do {} while !f1f.value
        XCTAssertEqual(f1f.value!.unwrap(), 10)
    }
    
    func testMap() -> () {
        let p1 = Promise<Int>()
        let f1 = Future<Int>(linkedPromise: p1)
        let f1m = f1.map { "\($0)" }
        p1.trySuccess(100)
        do {} while !f1m.value
        XCTAssertEqualObjects(f1m.value!.unwrap(), "100")

        var onComplete: Bool = false
        let p2 = Promise<Bool>()
        let f2 = Future<Bool>(copiedPromise: p2)
        let f2m: Future<String> = f2.map {
            onComplete = true
            DLog(.Future, "Here")
            if $0 {
                return "Hello"
            } else {
                return "Goodbye"
            }
        }
        p2.tryFail(NSException(name: "FutureTestException", reason: nil, userInfo: nil))
        do {} while !f2m.value
        XCTAssertFalse(onComplete)
        assertNil(f2m.value!.toOption())
        // TODO EXCEPTIONS
    }

    func testBind() -> () {
        let f1 = Future<Int>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return 100
            })
        let f2: Future<Int> = f1.bind {
            (i: Int) -> Future<Int> in
            return Future<Int>(task: {
                var j: Int = 0;
                do {} while j++ < STALL
                return -i
            })
        }
        do {} while !f2.value
        XCTAssertEqual(f2.value!.unwrap(), -100)
        
        let p1 = Promise<Int>(value: .Failure(NSException(name: "FutureTestException", reason: nil, userInfo: nil)))
        let f3 = Future<Int>(linkedPromise: p1)
        let f4: Future<Int> = f3.bind {
            (i: Int) -> Future<Int> in
            return Future<Int>(task: {
                var j: Int = 0;
                do {} while j++ < STALL
                return -i
                })
        }
        // TODO EXCEPTIONS
    }
    
    func testFilter() -> () {
        let f1 = Future<Int>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return 100
            })
        
        let f2 = f1.filter { $0 > 50 }
        do {} while !f2.value
        XCTAssertEqual(f2.value!.unwrap(), 100)
        
        let f3 = f1.filter { $0 != 100 }
        do {} while !f2.value
        // TODO EXCEPTIONS
    }
    
    func testOnSuccess() -> () {
        var onSuccess: Bool = false
        let p1 = Promise<Int>(value: .Success([100]))
        let f1 = Future<Int>(linkedPromise: p1)
        f1.onSuccess( { _ in true } =|= { _ in onSuccess = true; return Try.Success([""]) } as PartialFunction<Int,Try<String>>)
        do {} while !onSuccess
        
        let p2 = Promise<Int>(value: .Failure(NSException(name: "FutureTestException", reason: nil, userInfo: nil)))
        let f2 = Future<Int>(linkedPromise: p2)
        f2.onSuccess( { _ in true } =|= { _ in NSException(name: "FutureTestException", reason: nil, userInfo: nil).raise(); return Try.Success([""]) }  as PartialFunction<Int,Try<String>>)
    }
    
    func testOnFailure() -> () {
        let p1 = Promise<Int>(value: .Success([100]))
        let f1 = Future<Int>(linkedPromise: p1)
        f1.onFailure( { _ in true } =|= { _ in NSException(name: "FutureTestException", reason: nil, userInfo: nil).raise(); return Try.Success([""]) } as PartialFunction<NSException,Try<String>>)
        
        var onFailure: Bool = false
        let p2 = Promise<Int>(value: .Failure(NSException(name: "FutureTestException", reason: nil, userInfo: nil)))
        let f2 = Future<Int>(linkedPromise: p2)
        f2.onFailure( { _ in true } =|= { _ in onFailure = true; return Try.Success([""]) } as PartialFunction<NSException,Try<String>>)
        do {} while !onFailure
    }
    
    func testOnComplete() -> () {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        let pf: PartialFunction<Try<Int>,Try<Int>> =
            { $0.isSuccess() } =|= { _ in onSuccess = !onSuccess; return Try.Success([5]) } |
            { $0.isFailure() } =|= { _ in onFailure = !onFailure; return Try.Success([5]) }
        
        let p1 = Promise<Int>(value: .Success([100]))
        let f1 = Future<Int>(linkedPromise: p1)
        f1.onComplete(pf)
        do {} while !onSuccess
        do {} while onFailure
        
        let p2 = Promise<Int>(value: .Failure(NSException(name: "FutureTestException", reason: nil, userInfo: nil)))
        let f2 = Future<Int>(linkedPromise: p2)
        f2.onComplete(pf)
        do {} while !onSuccess
        do {} while !onFailure
    }
    
    func testRecover() -> () {
        let pf: PartialFunction<NSException,Int> = { _ in true } =|= { _ in return 200 }
        
        let p1 = Promise<Int>(value: .Success([100]))
        let f1 = Future<Int>(linkedPromise: p1)
        let f1r = f1.recover(pf)
        do {} while !f1r.value
        XCTAssertEqual(f1r.value!.unwrap(), 100)
        
        let p2 = Promise<Int>(value: .Failure(NSException(name: "FutureTestException", reason: nil, userInfo: nil)))
        let f2 = Future<Int>(linkedPromise: p2)
        let f2r = f2.recover(pf)
        do {} while !f2r.value
        XCTAssertEqual(f2r.value!.unwrap(), 200)
    }
    
    func testAndThen() -> () {
        let pf: PartialFunction<Try<Int>,String> =
            { $0.toOption() ? $0.unwrap() > 25 : false } =|= { _ in "G" } |
            { $0.toOption() ? $0.unwrap() < 25 : false } =|= { _ in "L" } |
            { _ in true } =|= { _ in "Default" }
        
        let p1 = Promise<Int>(value: .Success([100]))
        let f1 = Future<Int>(linkedPromise: p1)
        let f1at = f1.andThen(pf)
        do {} while !f1at.value
        XCTAssertEqualObjects(f1at.value!.unwrap(), "G")
        
        let p2 = Promise<Int>(value: .Success([20]))
        let f2 = Future<Int>(linkedPromise: p2)
        let f2at = f2.andThen(pf)
        do {} while !f2at.value
        XCTAssertEqualObjects(f2at.value!.unwrap(), "L")
        
        let p3 = Promise<Int>(value: .Failure(NSException()))
        let f3 = Future<Int>(linkedPromise: p3)
        let f3at = f3.andThen(pf)
        do {} while !f3at.value
        XCTAssertEqualObjects(f3at.value!.unwrap(), "Default")
    }

    func testAnd() -> () {
        let f1 = Future<Int>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return 100
            })
        let f2 = Future<String>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return "Hello"
            })
        let f3 = f1.and(f2)
        do {} while !f3.value
        let v1 = f3.value!.unwrap()
        XCTAssertEqualObjects(v1.0, 100)
        XCTAssertEqualObjects(v1.1, "Hello")
    }
    
    func testCompletedResult() -> () {
        let f1 = Future<Int>(value: 10)
        XCTAssertEqual(f1.completedResult, 10)
    }
    
    func testIsComplete() -> () {
        let f1 = Future<Int>(value: 10)
        XCTAssertTrue(f1.isComplete())
        XCTAssertEqual(f1.value!.unwrap(), 10)
        
        let f2 = Future<String>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return "Hello"
            })
        do {} while !f2.isComplete()
        XCTAssertEqualObjects(f2.value!.unwrap(), "Hello")
    }
    
    func testAwait() -> () {
        let f1 = Future<String>(task: {
            var j: Int = 0;
            do {} while j++ < STALL
            return "Hello"
            })
        f1.await()
        XCTAssertEqualObjects(f1.value!.unwrap(), "Hello")
    }
    
}
