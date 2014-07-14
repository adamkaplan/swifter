//
//  Promise.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

let notificationCenter = NSNotificationCenter.defaultCenter()
let promiseFulfilledNotification = "PromiseFulfilledNotification"

/* A PromiseState encapsulates all possible states of the Promise: .Pending,
 * or .Fulfilled with either a .Success(T) or a .Failure(E). */
enum PromiseState<T> {
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
    let lock: NSLock
    let callbacks: LockedList<Executable<T>>
    
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
        self.lock = NSLock()
        self.callbacks = LockedList<Executable<T>>()
    }
    
    convenience init(value: Try<T>) {
        self.init()
        self.tryFulfill(value)
    }
    
    deinit {
        DLog(.Promise, "Deinitializing Promise")
    }
    
    /* Applies fulfilled to a .Fufilled(Try<T>) and pending to a .Pending. */
    func fold<S>(fulfilled: ((Try<T>) -> S), pending: (() -> S)) -> S {
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
    
    // TODO: make private
    /* Attempts to change the state of the Promise to a .Fulfilled(Try<T>), and
     * returns whether or not the state change occured. */
    func tryFulfill(value: Try<T>) -> Bool {
        return self.fold({
                _ in
                Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
                return false
            }, {
                Log(.PromiseFulfilled, "Fulfilled with \(value)")
                self.state = .Fulfilled(value)
//                notificationCenter.postNotification(CallbackNotification(callbackValue: value.toObject(), caller: self))
//                notificationCenter.postNotificationName(promiseFulfilledNotification, object: self, userInfo: ["callbackValue" : value.toObject()])
                self.callback()
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
        return self.fold({ _ in true }, { false })
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
        let exec = Executable<T>(task: { _ = promise.tryFulfill($0) }, thread: Scheduler.assignThread())
        self.executeOrMap(exec)
    }
    
    func addCallback(exec: Executable<T>) -> () {
        self.fold({ exec.executeWithValue($0) }, { self.callbacks.push(exec) })
    }
    
    func callback() -> () {
        while !self.callbacks.isEmpty() {
            self.callbacks.pop()!.executeWithValue(self.value!)
        }
    }
    
    /* Executes the Executable with the value of the .Fulfilled promise, or
     * otherwise schedules the Executable to be executed after the Promise reaches
     * the .Fulfilled state. */
    func executeOrMap(exec: Executable<T>) -> () {
//        let onceExec = OnceExecutable(parent: exec)
        self.addCallback(exec)
        
        
//        self.fold({
//            exec.executeWithValue($0)
//            }, {
//                // TODO Prevent from being deinitialized.
//                // What if the Promise is fulfilled right here?
//                let observer = notificationCenter.addObserverForName(promiseFulfilledNotification, object: self, queue: exec.thread, usingBlock:
//                    {
//                        Log(.Executable, "in usingBlock")
//                        if let value = ($0.userInfo[callbackValueKey] as? TryObject<T>)?.toEnum() {
//                            exec.executeWithValue(value)
//                        }
//                    })
//                exec.thread.addOperationWithBlock {
//                    do {} while !exec.value
//                    notificationCenter.removeObserver(observer)
//                }
//            })
    }
    
    /* Schedules the Task to be executed for when the Promise is .Fulfilled. */
    func onComplete(task: ((Try<T>) -> ())) -> () {
        self.executeOrMap(Executable<T>(task: task, thread: Scheduler.assignThread()))
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
    func await(time: NSTimeInterval) -> AwaitedResult {
        self.timeout(time)
        return self.await()
    }
    
}
