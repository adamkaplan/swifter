//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

import Foundation

internal enum LogCategory: String, LogicValue {
    case Executable = "Executable"
    case OnceExecutable = "OnceExecutable"
    case Lock = "Lock"
    case Timer = "Timer"
    case Callback = "Callback"
    case Future = "Future"
    case FutureFolded = "FutureMapped"
    case Promise = "Promise"
    case PromiseMade = "PromiseMade"
    case PromiseFulfilled = "PromiseFulfilled"
    case LinkedList = "LinkedList"
    case List = "List"
    
    func getLogicValue() -> Bool {
        switch self {
        case .Executable:
            return true
        case .OnceExecutable:
            return true
        case .Lock:
            return true
        case .Timer:
            return true
        case .Callback:
            return true
        case .Future:
            return true
        case .FutureFolded:
            return true
        case .Promise:
            return true
        case .PromiseMade:
            return true
        case .PromiseFulfilled:
            return true
        case .LinkedList:
            return true
        case .List:
            return true
        }
    }
}

internal func Log(category: LogCategory) -> () {
    #if LOGGING
        if category {
            NSLog(category.toRaw())
        }
    #endif
}

internal func Log(category: LogCategory, string: String) -> () {
    #if LOGGING
        if category {
            NSLog(string)
        }
    #endif
}

internal func DLog(category: LogCategory) -> () {
    #if DEBUG
        if category {
            NSLog(category.toRaw())
        }
    #endif
}

internal func DLog(category: LogCategory, string: String) -> () {
    #if DEBUG
        if category {
            NSLog(string)
        }
    #endif
}
