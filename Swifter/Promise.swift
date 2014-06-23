//
//  Promise.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

// TODO: Refactor Promises to be more concise and essential. Create Callback
// system in which Promises interact with Runnable/Callback objects once a value
// that is promised has been fulfilled. Scheduling and the Callback objects are to
// be abstracted from Promises; Promises only work with fulfilled values and
// announce when they have been fulfilled. They interact with Callbacks by running
// a callback or execute method.

enum PromiseState<T> {
    case Fulfilled(T)
    case Broken
    case Pending
}

// Only necessary for logging; use #if in conjunction with Log.
extension PromiseState: Printable {
    var description: String {
    get {
        switch self {
        case .Fulfilled(let value):
            return ".Fulfilled(\(value))"
        case .Broken:
            return ".Broken"
        case .Pending:
            return ".Pending"
        }
    }
    }
}

class PromiseBrokenException: NSException {
    
    init() {
        super.init(name:"PromiseBrokenException", reason:nil, userInfo:nil)
    }
    
}

@objc class Promise<T> {
    
    var state: PromiseState<T>
    
    init() {
        Log(.PromiseMade)
        self.state = .Pending
    }
    
    func fulfill(value: T) -> Bool {
        switch self.state {
        case .Pending:
            Log(.PromiseFulfilled, "Fulfilled with \(value)")
            self.state = .Fulfilled(value)
            NSNotificationCenter().postNotificationName(nil, object: self, userInfo: nil)
            return true
        default:
            Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
            return false
        }
    }
    
    func breakPromise() -> Bool {
        switch self.state {
        case .Pending:
            self.state = .Broken
            Log(.PromiseBroken)
            return true
        default:
            Log(.Promise, "Attempted to fulfill an already-fulfilled promise (\(self.state)).")
            return false
        }
    }
    
    func isFulfilled() -> Bool {
        switch self.state {
        case .Fulfilled(_):
            return true
        default:
            return false
        }
    }
    
    func isBroken() -> Bool {
        switch self.state {
        case .Broken:
            return true
        default:
            return false
        }
    }
    
    func isPending() -> Bool {
        switch self.state {
        case .Pending:
            return true
        default:
            return false
        }
    }
    
    func peek() -> T? {
        switch self.state {
        case .Fulfilled(let value):
            Log(.Promise, "Peeking at Fulfilled(\(value))")
            return value
        default:
            return nil
        }
    }
    
    func getState() -> PromiseState<T> {
        return self.state
    }
    
    func waitFor() -> PromiseState<T> {
        do {} while self.isPending()
        
        return self.getState()
    }
    
//    func futureOf() -> Future<T> {
//
//    }
    
    func registerObserver(obs: NSObject) {
        NSNotificationCenter.defaultCenter().addObserver(obs, selector:"promiseDidFinish", name:nil, object:self)
    }
}
