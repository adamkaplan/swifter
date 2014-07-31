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
    case Fulfilled([T]) // TODO: REMOVE WORKAROUND [T] -> T
    case Pending
    
    var value: T? {
    get {
        switch self {
        case .Fulfilled(let f):
            return f[0]
        case .Pending:
            return nil
        }
    }
    }
    
}

/* A Promise is an object that contains only a state of an asynchronous computation:
 * it is either .Pending or .Fulfilled with a value. Promises themselves do not
 * enact computation, but act as state endpoints in a computation. */
public class Promise<T> {
    
    private var state: PromiseState<T>
    private let lock: NSLock
    private var callbacks = List<Executable<T>>()
    
    public var future: Future<T> {
    get {
        return Future<T>(linkedPromise: self)
    }
    }

    public var value: T? {
    get {
       return self.state.value
    }
    }
    
    init() {
        Log(.Promise, "Promise made")
        self.state = .Pending
        self.lock = NSLock()
    }
    
    convenience init(_ value: T) {
        self.init()
        self.tryFulfill(value)
    }
    
    deinit {
        DLog(.Promise, "Deinitializing Promise")
    }
    
    /* Applies fulfilled to a .Fufilled(Try<T>) and pending to a .Pending. */
    public func fold<S>(fulfilled: T -> S, pending: () -> S) -> S {
        return self.lock.perform {
//            [unowned self] () -> S in // TODO Is this necessary? It doesn't matter if it's owned?
            switch self.state {
            case .Fulfilled(let f):
                return fulfilled(f[0])
            case .Pending:
                return pending()
            }
        }
    }
    
    /* Attempts to change the state of the Promise to a .Fulfilled(Try<T>), and
     * returns whether or not the state change occured. */
    public func tryFulfill(value: T) -> Bool {
        return self.fold({
                _ in
                Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
                return false
            }, {
                Log(.Promise, "Promise fulfilled with \(value)")
                self.state = .Fulfilled([value])
                self.callback()
                return true
            })
    }
    
    /* Returns whether the Promise has reached a .Fulfilled(T) state. */
    public func isFulfilled() -> Bool {
        return self.fold({ _ in true }, { false })
    }
    
    /* Fulfills the Promise simultaneously with this Promise. */
    public func alsoFulfill(promise: Promise<T>) -> () {
        self.executeOrMap(Executable<T>(queue: Scheduler.assignQueue()) { _ = promise.tryFulfill($0) })
    }
    
    private func callback() -> () {
        self.callbacks.iter { $0.executeWithValue(self.value!) }
    }
    
    /* Executes the Executable with the value of the .Fulfilled promise, or
     * otherwise schedules the Executable to be executed after the Promise reaches
     * the .Fulfilled state. */
    internal func executeOrMap(exec: Executable<T>) -> () {
        self.fold({ exec.executeWithValue($0) }, { self.callbacks = exec^^self.callbacks })
    }
    
    /* Schedules the Task to be executed for when the Promise is .Fulfilled. */
    public func onComplete(task: T -> ()) -> () {
        self.executeOrMap(Executable(queue: Scheduler.assignQueue(), task: task))
    }
    
}

extension Promise : Awaitable {
    
    typealias AwaitedResult = Promise<T>
    typealias CompletedResult = T
    
    public var completedResult: CompletedResult {
    get {
        do {} while !self.isFulfilled()
        return self.state.value!
    }
    }
    
    public func isComplete() -> Bool {
        return self.isFulfilled()
    }
    
    public func await() -> Promise<T> {
        return self.await(NSTimeInterval.infinity, timeout: nil)
    }

    public func await(time: NSTimeInterval, timeout: (Promise<T> -> Promise<T>)!) -> Promise<T> {
//        let timer = NSTimer.scheduledTimerWithTimeInterval(time, userInfo: nil, repeats: false) { // TODO REMOVE WORKAROUND
//            _ in
//            Log(.Timer, "Timing out")
//            if !self.isComplete() {
//                timeout(self)
//            }
//        }
//        do {} while !self.isComplete() && !timer.hasFired()
//        if self.isComplete() {
//            return self
//        } else {
//            return timeout(self)
//        }
        return self
    }
    
}
