//
//  Future.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

// TODO: Abstract away all scheduling; encapsulate into Runnable/Callback
// tasks. Futures only wrap and manipulate Callbacks and Promises to yield
// asynchronous computation.

let scheduler: Scheduler = Scheduler()

class Future<T>: NSObject {
    
    typealias P = Promise<Try<T>>
    typealias PS = PromiseState<Try<T>>
    
    let promise: P
    let queue: dispatch_queue_t
    var test: Bool = false
    
    init(value: T) {
        self.promise = Promise<Try<T>>()
        self.queue = scheduler.assignThread()
        
        super.init()

        let block: (() -> ()) = {
            _ = self.promise.fulfill(Try.Success(value))
        }
        
        dispatch_async(self.queue, block)
    }
    
    init(value: T, queue: dispatch_queue_t) {
        self.promise = Promise<Try<T>>()
        self.queue = queue
        
        super.init()
        
        let block: (() -> ()) = {
            _ = self.promise.fulfill(Try.Success(value));
        }
        
        dispatch_async(self.queue, block)
    }
    
    init(f: (() -> Try<T>)) {
        self.promise = Promise<Try<T>>()
        self.queue = scheduler.assignThread()
        
        super.init()
        
        let block: (() -> ()) = {
            _ = self.promise.fulfill(f())
        }
        
        dispatch_async(self.queue, block)
    }
    
    convenience init(f: (() -> T)) {
        self.init(f:{ .Success(f()) })
    }
    
    init(f: (() -> Try<T>), queue: dispatch_queue_t) {
        self.promise = Promise<Try<T>>()
        self.queue = queue
        
        super.init()
        
        let block: (() -> ()) = {
            _ = self.promise.fulfill(f())
        }
        
        dispatch_async(self.queue, block)
    }
    
    convenience init(f: (() -> T), queue: dispatch_queue_t) {
        self.init(f:{ .Success(f()) }, queue:queue)
    }
    
    func cancel() -> Bool {
        return self.promise.breakPromise()
    }
    
    func isFinished() -> Bool {
        return self.promise.isFulfilled()
    }
    
    func isCancelled() -> Bool {
        return self.promise.isBroken()
    }
    
    func getPromise() -> P {
        return self.promise
    }
    
    func getState() -> PS {
        return self.getPromise().getState()
    }
    
    func map<S>(f: ((T) -> Try<S>)) -> Future<S> {
        
        let f = Future<S>(f:{ () -> Try<S> in
            var state: PS! = nil
            var result: Try<S>! = nil
            
            dispatch_sync(scheduler.assignThread(), {
                do {} while !self.test
                state = self.getPromise().getState()
                })
            
            switch state! {
            case .Fulfilled(let value):
                result = value.map(f)
            case .Broken:
                result = Try.Failure(PromiseBrokenException())
            case .Pending:
                ()
            }
            
            return result
            })
        
        self.promise.registerObserver(f)
        
        return f
    }
    
    func map<S>(f: ((T) -> S)) -> Future<S> {
        return self.map({ Try.Success(f($0)) })
    }
    
    // Modularize when algorithm has been designed
    func map<S>(f: ((Try<T>) -> Try<S>)) -> Future<S> {
        let f = Future<S>(f:{ () -> Try<S> in
            var state: PS! = nil
            var result: Try<S>! = nil
            
            dispatch_sync(scheduler.assignThread(), {
                do {} while !self.test
                state = self.getPromise().getState()
                })
            
            switch state! {
            case .Fulfilled(let value):
                result = f(value)
            case .Broken:
                result = Try.Failure(PromiseBrokenException())
            case .Pending:
                ()
            }
            
            return result
            })
        
        self.promise.registerObserver(f)
        
        return f
    }
    
    func map<S>(f: ((Try<T>) -> S)) -> Future<S> {
        return self.map({ Try.Success(f($0)) })
    }
    
    func map<S>(pf: PartialFunction<Try<T>,Try<S>>) -> Future<S> {
        let f = Future<S>(f:{ () -> Try<S> in
            var state: PS! = nil
            var result: Try<S>! = nil
            
            dispatch_sync(scheduler.assignThread(), {
                do {} while !self.test
                state = self.getPromise().getState()
                })
            
            switch state! {
            case .Fulfilled(let value):
                result = pf.apply(value)
            case .Broken:
                result = Try.Failure(PromiseBrokenException())
            case .Pending:
                ()
            }
            
            return result
            })
        self.promise.registerObserver(f)
        
        return f
    }
    
    func map<S>(pf: PartialFunction<Try<T>,S>) -> Future<S> {
        return self.map({ Try.Success(pf.apply($0)!) })
    }
    
//    func bind(f: ((T) -> Future<S>)) -> Future<S> {
//        
//    }
    
    func peek() -> T? {
        return self.promise.peek()?.toOption()
    }
    
    func waitFor() -> Try<T>? {
        switch self.promise.waitFor() {
        case .Fulfilled(let value):
            return value
        default:
            return nil
        }
    }
    
    func onSuccess<S>(pf: PartialFunction<T,S>) -> () {
        
    }
    
    func onFailure<S>(pf: PartialFunction<T,S>) -> () {
        
    }
    
//    func and<S>(other: Future<S>) -> Future<(T,S)> {
//        
//    }
    
//    class func all<T>(futures: Future<T>[]) -> Future<T[]> {
//        
//    }
    
    
    
    func promiseDidFinish(_: NSNotification) {
        self.test = true
    }
    
}

operator infix >=> {associativity left}
@infix func >=> <T,S> (f: Future<T>, c: ((T) -> S)) -> Future<S> {
    return f.map(c)
}
