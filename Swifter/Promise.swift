//
//  Promise.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A PromiseState encapsulates all possible states of the Promise: .Pending,
 * or .Fulfilled with either a .Success(T) or a .Failure(E). */
enum PromiseState<T> {
    case Fulfilled(Try<T>)
    case Pending
    
    var value: Try<T>? {
    get {
        switch self {
        case .Fulfilled(let t):
            return t
        case .Pending:
            return nil
        }
    }
    }
    
}

/* A PromiseAlreadyFulfilledException indicates that a Promise was attempted to be
 * fulfilled with a value after already beeing fulfilled. */
class PromiseAlreadyFulfilledException : NSException {
    
    init() {
        super.init(name: "PromisedAlreadyFulfilledException", reason: nil, userInfo: nil)
    }
    
}

/* A Promise is an object that contains only a state of an asynchronous computation:
 * it is either .Pending or .Fulfilled with a value. Promises themselves do not
 * enact computation, but act as state endpoints in a computation. */
class Promise<T> {
    
    typealias PAFE = PromiseAlreadyFulfilledException
    
    // TODO: make private
    var state: PromiseState<T>
    
    var future: Future<T> {
    get {
        return Future<T>(linkedPromise: self)
    }
    }

    var value: Try<T>? {
    get {
       return self.state.value
    }
    }
    
    init() {
        Log(.PromiseMade)
        self.state = .Pending
    }
    
    convenience init(value: Try<T>) {
        self.init()
        self.tryFulfill(value)
    }
    
    /* Applies fulfilled to a .Fufilled(Try<T>) and pending to a .Pending. */
    func stateFold<S>(fulfilled: ((Try<T>) -> S), pending: (() -> S)) -> S {
        switch self.state {
        case .Fulfilled(let f):
            return fulfilled(f)
        case .Pending:
            return pending()
        }
    }
    
    // TODO: make private
    /* Attempts to change the state of the Promise to a .Fulfilled(Try<T>), and
     * returns whether or not the state change occured. */
    func tryFulfill(value: Try<T>) -> Bool {
        return self.stateFold({
                _ in
                Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
                return false
            }, {
                Log(.PromiseFulfilled, "Fulfilled with \(value)")
                self.state = .Fulfilled(value)
                let userInfo = ["callbackValue" : value]
                NSNotificationCenter.defaultCenter().postNotification(name: canExecuteNotification, object: self, userInfo: userInfo)
                return true
            })
    }
    
    /* Changes the state of the Promise from a .Pending to a .Fulfilled(Try<T>), or
     * raises a PromiseAlreadyFulfilledException. */
    func fulfill(value: Try<T>) -> () {
        if !self.tryFulfill(value) {
            PAFE().raise()
        }
    }
    
    /* Returns whether the Promise has reached a .Fulfilled(T) state. */
    func isFulfilled() -> Bool {
        return self.stateFold({ _ in true }, { false })
    }

    /* Attempts to change the state of the Promise to a .Fulfilled(.Success(T)),
     * and returns whether or not the state change occurred. */
    func trySuccess(s: T) -> Bool {
        return self.tryFulfill(.Success([s]))
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(.Success(T)),
     * and if not possible, raises a PromiseAlreadyFulfilledException. */
    func success(s: T) -> () {
        if !self.trySuccess(s) {
            PAFE().raise()
        }
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(.Failure(E)),
     * and returns whether or not the state change occurred. */
    func tryFail(e: NSException) -> Bool {
        return self.tryFulfill(.Failure(e))
    }
   
    /* Attempts to change the state of the Promise to a .Fulfilled(.Failure(E)),
     * and if not possible, raises a PromiseAlreadyFulfilledException. */
    func fail(e: NSException) -> () {
        if !self.tryFail(e) {
            PAFE().raise()
        }
    }
    
    /* Fulfills the Promise simultaneously with this Promise. */
    func alsoFulfill(promise: Promise<T>) -> () {
        let exec = Executable<T>(task: { promise.tryFulfill($0) }, thread: Scheduler.assignThread(), observed: self)
        self.executeOrMap(exec)
    }
    
    /* Executes the Executable with the value of the .Fulfilled promise, or
     * otherwise schedules the Executable to be executed after the Promise reaches
     * the .Fulfilled state. */
    func executeOrMap(exec: Executable<T>) -> () {
        self.stateFold({
            exec.executeWithValue($0)
            }, {
                // TODOCreate callback.
        })
    }
    
    /* Schedules the Task to be executed for when the Promise is .Fulfilled. */
    func onComplete(task: ((Try<T>) -> Any)) -> () {
        self.executeOrMap(Executable<T>(task: task, thread: Scheduler.assignThread(), observed: self)) // THREAD
    }
    
}

extension Promise : Awaitable {
        
    /* The type of the action that is awaited. */
    typealias AwaitedResult = Promise<T>
    
    /* The type of the completed result of the action. */
    typealias CompletedResult = Try<T>
    
    /* The result of the awaited action at completion. */
    var completedResult: CompletedResult {
    get {
        do {} while !self.isFulfilled()
        return self.state.value!
    }
    }
    
    /* Returns if the awaited action has completed. */
    func isComplete() -> Bool {
        return self.isFulfilled()
    }
    
    /* Awaits indefinitely until the action has completed. */
    func await() -> AwaitedResult {
        return self.await(NSTimeInterval.infinity)
    }

    // TODO: make private or refactor timeout().
    /* Attempts to fail this Promise with a PromiseAlreadyFulfilledException. */
    func tryFailWithPAFE(timer: NSTimer!) -> () {
        self.tryFail(PAFE())
    }
    
    /* Fails the Promise with a TimeoutException after the specified NSTimeInterval. */
    func timeout(time: NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(time, target: self, selector: "tryFailWithPAFE:", userInfo: nil, repeats: false)
    }

    /* Returns an attempt at awaiting the action for an NSTimeInterval duration. */
    func await(time: NSTimeInterval) -> AwaitedResult {
        let promise = Promise<T>()
        
        self.alsoFulfill(promise)
        promise.timeout(time)
        
        return promise
    }
    
}
