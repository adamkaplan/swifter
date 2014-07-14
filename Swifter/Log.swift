//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

import Foundation

enum LogCategory: String, LogicValue {
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
        }
    }
}

func Log(category: LogCategory) -> () {
    #if LOGGING
        if category {
            NSLog(category.toRaw())
        }
    #endif
}

func Log(category: LogCategory, format: String, args: Any...) -> () {
    #if LOGGING
        if category {
            NSLog(format, args)
        }
    #endif
}

func DLog(category: LogCategory) -> () {
    #if DEBUG
        if category {
            NSLog(category.toRaw())
        }
    #endif
}

func DLog(category: LogCategory, format: String, args: Any...) -> () {
    #if DEBUG
        if category {
            NSLog(format, args)
        }
    #endif
}
