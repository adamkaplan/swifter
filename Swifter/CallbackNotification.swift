//
//  CallbackNotification.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/1/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

let callbackNotification = "CallbackNotification"
let callbackValueKey = "callbackValue"

/* A CallbackNotification is used to notify and execute an Executable upon
 * the completion of an observed object that triggers the execution. */
class CallbackNotification<T : AnyObject> : NSNotification {
    
//    override var name: String! {
//    get {
//        return callbackNotification
//    }
//    }
//    
//    let caller: AnyObject!
//    
//    override var object: AnyObject! {
//    get {
//        return self.caller
//    }
//    }
//
//    let _callbackValue: T
//    
//    var callbackValue: T {
//    get {
//        return _callbackValue
//    }
//    }
//    
//    override var userInfo: [NSObject : AnyObject]! {
//    get {
//        return [callbackValueKey : self.callbackValue]
//    }
//    }
//    
//    init(callbackValue: T, caller: AnyObject?) {
//        Log(.Callback, "CallbackNotification initialized")
//        self._callbackValue = callbackValue
//        self.caller = caller
//        super.init(name: self.name, object: self.object, userInfo: self.userInfo)
//    }
    
}
