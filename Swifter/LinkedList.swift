//
//  LinkedList.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/26/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

// TODO: Generalize, maintain, and test. Perhaps has overhead in implementation.
// Also perhaps unnecessary.

class LinkedListCell<T> {
    let head: Any
    var next: LinkedListCell<T>?
    
    convenience init(head: T) {
        self.init(head: head, next: nil)
    }
    
    init(head: T, next: LinkedListCell<T>?) {
        self.head = head
        self.next = next
    }
}

@objc class LinkedList<T> {

    var head: LinkedListCell<T>?
    var last: LinkedListCell<T>!

    init() {
        self.head = nil
        self.last = nil
    }

    init(head: T) {
        self.head = LinkedListCell<T>(head: head)
        self.last = self.head
    }

    init(head: T, next: LinkedList<T>?) {
        self.head = LinkedListCell<T>(head: head, next: next?.head)
        self.last = next ? next!.last : self.head
    }

    func push(t: T) -> () {
        let head = LinkedListCell<T>(head: t, next: self.head)
        self.head = head
    }

    func add(t: T) -> () {
        self.last.next = LinkedListCell<T>(head: t)
        self.last = self.last.next
    }

    func pop() -> T? {
        let head = self.head?.head
        self.head = self.head?.next
        return head as? T
    }
}
