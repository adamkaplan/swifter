//
//  TryTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/24/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class TryTests: XCTestCase {
    
    func testFold() -> () {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Int> = .Success(10)
        let failureTry: Try<Int> = .Failure(NSException())
        
        successTry.fold( { _ in onSuccess = true }, { _ in onFailure = false })
        XCTAssertTrue(onSuccess)
        XCTAssertFalse(onFailure)
        failureTry.fold( { _ in onSuccess = false }, { _ in onFailure = true })
        XCTAssertTrue(onSuccess)
        XCTAssertTrue(onFailure)
    }
    
    func testIsSuccess() -> () {
        let s: Try<Int> = .Success(10)
        let f: Try<Int> = .Failure(NSException())

        XCTAssertTrue(s.isSuccess())
        XCTAssertFalse(f.isSuccess())
    }
    
    func testIsFailure() -> () {
        let s: Try<String> = .Success("Cat")
        let f: Try<String> = .Failure(NSException())
        
        XCTAssertFalse(s.isSuccess())
        XCTAssertTrue(f.isSuccess())
    }
    
    func testToOption() -> () {
        let s: Try<String> = .Success("Kitten")
        let f: Try<String> = .Failure(NSException())
        
        XCTAssertEqual(s.toOption()!, "Kitten")
        assertNil(f.toOption())
    }
    
    func testUnwrap() -> () {
        let s: Try<String> = .Success("Kitten")
        
        XCTAssertEqualObjects(s.unwrap(), "Kitten")
    }
    
    func testFilter() -> () {
        let s: Try<Int> = .Success(10)
        
        XCTAssertEqual(s.filter( { $0 % 2 == 0 } ).toOption()!, 10)
        assertNil(s.filter( { $0 < 0 } ).toOption())
    }
    
    func testGetOrElse() -> () {
        let s: Try<Int[]> = .Success([1])
        let f: Try<Int[]> = .Failure(NSException())
        
        XCTAssertEqualObjects(s.getOrElse([]), [1])
        XCTAssertEqualObjects(f.getOrElse([]), [])
    }
    
    func testOrElse() -> () {
        let s: Try<Bool?> = .Success(true)
        let f: Try<Bool?> = .Failure(NSException())
        
        XCTAssertTrue(s.orElse(.Success(false)).getOrElse(nil))
        XCTAssertFalse(f.orElse(.Success(false)).getOrElse(true))
        assertNil(f.orElse(.Failure(NSException())).getOrElse(nil))
    }
    
    func testMap() -> () {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Int> = .Success(10)
        let failureTry: Try<Int> = .Failure(NSException())
        
        XCTAssertEqual(successTry.map( {
            (i: Int) -> Int in
            onSuccess = true
            return 2 * i } ).toOption()!, 10)
        XCTAssertTrue(onSuccess)
        assertNil(failureTry.map( {
            (i: Int) -> Int in
            onFailure = true
            return 2 * i } ).toOption())
        XCTAssertFalse(onFailure)
    }
    
    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
    * raises a TryDidFailException. */

    
    func testOnSuccess() {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Bool> = .Success(false)
        let failureTry: Try<Bool> = .Failure(NSException())
        
        XCTAssertTrue(successTry.onSuccess( {
            (b: Bool) -> Bool in
            onSuccess = true
            return !b }).toOption()!)
        XCTAssertTrue(onSuccess)
        
        failureTry.onSuccess { _ in onFailure = true }
        XCTAssertFalse(onFailure)
    }
    
    func testOnFailure() {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Bool> = .Success(false)
        let failureTry: Try<Bool> = .Failure(NSException())

        successTry.onFailure { _ in onSuccess = true }
        XCTAssertFalse(onSuccess)
        
        XCTAssertTrue(failureTry.onFailure({ _ in onFailure = true; return true }).toOption()! as Bool)
        XCTAssertTrue(onFailure)
    }
    
    func testBind() -> () {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Int> = .Success(10)
        let failureTry: Try<Int> = .Failure(NSException())
        
        XCTAssertEqual(successTry.bind( { (i: Int) -> Try<Int> in
            onSuccess = true
            return Try.Success(2 * i) } ).toOption()!, 10)
        XCTAssertTrue(onSuccess)
        assertNil(failureTry.bind( { (i: Int) -> Try<Int>
            in onFailure = true
            return Try.Success(2 * i) } ).toOption())
        XCTAssertFalse(onFailure)
    }
    
    func testRecover() -> () {
        var onSuccess: Bool = false
        var onFailure: Bool = false
        
        let successTry: Try<Int> = .Success(10)
        let failureTry: Try<Int> = .Failure(NSException())
        
        let pf: PartialFunction<NSException, Int> = { _ in true } =|= { (_: NSException) -> Int in
            onFailure = true
            return 25 }
        
        XCTAssertEqual(successTry.recover(pf).toOption()!, 10)
        XCTAssertEqual(failureTry.recover(pf).toOption()!, 25)
        XCTAssertTrue(onFailure)
    }

}
