//
//  Awaitable.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/1/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A TimeoutException indicates the Awaitable timed out. */
class TimeoutException : NSException {
    
    init(time: NSTimeInterval) {
        super.init(name: "TimeoutException", reason: "Computation exceeded \(time)", userInfo: nil)
    }
    
}

/* An asynchronous action that can be awaited. */
protocol Awaitable {
    
    /* An exception indicating the computation timed out. */
    typealias TE = TimeoutException
    
    /* The type of the action that is awaited. */
    typealias AwaitedResult
    
    /* The type of the completed result of the action. */
    typealias CompletedResult
    
    /* The result of the awaited action at completion. */
    var completedResult: CompletedResult { get }
    
    /* Returns if the awaited action has completed. */
    func isComplete() -> Bool
    
    /* Awaits indefinitely until the action has completed. */
    func await() -> AwaitedResult
    
    /* Returns an attempt at awaiting the action for an NSTimeInterval duration. */
    func await(time: NSTimeInterval) -> AwaitedResult

}
