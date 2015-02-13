//
//  LinkedList.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/26/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

/** This is a mutable implementation of a linked list and is not recommended to be
    used in a functional paradigm. */
public class LinkedList<T> {
    
    var _this: [T!] // TODO REMOVE WORKAROUND [T!] -> T, _this -> this
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
    
    public func push(t: T) -> () {
        let next = LinkedList<T>(this: self.this)
        next.prev = self
        next.next = self.next
        self.this = t
        self.next = next
    }
    
    public func pop() -> T? {
        let t = self.this
        self.this = self.next?.this
        self.next = self.next?.next
        if self.next != nil {
            self.next!.prev = self
        }
        return t
    }
    
    private func lastElement() -> LinkedList<T> {
        var list: LinkedList<T> = self
        while (list.next != nil) {
            list = list.next!
        }
        return list
    }
    
    public func append(list: LinkedList<T>) {
        let last = self.lastElement()
        last.next = list
        list.prev = last
    }
    
    public func append(last: T) {
        self.append(LinkedList(this: last))
    }
    
    public func isEmpty() -> Bool {
        return (self.this != nil) ? false : true
    }
    
}

public class LinkedListGenerator<T> : GeneratorType {
    
    typealias Element = T
    
    var current: LinkedList<T>?
    
    init(linkedList: LinkedList<T>) {
        self.current = LinkedList<T>()
        self.current!.this = linkedList.this
        self.current!.next = linkedList.next
        self.current!.prev = linkedList.prev
    }
    
    public func next() -> Element? {
        let next = current?.this
        current = current?.next
        if current != nil {
            current!.prev = nil
        }
        return next
    }
    
}

//extension LinkedList : SequenceType { // TODO REMOVE COMMENTS
//    
//    typealias Generator = LinkedListGenerator<T>
//
//    typealias Generator = LinkedListGenerator<T>
//    
//    public func generate() -> Generator {
//        return Generator(linkedList: self)
//    }
//    
//}
