//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

import Foundation

enum LogCategory: String {
    case Executable = "Executable"
    case OnceExecutable = "OnceExecutable"
    case Future = "Future"
    case FutureFolded = "FutureMapped"
    case Promise = "Promise"
    case PromiseMade = "PromiseMade"
    case PromiseFulfilled = "PromiseFulfilled"
    case LinkedList = "LinkedList"
}

func Log(category: LogCategory) -> () {
    #if LOGGING
        NSLog(category.toRaw())
    #endif
}

func Log(category: LogCategory, format: String, args: Any...) -> () {
    #if LOGGING
        NSLog(format, args)
    #endif
}
