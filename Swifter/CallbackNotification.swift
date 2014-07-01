//
//  CallbackNotification.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/1/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A CallbackNotification is used to notify and execute an Executable upon
 * the completion of an observed object that triggers the execution. */
class CallbackNotification<T> : NSNotification {
    
    let value: T
    
    init(value: T) {
        self.value = value
        super.init()
    }
    
}
