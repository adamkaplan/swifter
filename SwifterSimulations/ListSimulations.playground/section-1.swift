// ListSimulations.playground
// A demonstration of the Tarjan, Sleator, et al algorithm and its implementation
// into an immutable linked list. 
// Compares List to the native Array and demonstrates the additional functionalities 
// provided by List

import Foundation

//
// IMPLEMENTATION
//

internal class PersistentData<T> {
    
    typealias Version = NSDate
    
    let fstValue: T
    
    var version: Version?
    var sndValue: T!
    
    init(_ fstValue: T) {
        self.fstValue = fstValue
    }
    
    func get(version: Version) -> T {
        if self.version != nil {
            switch self.version!.compare(version) {
            case .OrderedDescending:
                return self.fstValue
            case .OrderedSame, .OrderedAscending:
                return self.sndValue
            }
        } else {
            return self.fstValue
        }
    }
    
    func set(sndValue: T) -> PersistentData<T>? {
        if self.version != nil {
            return PersistentData<T>(sndValue)
        } else {
            self.version = Version()
            self.sndValue = sndValue
            return nil
        }
    }
    
}

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
        return fold2Result ?? false
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

/** The internal implementation of the List. It is made of three clusers: Nil, Cons,
and Appension. A Nil node is the end of a list. A Cons joins an element to a
list tail, using the version of the List as the version of the overall Cons. An
Appension is a wrapper for a List that causes the traversal version of the List to
be used, without regard to the previous traversal versions. */
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

class Nil<T> : ListImpl<T> {}

class Cons<T> : ListImpl<T> {
    
    typealias Data = PersistentData<(T, ListImpl<T>)>
    
    let data: Data
    
    init(_ head: T, _ tail: ListImpl<T>) {
        self.data = Data((head, tail))
    }
    
    private init(_ data: Data) {
        self.data = data
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
            if (self.data.version != nil) {
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
        self.data = Data(tail)
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
            return .NewVersion(self.data.version!)
        }
    }
    
}

prefix operator  ^ {}
prefix func ^ <T> (arr: [T]) -> List<T> {
    var list = List<T>()
    for i in 1...arr.count {
        list = arr[arr.count - i]^^list
    }
    return list
}

infix operator  ^^ {associativity right}
func ^^ <T> (head: T, tail: T) -> List<T> {
    return List<T>(head, List<T>(tail, List<T>()))
}
func ^^ <T> (head: T, tail: List<T>) -> List<T> {
    return List<T>(head, tail)
}

infix operator  ^&^ {associativity right}
func ^&^ <T> (front: List<T>, end: List<T>) -> List<T> {
    return front.append(end)
}

//
// DEMONSTRATION
//

// State (mutability)
let sumA: [Int] -> Int = { $0.reduce(0, +) }
let sumL: List<Int> -> Int = { $0.leftFold(0, +) }

var a0 = [6, 5, 3, 2, -1, 0]
var l0 = ^a0

sumA(a0) // 15
sumL(l0) // 15

a0.extend([4]) // mutates the state of the underlying array
let l1 = l0.append(^[4]) // mutates the underlying implementation, but not the visible structure of l0
let l2 = l0

sumA(a0) // 19, mutated
sumL(l0) // 15, not mutated
sumL(l1) // 19, includes new element
sumL(l2) // 15, not mutated

l0 = l1 // can change references to Lists but overall data structure contains all versions

sumA(a0) // 19, mutated
sumL(l0) // 19, is l1
sumL(l1) // 19, is l1
sumL(l2) // 15, is l0

// Folding
// Array and List define a traversal pattern (reduce, fold) that permit simple creation of various functions
let allA: [Bool] -> Bool = { $0.reduce(true) { $0.0 && $0.1.boolValue }.boolValue }
let allL: List<BooleanType> -> Bool = { $0.leftFold(true) { $0.acc && $0.elem.boolValue }.boolValue }

let getEvenStringsA: [(Int,String)] -> [String] = { $0.filter { $0.0 % 2 == 0 }.map { $0.1 } }
let getEvenStringsL: List<(Int,String)> -> List<String> = {
    $0.filter { $0.0 % 2 == 0 }.rightFold(List<String>()) {
        $0.elem.1 ^^ $0.acc
    }
}

var a3 = [(0, "A"), (1, "B"), (2, "C")]
let l3 = ^a3

getEvenStringsA(a3).description
getEvenStringsL(l3).description

// func is necessary as generic closures cannot be created (yet?)
func isMemberA<T>(array: [T], elem: T, eq: (T,T) -> Bool) -> Bool {
    return array.reduce(false) { $0.0 || eq($0.1, elem) }
}

func uniqueA<T>(array: [T], eq: (T,T) -> Bool) -> [T] {
    var uniqueArray: [T] = []
    array.map { isMemberA(uniqueArray, $0, eq) ? () : uniqueArray.append($0) }
    return uniqueArray
}

func uniqueL<T>(list: List<T>, eq: (T,T) -> Bool) -> List<T> {
    return list.rightFold(List<T>()) { $0.acc.contains($0.elem, eq: eq) ? $0.acc : $0.elem ^^ $0.acc }
}

a3.extend(a3) // Mutated to [(0, "A"), (1, "B"), (2, "C"), (0, "A"), (1, "B"), (2, "C")]
let a4 = a3
let l4 = l3 ^&^ l3

a4.description
l4.description

getEvenStringsA(a4).description
getEvenStringsL(l4).description
uniqueA(getEvenStringsA(a4), ==).description
uniqueL(getEvenStringsL(l4), ==).description

func both<T,S>(tuple: (T,T), f: T -> S) -> (S,S) {
    return (f(tuple.0), f(tuple.1))
}

let splitStringsL: List<(Int,String)> -> (List<String>, List<String>) = {
    both($0.partition { $0.0 % 2 == 0 }) { $0.map { $0.1 } }
}

let (even1, odd1) = splitStringsL(l3)
let (even2, odd2) = splitStringsL(l4)
even1.description
odd1.description
even2.description
odd2.description
uniqueL(even2, ==).description
uniqueL(odd2, ==).description
