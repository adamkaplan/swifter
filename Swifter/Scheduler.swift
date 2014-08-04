//
//  Scheduler.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/** The singleton Scheduler manages the creation and assignment of operation queues
    for use by Executables, Futures, and Promises. Scheduler.assignQueue() should
    be optimized, e.g., to reuse serial queues for operations that only need to be executed
    once a previous operation in the queue has completed. */
public class Scheduler {
    
    public class func assignQueue() -> NSOperationQueue {
        return NSOperationQueue()
    }
    
}
