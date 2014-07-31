//
//  List.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/16/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A generic, functional, persistent/immutable linked list based on the algorithm
 * designed by Sleator, Tarjan, et al. */
class List<T> {
    
    typealias Version = PersistentData<T>.Version
 
    private let version: Version
    private let internalList: ListImpl<T>
    
    init() {
        self.version = Version()
        self.internalList = Nil<T>()
    }
    
    init(_ head: T, _ tail: List<T>) {
        self.version = tail.version
        self.internalList = Cons(head, tail.internalList)
    }

    private init(_ version: Version, _ list: ListImpl<T>) {
        self.version = version
        self.internalList = list
    }
    
    deinit {
        DLog(.List, "Deinitializing " + self.description)
    }
    
    func leftFold<A>(acc: A, f: (acc: A, elem: T) -> A) -> A {
        return self.internalList.internalLeftFold(self.version, acc: acc, f: f)
    }
    
    func rightFold<A>(acc: A, f: (elem: T, acc: A) -> A) -> A {
        return self.internalList.internalRightFold(self.version, acc: acc, f: f)
    }

    func head() -> T? {
        return self.internalList.head(self.version)
    }

    func tail() -> List<T>? {
        if let tail = self.internalList.tail(self.version) {
            return List<T>(self.version, tail)
        } else {
            return nil
        }
    }
    
    func isEmpty() -> Bool {
        return self.leftFold(true) { (_, _) -> Bool in false }
    }
    
    func reverseMap<S>(f: T -> S) -> List<S> {
        return self.leftFold(List<S>()) { List<S>(f($0.elem), $0.acc) }
    }
    
    func map<S>(f: T -> S) -> List<S> {
        return self.rightFold(List<S>()) { List<S>(f($0.elem), $0.acc) }
    }
    
    func iter(f: T -> ()) -> () {
        self.map(f)
    }

    func reverse() -> List<T> {
        return self.reverseMap { $0 }
    }
    
    func reverseFilter(p: T -> Bool) -> List<T> {
        return self.leftFold(List<T>()) { p($0.elem) ? List<T>($0.elem, $0.acc) : $0.0 }
    }
    
    func filter(p: T -> Bool) -> List<T> {
        return self.rightFold(List<T>()) { p($0.elem) ? List<T>($0.elem, $0.acc) : $0.acc}
    }

    func contains(value: T, eq: (T,T) -> Bool) -> Bool {
        return self.leftFold(false) { $0.acc || eq($0.elem, value) }
    }
    
    func nth(n: Int) -> T? {
        return self.leftFold((n: n, nth: nil)) {
            let (n, nth) = $0.acc
            if n == 0 {
                return (n - 1, $0.elem)
            } else {
                return (n - 1, nth)
            }
        }.nth
    }
    
    func length() -> Int {
        return self.leftFold(0) { $0.acc + 1 }
    }
    
    func last() -> T? {
        return self.leftFold(nil) { $0.elem }
    }
    
    func reversePartition(p: T -> Bool) -> (List<T>, List<T>) {
        return self.leftFold((trues: List<T>(), falses: List<T>())) {
            if p($0.elem) {
                return (List<T>($0.elem, $0.acc.trues), $0.acc.falses)
            } else {
                return ($0.acc.trues, List<T>($0.elem, $0.acc.falses))
            }
        }
    }
    
    func partition(p: T -> Bool) -> (List<T>, List<T>) {
        return self.rightFold((trues: List<T>(), falses: List<T>())) {
            if p($0.elem) {
                return (List<T>($0.elem, $0.acc.trues), $0.acc.falses)
            } else {
                return ($0.acc.trues, List<T>($0.elem, $0.acc.falses))
            }
        }
    }
    
    func leftFold2<A,S>(other: List<S>, acc: A, f: (acc: A, one: T, two: S) -> A) -> A? { // TODO reimplement
        if self.length() != other.length() {
            return nil
        }

        return self.leftFold((acc, other)) {
            let (acc, other) = $0.acc
            return (f(acc: acc, one: $0.elem, two: other.head()!), other.tail()!)
        }.0
    }
    
    func equal(other: List<T>, eq: (T, T) -> Bool) -> Bool {
        let fold2Result = self.leftFold2(other, acc: true) { $0.acc && eq($0.one, $0.two) }
        return fold2Result ? fold2Result! : false
    }
    
    func append(end: List<T>) -> List<T> {
        let appendResult = self.internalList.append(self.version, end: end)
        switch appendResult {
        case .NewData(let newData):
            return List<T>(Version(), Cons<T>(newData))
        case .NewList(let newList):
            return newList
        case .NewVersion(let version):
            return List<T>(version, self.internalList)
        }
    }
    
}

extension List : Printable {
    
    var description: String {
    get {
        return "[" + self.leftFold("") { $0 + "|\($1)|" } + "]"
    }
    }
    
}

enum AppendChange<T> {
    case NewData(PersistentData<(T, ListImpl<T>)>)
    case NewList(List<T>)
    case NewVersion(List<T>.Version)
}

class ListImpl<T> {
    
    typealias Version = List<T>.Version
    
    func internalLeftFold<A>(version: Version, acc: A, f: ((A,T) -> A)) -> A {
        return acc
    }
    
    func internalRightFold<A>(version: Version, acc: A, f: ((T,A) -> A)) -> A {
        return acc
    }
    
    func head(version: Version) -> T? {
        return nil
    }
    
    func tail(version: Version) -> ListImpl<T>? {
        return nil
    }
    
    func append(version: Version, end: List<T>) -> AppendChange<T> {
        return .NewList(end)
    }
    
}

class Nil<T> : ListImpl<T> {

    deinit {
        DLog(.List, "Deinitializing Nil")
    }

}

class Cons<T> : ListImpl<T> {
    
    typealias Data = PersistentData<(T, ListImpl<T>)>
    
    let data: Data
    
    init(_ head: T, _ tail: ListImpl<T>) {
        self.data = Data((head, tail))
    }
    
    private init(_ data: Data) {
        self.data = data
    }

    deinit {
        DLog(.List, "Deinitializing Cons")
    }

    override func internalLeftFold<A>(version: Version, acc: A, f: ((A,T) -> A)) -> A {
        let (head, tail) = self.data.get(version)
        return tail.internalLeftFold(version, acc: f(acc, head), f: f)
    }
    
    override func internalRightFold<A>(version: Version, acc: A, f: ((T,A) -> A)) -> A {
        let (head, tail) = self.data.get(version)
        return f(head, tail.internalRightFold(version, acc: acc, f: f))
    }
    
    override func head(version: Version) -> T? {
        let (head, _) = self.data.get(version)
        return head
    }
    
    override func tail(version: Version) -> ListImpl<T>? {
        let (_, tail) = self.data.get(version)
        return tail
    }
    
    override func append(version: Version, end: List<T>) -> AppendChange<T> {
        let (head, tail) = self.data.get(version)
        let appendChange = tail.append(version, end: end)
        switch appendChange {
        case .NewData(let data):
            if let newData = self.data.set((head, Cons<T>(data)) as (T, ListImpl<T>)) {
                return .NewData(newData)
            } else {
                return .NewVersion(self.data.version!)
            }
        case .NewList(let list):
            let data: (T, ListImpl<T>) = (head, Appension<T>(list))
            if let newData = self.data.set(data) {
                return .NewData(newData)
            } else {
                return .NewVersion(self.data.version!)
            }
        case .NewVersion(let version): // CHECK TODO
            if self.data.version {
                switch self.data.version!.compare(version) {
                case .OrderedDescending:
                    return .NewVersion(version)
                default:
                    return .NewData(Data((head, tail)))
                }
            } else {
                return .NewVersion(version)
            }
        }

    }
    
}

class Appension<T> : ListImpl<T> {
    
    typealias Data = PersistentData<List<T>>
    
    let data: Data
    
    init(_ tail: List<T>) {
        Log(.List, "Initializing Appension with " + tail.description)
        self.data = Data(tail)
    }
    
    deinit {
        DLog(.List, "Deinitializing Appension")
    }
    
    override func internalLeftFold<A>(version: Version, acc: A, f: ((A,T) -> A)) -> A {
        let tail = self.data.get(version)
        return tail.leftFold(acc, f: f)
    }
    
    override func internalRightFold<A>(version: Version, acc: A, f: ((T,A) -> A)) -> A {
        let tail = self.data.get(version)
        return tail.rightFold(acc, f: f)
    }
    
    override func head(version: Version) -> T? {
        let tail = self.data.get(version)
        return tail.internalList.head(tail.version)
    }
    
    override func tail(version: Version) -> ListImpl<T>? {
        let tail = self.data.get(version)
        return tail.internalList.tail(tail.version)
    }
    
    override func append(version: Version, end: List<T>) -> AppendChange<T> {
        // Fix here to not return a .NewList but either a .NewVersion etc.
        // Do we even need .NewList?
        let tail = self.data.get(version)
        let newTail = tail.append(end)
        if let newData = self.data.set(newTail) {
            return .NewList(newTail)
        } else {
            NSLog("Returning Appension .NewVersion")
            return .NewVersion(self.data.version!)
        }
    }
    
}

/* Constructs a List from an Array. */
operator prefix ^ {}
@prefix func ^ <T> (arr: [T]) -> List<T> {
    var list = List<T>()
    for i in 1...arr.count {
        NSLog("\(i) " + list.description)
        list = arr[arr.count - i]^^list
    }
    return list
}

/* Constructs a List from a head and a tail. */
operator infix ^^ {associativity right}
@infix func ^^ <T> (head: T, tail: T) -> List<T> {
    return List<T>(head, List<T>(tail, List<T>()))
}
@infix func ^^ <T> (head: T, tail: List<T>) -> List<T> {
    return List<T>(head, tail)
}

/* Appends two Lists in order. */
operator infix ^&^ {associativity left}
@infix func ^&^ <T> (front: List<T>, end: List<T>) -> List<T> {
    return front.append(end)
}
