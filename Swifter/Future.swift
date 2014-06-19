//
//  Future.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

let scheduler: Scheduler = Scheduler()

@objc class Future<T> {
    
    let promise: Promise<T>
    let queue: dispatch_queue_t
    
    // Queue is created within, but include classifier for type of queue??
    init(value: T) {
        self.promise = Promise<T>()
        self.queue = scheduler.assignThread()
        
        let block = {
            self.promise.fulfill(value)
        }
        
        dispatch_async(self.queue, block)
    }
    
    init(function: (() -> T)) {
        self.promise = Promise<T>()
        self.queue = scheduler.assignThread()
        
        let block = {
            self.promise.fulfill(function())
        }
        
        dispatch_async(self.queue, block)
    }
    
    init(function: (() -> T), queue: dispatch_queue_t) {
        self.promise = Promise<T>()
        self.queue = queue
        
        let block = {
            self.promise.fulfill(function())
        }
        
        dispatch_async(self.queue, block)
    }
    
    func peek() -> T {
        return (self.promise.peek() as T)
    }
    
    func isDetermined() -> Bool {
        return self.promise.isFulfilled()
    }

    func map<S>(function: ((T) -> S)) -> Future<S> {
        return Future<S>(function:{
            var value: T! = nil
            dispatch_sync(scheduler.stall, {
                value = self.waitFor() as T
                })
            return function(value)
            }, queue:self.queue)
    }
    
    func waitFor() -> Any {
        do {} while !self.promise.isFulfilled()
        
        return self.promise.peek()!
    }
    
}

operator infix >=> {associativity left}
@infix func >=> <T,S> (f: Future<T>, c: ((T) -> S)) -> Future<S> {
    return f.map(c)
}