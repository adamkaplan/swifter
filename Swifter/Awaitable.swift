//
//  Awaitable.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/1/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/** A TimeoutException indicates the Awaitable did not finish in the given time. */
public class TimeoutException : TryFailure { //: NSException {

    let time: NSTimeInterval
    
    init(time: NSTimeInterval) {
        self.time = time
    }

    public func fail() -> () {
        NSException(name: "TimeoutException", reason: "Computation exceeded \(time)", userInfo: nil).raise()
    }
    
}

/** An asynchronous action that can be awaited. */
public protocol Awaitable {
    
    /** The type of the action that is awaited (most often, Self). This type is 
        returned by await() to allow method chaining. */
    typealias AwaitedResult

    /** The type of the completed result of the action. */
    typealias CompletedResult
    
    /** The result of the awaited action at completion. (This method blocks.) */
    var completedResult: CompletedResult { get }
    
    /** Returns if the awaited action has completed. */
    func isComplete() -> Bool
    
    /** Blocks indefinitely until the action has completed. */
    func await() -> AwaitedResult
    
    /** Returns an attempt at awaiting the action for an input duration. */
    func await(time: NSTimeInterval, timeout: (Self -> AwaitedResult)!) -> AwaitedResult

}
