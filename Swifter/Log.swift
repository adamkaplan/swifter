//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

import Foundation

enum LogCategory: String {
    case Promise = "Promise"
    case PromiseMade = "PromiseMade"
    case PromiseFailed = "PromiseFailed"
    case PromiseBroken = "PromiseBroken"
    case PromiseFulfilled = "PromiseFulfilled"
    case Future = "Future"
    case FutureMapped = "FutureMapped"
    case Scheduler = "Scheduler"
    case ThreadCreation = "ThreadCreation"
    case ThreadDispatch = "ThreadDispatch"
}

func Log(category: LogCategory) {
    #if DEBUG
        NSLog(category.toRaw())
    #endif

    do {} while false;
}

func Log(category: LogCategory, format: String, args: Any...) -> () {
    #if DEBUG
        NSLog(format, args)
    #endif
    
    do {} while false;
}
