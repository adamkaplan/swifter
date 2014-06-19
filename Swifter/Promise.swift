//
//  Promise.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

enum PromisedValue {
    case Fulfilled(Any)
    case NotYetFulfilled
}

@objc class PromisedAlreadyFulfilledException: NSException {
    
    init() {
        super.init(name:"PromiseAlreadyFulfilled", reason:nil, userInfo:nil)
    }
}

class Promise<T> {
    
    var value: PromisedValue
    
    init() {
        Log(.PromiseMade)
        self.value = .NotYetFulfilled
    }
    
    func fulfill(value: T) -> () {
        switch self.value {
        case .Fulfilled(_):
            PromisedAlreadyFulfilledException().raise()
        case .NotYetFulfilled:
            Log(.PromiseFulfilled, "Fulfilled with \(value)")
            self.value = .Fulfilled(value)
        }
    }
    
    func fulfillIfUnfulfilled(value: T) -> () {
        switch self.value {
        case .Fulfilled(_):
            ()
            Log(.PromiseLogging, "Attempted to fulfill an already fulfilled promise.")
        case .NotYetFulfilled:
            Log(.PromiseFulfilled, "Fulfilled with \(value)")
            self.value = .Fulfilled(value)
        }
    }
    
    func isFulfilled() -> Bool {
        switch self.value {
        case .Fulfilled(_):
            return true
        case .NotYetFulfilled:
            return false
        }
    }
    
    func peek() -> Any? {
        switch self.value {
        case .Fulfilled(let value):
            Log(.PromiseLogging, "Peeking at Fulfilled(\(value))")
            return value
        case .NotYetFulfilled:
            Log(.PromiseLogging, "Peeking at NotYetFulfilled")
            return nil
        }
    }
}
