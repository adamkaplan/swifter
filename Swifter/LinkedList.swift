//
//  LinkedList.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/26/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

// TODO: make a functional version; conform to Sequence. is this necessary?
class LinkedList<T> {
    
    var _this: [T!]
    var this: T! {
    get
    {
        return _this[0]
    }
    set(newThis)
    {
        _this = [newThis]
    }
    }
    var next: LinkedList<T>?
    var prev: LinkedList<T>?
    
    init() {
        _this = [nil]
        self.next = nil
        self.prev = nil
    }
    
    init(this: T!) {
        _this = [this]
        self.next = nil
        self.prev = nil
    }
    
    deinit {
        DLog(.LinkedList, "Deinitializing LinkedList")
    }
    
    func push(t: T) -> () {
        let next = LinkedList<T>(this: self.this)
        next.prev = self
        next.next = self.next
        self.this = t
        self.next = next
    }
    
    func pop() -> T? {
        let t = self.this
        self.this = self.next?.this
        self.next = self.next?.next
        if self.next {
            self.next!.prev = self
        }
        return t
    }
    
    func isEmpty() -> Bool {
        return self.this ? false : true
    }
    
}
