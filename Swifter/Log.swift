//
//  Log.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/11/14.
//  Copyright (c) 2014 Yahoo! Inc. All rights reserved.
//

/// This file contains utility functions to log the performance of the Swifter
/// framework in the Debug and Logging build configurations. These functions
/// do nothing in the Release build configuration, but may or may not be optimized
/// away during compilation.

import Foundation

internal enum LogCategory: BooleanType {
    case Executable
    case Future
    case LinkedList
    case List
    case Lock
    case PartialFunction
    case Promise
    case Timer
    
    var boolValue: Bool {
        get {
            switch self {
            case .Executable:
                return true
            case .Future:
                return true
            case .LinkedList:
                return true
            case .List:
                return true
            case .Lock:
                return true
            case .PartialFunction:
                return true
            case .Promise:
                return true
            case .Timer:
                return true
            }
        }
    }
}

internal func Log(category: LogCategory, string: String) -> () {
    #if LOGGING
        if category {
            NSLog(string)
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
