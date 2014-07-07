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
class CallbackNotification : NSNotification {
    
    var _value: [Any]
    var value: Any {
    get
    {
       return _value[0]
    }
    set(newValue)
    {
        _value = [newValue]
    }
    }
    
    init(value: Any) {
        _value = [value]
        super.init()
        self.value = value
    }
    
}
