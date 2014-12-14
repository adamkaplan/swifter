swifter
=======

Swifter makes Swift _Swifter_ by adding functional extensions.

Partial Functions
=======

A partial function of type `PartialFunction<A, B>` is a unary function where the domain does not necessarily include all values of type A. The function `isDefinedAt` allows to test dynamically if a value is in the domain of the function.

The main distinction between `PartialFunction` and Swift functions is that the user of a `PartialFunction` may choose to do something different with input that is declared to be outside its domain. For example:

```swift
let sample = [1,2,3,4,5,6]

let acceptEven = PartialFunction<Int,String> { 
 	(i: Int, _) in
  	if i % 2 == 0 {
    	return .Defined("\(i) is even")
  	} else {
    	return .Undefined
  	}
}

// the method isDefinedAt can be used by filter to select members
let evens = sample.filter { acceptEven.apply($0) != nil } // evens is [2, 4, 5]

// the method apply can be used to apply the partial function to arguments
// this method will print "# is even" for even numbers.
for i in sample {
  	if let n = acceptEven.apply(i) {
    	println(n)
  	}
}

let acceptOdd = PartialFunction<Int,String> { 
  	(i: Int, _) in
  	if i % 2 != 0 {
    	return .Defined("\(i) is odd")
  	} else {
    	return .Undefined
  	}
}

// the method orElse allows chaining another partial function to handle
// input outside the declared domain
let evenOrOdd = isEven.orElse(isOdd)
for i in sample {
  	if let n = evenOrOdd.apply(i) {
    	println(n)
  	}
}

let uppercase = PartialFunction<String,String> { $0.0.uppercaseString }

// the method andThen allows chaining one partial function to be executed
// after another one on success
let uppercaseEvenOrOdd = evenOrOdd.andThen(uppercase)
for i in sample {
  	if let n = uppercaseEvenOrOdd.apply(i) {
    	println(n)
  	}
}
```

Concurrency
=======

Swifter implements `Future<T>` and `Promise<T>` as asynchronous primitives. `Promise<T>` is a once-writable container of a value that allows `Executable<T>` to be executed when the `Promise<T>` is fulfilled. `Future<T>` wraps a `Promise<T>` and manages the creation and scheduling of asynchronous tasks.
	
```swift
let future1 = Future<UInt32>(20)
let future2 = future1 >>| {
    (i: UInt32) -> String in
    sleep(i/10)
    return "Cat"
}
let promise3 = Promise<String>()
let future3 = future2 >>= {
    (_: String) -> Future<String> in
    return Future<String>(linkedPromise: promise3)
}
let future4 = future3 >>| {
    (_: String) -> Bool in
    return true
}

future1.value // 10, instantly
future2.value // nil (not completed yet)
future2.completedResult // Blocks for two seconds, then "Cat"
future3.value // nil
// future3.completedResult // would block forever
future2 >>| {
    promise3.tryFulfill($0)
}
future4.completedResult // true
future3.completedResult // "Cat"
```

Try
=======

Swift has no concept of try-catch, and expects programs to account for and prevent exceptional behavior. Swifter implements a `Try<T>` (that is, a Success or Failure) to allow programs to easily express and act on this behavior.

```swift
enum Exceptions :  TryFailure {
    case NotParseableAsInt
    case IndexOutOfBounds
    
    func fail() -> () {} // Conformance to TryFailure
}

// f1 parses a String to an Int.
let f1: String -> Try<Int> = {
    if let i = $0.toInt() {
        return .Success([i])
    } else {
        return .Failure(Exceptions.NotParseableAsInt)
    }
}

// f2 uses an input Int as an index into [10, 45].
let f2: Int -> Try<[Int]> = {
    let arr = [10, 45]
    if $0 >= 0 && $0 < arr.count {
        return .Success([[arr[$0]]])
    } else {
        return .Failure(Exceptions.IndexOutOfBounds)
    }
}

// f3 takes an [Int] and converts the first element to a String.
let f3: [Int] -> String = {
    return "\($0[0])"
}

// f performs f1, f2, and f3 in succession, returning the successful
// value, or if failed, returns a String specific to the failure.
let f: String -> String = {
    (str: String) -> String in
    return f1(str).bind(f2).map(f3).fold( { $0 }, {
        switch $0 as Exceptions {
        case .NotParseableAsInt:
            return "'" + str + "' isn't parseable as an int"
        case .IndexOutOfBounds:
            return "\(str.toInt()!) isn't a valid index into [10, 45]"
        }
    })
}

f("0") // "10"
f("1") // "45"
f("2") // "2 isn't a valid index into [10, 45]"
f("Hello") // "'Hello' isn't parseable as an int"
```

Functional Data Structures
=======

Swifter implements a functional (that is, persistent and immutable) linked `List<T>`, using a modification box (PersistentData<T>) based on the Sleator, Tarjan, et al. algorithm. 

```swift
// State (mutability)
let sumA: [Int] -> Int = { $0.reduce(0, +) }
let sumL: List<Int> -> Int = { $0.leftFold(0, +) }

var a0 = [6, 5, 3, 2, -1, 0]
let l0 = ^a0 // the ^ operator converts a [T] to a List<T>

sumA(a0) // 15
sumL(l0) // 15

a0.extend([4]) // mutates the state of the underlying array
let l1 = l0.append(^[4]) // mutates the underlying implementation, but not the visible structure of l0
let l2 = l0.rightFold(List<Int>()) { $0.elem ^^ $0.acc } // copy l0

sumA(a0) // 19, mutated (the same input to a function returns a different output)
sumL(l0) // 15, not mutated (the same input to a function returns the same output)
sumL(l1) // 19, includes new element
sumL(l2) // 15, not mutated

// Traversal (reduce, fold)
let getEvenStringsA: [(Int,String)] -> [String] = { $0.filter { $0.0 % 2 == 0 }.map { $0.1 } }
let getEvenStringsL: List<(Int,String)> -> List<String> = {
    $0.filter { $0.0 % 2 == 0 }.rightFold(List<String>()) {
        $0.elem.1 ^^ $0.acc
    }
}

var a3 = [(0, "A"), (1, "B"), (2, "C")]
let l3 = ^a3

getEvenStringsA(a3).description // "[A, C]"
getEvenStringsL(l3).description // "[|A||C|]"
````

Issues
=======

* Xcode6-Beta5 cannot compile generic types (workaround: wrap T as [T])
* Xcode6-Beta5 has difficulty inferencing types


Future Developments
=======

* Abstract the immutable/persistent data structure framework to allow custom recursive data structures to simply conform to this framework and be functional.
* Implement a Scheduler to intelligently manage the Executable queue/thread scheduling of Futures.
* Refactor Try<T> to Try<T,E : TryFailure>
* Reduce Swifter overhead and maximize compiler optimizations (PartialFunction pattern matching, tail recursion)
* Create Future CoreData and network call primitives
* Implement List pattern matching
* Simplify the creation of PartialFunctions
* Implement concurrent data structure operations (e.g., List.concurrentLeftFold<A>(acc: A, f: (A,T) -> A) -> Future<A>)

Notes
=======

The result of `apply()` is an optional value. This optional represents the accept/reject state of the partial function. Therefor, a `nil` result means that the argument was not applicable to the partial function.

Thanks to the Scala team at TypeSafe for providing inspiration and examples.

References
=======
[Scala Partial Functions Without A PhD](http://blog.bruchez.name/2011/10/scala-partial-functions-without-phd.html)

[Scala API](http://www.scala-lang.org/api/2.10.2/index.html#scala.PartialFunction)

[Making Data Structures Persistent](http://www.cs.cmu.edu/~sleator/papers/Persistence.htm)

Core Contributors
=======
[Adam Kaplan](https://github.com/adkap)
[Daniel Hanggi](https://github.com/djh325)
