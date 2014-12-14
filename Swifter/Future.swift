//
//  Future.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/** A Future is an entity that will be some value in the future. Futures encapsulate
    the scheduling and memory management of the calculation of these values and allow
    operations to be performed, at some point in the future, based on this future value. */
public class Future<T> {
    
    internal let promise: Promise<T>
    
    /** Optionally returns the current value of the Future, dependent on its completion status. */
    public var value: T? {
    get {
        return self.promise.value
    }
    }
    
    /** Creates a Future already completed with `value`. */
    init(_ value: T) {
        self.promise = Promise<T>(value)
    }
    
    /** Creates a Future whose value will be determined from the completion of `task`. */
    init(_ task: () -> T) {
        self.promise = Promise<T>()
        Executable(queue: Scheduler.assignQueue()) {
            _ = self.promise.tryFulfill(task())
        }.executeWithValue()
    }
    
    /** Creates a Future whose status is directly linked to the state of the Promise. */
    init(linkedPromise: Promise<T>) {
        self.promise = linkedPromise
    }
    
    /** Creates a copied Promise, bound to the original, that will be used as the
        state of this Future. */
    init(copiedPromise: Promise<T>) {
        self.promise = Promise<T>()
        copiedPromise.alsoFulfill(self.promise)
    }
    
    deinit {
        DLog(.Future, "Deinitializing Future")
    }
    
    /** Creates a new Future from the application of `f` to the resulting PromiseState. */
    public func map<S>(f: T -> S) -> Future<S> {
        Log(.Future, "Future is mapped to a new Future")
        
        let promise = Promise<S>()
        
        self.promise.executeOrMap(Executable<T>(queue: Scheduler.assignQueue()) {
            _ = promise.tryFulfill(f($0))
            })
        
        return Future<S>(linkedPromise: promise)
    }
    
    /** Creates a new Future from the application of `f` to the result of this Future. */
    public func bind<S>(f: T -> Future<S>) -> Future<S> {
        Log(.Future, "Future is bound to a new Future")
        
        let promise = Promise<S>()

        self.promise.executeOrMap(Executable<T>(queue: Scheduler.assignQueue()) {
            f($0).promise.alsoFulfill(promise)
            })
        
        return Future<S>(linkedPromise: promise)
    }
 
    /** Applies the PartialFunction to the completed result of this Future. */
    public func onComplete<S>(pf: PartialFunction<T,S>) -> () {
        self.map(pf.tryApply)
    }
    
    /** Applies the PartialFunction to the result of this Future, and returns a new
        Future with the result of this Future. */
    public func andThen<S>(pf: PartialFunction<T,S>) -> Future<Try<S>> {
        return self.map { pf.tryApply($0) }
    }
    
    /** Returns a single Future whose value, when completed, will be a tuple of the
        completed values of the two Futures. */
    public func and<S>(other: Future<S>) -> Future<(T,S)> {
        return self.bind {
            (first: T) -> Future<(T,S)> in
            other.bind {
                (second: S) -> Future<(T,S)> in
                return Future<(T,S)>((first, second))
            }
        }
    }
    
}

extension Future : Awaitable {
    
    typealias AwaitedResult = Future<T>
    typealias CompletedResult = T
    
    public var completedResult: T {
    get {
        self.await()
        return self.value!
    }
    }
    
    public func isComplete() -> Bool {
        return self.promise.isFulfilled()
    }
    
    public func await() -> Future<T> {
        return self.await(NSTimeInterval.infinity, nil)
    }
    
    public func await(time: NSTimeInterval, timeout: (Future<T> -> Future<T>)!) -> Future<T> {
        let future = Future(copiedPromise: self.promise)
        future.promise.await(time, timeout: nil)
        return future
    }
    
}

/** The mapping operator. */
infix operator  >>| {associativity left}
 func >>| <T,S> (future: Future<T>, f: T -> S) -> Future<S> {
    return future.map(f)
}

/** The binding operator. */
infix operator  >>= {associativity left}
 func >>= <T,S> (future: Future<T>, f: T -> Future<S>) -> Future<S> {
    return future.bind(f)
}
