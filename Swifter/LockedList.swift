//
//  LockedList.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/14/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

class LockedList<T> {
    
    let lock: NSLock
    let list: LinkedList<T>
    
    init() {
        self.lock = NSLock()
        self.list = LinkedList<T>()
    }
    
    init(this: T) {
        self.lock = NSLock()
        self.list = LinkedList<T>(this: this)
    }
    
    func push(t: T) -> () {
        return self.lock.perform { self.list.push(t) }
    }
    
    func pop() -> T? {
        return self.lock.perform ( self.list.pop )
    }
    
    func isEmpty() -> Bool {
        return self.lock.perform ( self.list.isEmpty )
    }
    
}
