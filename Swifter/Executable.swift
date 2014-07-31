//
//  Executable.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/30/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* An Executable is a wrapped action (Task) and queue on which to be executed. */
public class Executable<T> {
    
    typealias Task = T -> ()
    
    let queue: NSOperationQueue
    let task: Task

    init(queue: NSOperationQueue, task: Task) {
        self.queue = queue
        self.task = task
    }
    
    deinit {
        DLog(.Executable, "Deinitializing Executable")
    }
    
    public func executeWithValue(value: T) -> () {
        Log(.Executable, "Executing with \(value) on \(self.queue)")
        self.queue.addOperationWithBlock { _ = self.task(value) }
    }
    
}
