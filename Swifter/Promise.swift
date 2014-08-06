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
private enum PromiseState<T> {
    case Fulfilled(Try<T>)
    case Pending
    
    var value: Try<T>? {
    get {
        switch self {
        case .Fulfilled(let f):
            return f
        case .Pending:
            return nil
        }
    }
    }
    
}

/* A PromiseAlreadyFulfilledException indicates that a Promise was attempted to be
 * fulfilled with a value after already beeing fulfilled. */
public class PromiseAlreadyFulfilledException : NSException {
    
    init() {
        super.init(name: "PromisedAlreadyFulfilledException", reason: nil, userInfo: nil)
    }
    
}

/* A Promise is an object that contains only a state of an asynchronous computation:
 * it is either .Pending or .Fulfilled with a value. Promises themselves do not
 * enact computation, but act as state endpoints in a computation. */
public class Promise<T> {
    
    typealias PAFE = PromiseAlreadyFulfilledException
    
    // TODO: make private
    private var state: PromiseState<T>
    private let lock: NSLock
    private let callbacks = LinkedList<Executable<T>>()
    
    public var future: Future<T> {
    get {
        return Future<T>(linkedPromise: self)
    }
    }

    public var value: Try<T>? {
    get {
       return self.state.value
    }
    }
    
    init() {
        Log(.PromiseMade)
        self.state = .Pending
        self.lock = NSLock()
    }
    
    convenience init(value: Try<T>) {
        self.init()
        self.tryFulfill(value)
    }
    
    deinit {
        DLog(.Promise, "Deinitializing Promise")
    }
    
    /* Applies fulfilled to a .Fufilled(Try<T>) and pending to a .Pending. */
    public func fold<S>(fulfilled: ((Try<T>) -> S), pending: (() -> S)) -> S {
        return self.lock.perform {
            [unowned self] () -> S in
            switch self.state {
            case .Fulfilled(let f):
                return fulfilled(f)
            case .Pending:
                return pending()
            }
        }
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(Try<T>), and
     * returns whether or not the state change occured. */
    public func tryFulfill(value: Try<T>) -> Bool {
        return self.fold({
                _ in
                Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
                return false
            }, {
                Log(.PromiseFulfilled, "Fulfilled with \(value)")
                self.state = .Fulfilled(value)
                self.callback()
                return true
            })
    }
    
    /* Changes the state of the Promise from a .Pending to a .Fulfilled(Try<T>), or
     * raises a PromiseAlreadyFulfilledException. */
    public func fulfill(value: Try<T>) -> () {
        if !self.tryFulfill(value) {
            PAFE().raise()
        }
    }
    
    /* Returns whether the Promise has reached a .Fulfilled(T) state. */
    public func isFulfilled() -> Bool {
        return self.fold({ _ in true }, { false })
    }

    /* Attempts to change the state of the Promise to a .Fulfilled(.Success(T)),
     * and returns whether or not the state change occurred. */
    public func trySuccess(s: T) -> Bool {
        return self.tryFulfill(.Success([s]))
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(.Success(T)),
     * and if not possible, raises a PromiseAlreadyFulfilledException. */
    public func success(s: T) -> () {
        if !self.trySuccess(s) {
            PAFE().raise()
        }
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(.Failure(E)),
     * and returns whether or not the state change occurred. */
    public func tryFail(e: NSException) -> Bool {
        return self.tryFulfill(.Failure(e))
    }
   
    /* Attempts to change the state of the Promise to a .Fulfilled(.Failure(E)),
     * and if not possible, raises a PromiseAlreadyFulfilledException. */
    public func fail(e: NSException) -> () {
        if !self.tryFail(e) {
            PAFE().raise()
        }
    }
    
    /* Fulfills the Promise simultaneously with this Promise. */
    public func alsoFulfill(promise: Promise<T>) -> () {
        let exec = Executable<T>(task: { _ = promise.tryFulfill($0) }, thread: Scheduler.assignThread())
        self.executeOrMap(exec)
    }
    
    private func callback() -> () {
        for callback in self.callbacks {
            callback.executeWithValue(self.value!)
        }
    }
    
    /* Executes the Executable with the value of the .Fulfilled promise, or
     * otherwise schedules the Executable to be executed after the Promise reaches
     * the .Fulfilled state. */
    internal func executeOrMap(exec: Executable<T>) -> () {
        self.fold({ exec.executeWithValue($0) }, { self.callbacks.push(exec) })
    }
    
    /* Schedules the Task to be executed for when the Promise is .Fulfilled. */
    public func onComplete(task: ((Try<T>) -> ())) -> () {
        self.executeOrMap(Executable<T>(task: task, thread: Scheduler.assignThread()))
    }
    
}

extension Promise : Awaitable {
    
    /* The type of the action that is awaited. */
    typealias AwaitedResult = Promise<T>
    
    /* The type of the completed result of the action. */
    typealias CompletedResult = Try<T>
    
    /* The result of the awaited action at completion. */
    public var completedResult: CompletedResult {
    get {
        do {} while !self.isFulfilled()
        return self.state.value!
    }
    }
    
    /* Returns if the awaited action has completed. */
    public func isComplete() -> Bool {
        return self.isFulfilled()
    }
    
    /* Awaits indefinitely until the action has completed. */
    public func await() -> AwaitedResult {
        do {} while !self.isComplete()
        return self
    }
    
    /* Fails the Promise with a TimeoutException after the specified NSTimeInterval. */
    func timeout(time: NSTimeInterval) {
        NSTimer.scheduledTimerWithTimeInterval(time, userInfo: nil, repeats: false) {
            _ in
            Log(.Timer, "Timing out")
            _ = self.tryFulfill(.Failure(PAFE()))
        }
    }

    /* Returns the blocked attempt at awaiting the action for an NSTimeInterval duration. */
    public func await(time: NSTimeInterval) -> AwaitedResult {
        self.timeout(time)
        return self.await()
    }
    
}
