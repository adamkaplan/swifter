//
//  Executable.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/30/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

let canExecuteNotification = "CanExecuteNotification"
let notificationCenter = NSNotificationCenter.defaultCenter()

/* An Executable is a wrapped computation (Task) and thread on which to be executed. */
class Executable<T> {
    
    typealias Task = ((Try<T>) -> ())
    
    let task: Task
    
    let thread: NSOperationQueue
    
    let observer: AnyObject!
    let observed: AnyObject!
    
    var value: Try<T>!

    /* Creates an Executable to run a Task on an NSOperationQueue, optionally
     * triggered by a CallbackNotification sent from `observed`. */
    init(task: Task, thread: NSOperationQueue, observed: AnyObject!) {
        self.task = task
        self.thread = thread
        self.observed = observed
        self.observer = notificationCenter.addObserverForName(canExecuteNotification,
            object: observed,
            queue: thread,
            usingBlock: {
                NSLog(
                    "in usingBlock")
                self.receiveNotification($0)
            })
    }
    
    deinit {
        Log(.Executable, "Deinitializing Executable and removing from notification center.")
        notificationCenter.removeObserver(self)
    }
    
    /* The selector called when the notification center receives a CanExecuteNotification. */
    func receiveNotification(notification: NSNotification) -> () {
        Log(.Executable, "Received notification")
        
        if let tryObject = (notification.userInfo["callbackValue"] as? TryObject<T>) {
            let value = tryObject.toEnum()
            self.executeWithValue(value)
        }
    }
    
    /* Executes the Executable by running its Task on the NSOperationQueue with `value`. */
    func executeWithValue(value: Try<T>) -> () {
        Log(.Executable, "Executing with \(value) on \(self.thread)")
        self.value = value
        self.thread.addOperationWithBlock { self.task(self.value); return () }
    }
    
}

/* A OnlyExecutableOnceException indicates that the Executable was attempted to 
 * be executed more than once. */
class OnlyExecutableOnceException: NSException {
    
    init() {
        super.init(name: "OnlyExecutableOnceException", reason: nil, userInfo: nil)
    }
    
}

/* A OnceExecutable is an Executable that can only be executed once. */
class OnceExecutable<T> : Executable<T> {
    
    typealias OEOE = OnlyExecutableOnceException
    
    /* Creates a OnceExecutable to run a Task on an NSOperationQueue, optionally
     * triggered by a CallbackNotification sent from `observed`. */
    init(task: Task, thread: NSOperationQueue, observed: AnyObject!) {
        super.init(task: task, thread: thread, observed: observed)
    }
    
    /* Creates a OnceExecutable with the execution parameters as the Executable. */
    init(parent: Executable<T>) {
        super.init(task: parent.task, thread: parent.thread, observed: parent.observed)
    }
    
    /* The selector called when the notification center receives a CanExecuteNotification. 
     * The OnceExecutable implementation removes the Executable from the notification center
     * dispatch table to minimize callbacks to execute more than once. */
    override func receiveNotification(notification: NSNotification) -> () {
        super.receiveNotification(notification)
        
        if (self.value) {
            notificationCenter.removeObserver(self.observer)
            Log(.OnceExecutable, "Removed the OnceExecutable from the notification center dispatch table.")
        }
    }
    
    /* Executes the Executable by running its Task on the NSOperationQueue with `value`. 
     * This process can only occur once, and the OnceExecutable will raise a 
     * OnlyExecutableOnceException if called to execute a second time. */
    override func executeWithValue(value: Try<T>) -> () {
        if self.value {
            OEOE().raise()
        } else {
            super.executeWithValue(value)
        }
    }
    
}
