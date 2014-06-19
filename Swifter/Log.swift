//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

import Foundation

enum LogCategory: String {
    case PromiseLogging = "Promise logging"
    case PromiseMade = "Promise made"
    case PromiseFulfilled = "Promise fulfilled"
    case FutureLogging = "Future logging"
    case FutureBound = "Future bound"
    case SchedulerLogging = "Scheduler logging"
    case ThreadCreation = "Thread created"
    case ThreadDispatch = "Thread dispatched"
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
