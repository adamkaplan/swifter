//
//  Scheduler.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/19/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

// Manage the creation and selection of threads.

// TODO: make everything single-instance
@objc class Scheduler {
    
    var queues: Array<dispatch_queue_t>

    let stall: dispatch_queue_t = dispatch_queue_create("concurrent stalling queue", DISPATCH_QUEUE_CONCURRENT)
    // A concurrent queue onto which bound futures are placed.
    
    init() {
        self.queues = []
    }
    
    func createThread() -> dispatch_queue_t {
        let ns: NSString = "Queue \(self.queues.count - 1)"
        let cs: CString = ns.cStringUsingEncoding(String.defaultCStringEncoding())
        let q: dispatch_queue_t = dispatch_queue_create(cs, DISPATCH_QUEUE_CONCURRENT)
        self.queues.append(q)
        return q
    }
    
    func assignThread() -> dispatch_queue_t {
        return createThread()
    }
}
