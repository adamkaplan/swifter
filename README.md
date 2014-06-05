swifter
=======

Swifter makes Swift even Swifter by adding specialized functional extensions: supercharge your code

Partial Functions
=======

A partial function of type `PartialFunction<A, B>` is a unary function where the domain does not necessarily include all values of type A. The function `isDefinedAt` allows to test dynamically if a value is in the domain of the function.

The main distinction between `PartialFunction` and Swift functions is that the user of a `PartialFunction` may choose to do something different with input that is declared to be outside its domain. For example:

```swift
let sample = [1,2,3,4,5,6]

let acceptEven = PartialFunction<Int,String> { (i: Int, _) in
  if i % 2 == 0 {
    return .Match("\(i) is even")
  } else {
    return .NoMatch
  }
}

// the method isDefinedAt can be used by filter to select members
let evens = sample.filter { i in
  acceptEven.apply(i) != nil
}

// evens is [2, 4, 5]

// the method apply can be used to apply the partial function to arguments
// this method will print "# is even" for even numbers.
for i in sample {
  if let n = acceptEven.apply(i) {
    println(n)
  }
}

let acceptOdd = PartialFunction<Int,String> { (i: Int, _) in
  if i % 2 != 0 {
    return .Match("\(i) is odd")
  } else {
    return .NoMatch
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

let uppercase = PartialFunction<String,String> { (s: String, _) in
  .Match(s.uppercaseString)
}

// the method andThen allows chaining one partial function to be executed
// after another one on success
let uppercaseEvenOrOdd = evenOrOdd.andThen(uppercase)
for i in sample {
  if let n = uppercaseEvenOrOdd.apply(i) {
    println(n)
  }
}

```

Notes
=======
This is a first pass at a native implementation of Scala PartialFunction to Swift. It is meant as a fundamental building block for future features, and as a proof of concept.

The result of `apply()` is an optional value. This optional represents the accept/reject state of the partial function. Therefor, a `nil` result means that the argument was not applicable to the partial function.

Thanks to the Scala team at TypeSafe for providing inspiration and examples.

References
=======
[Scala Partial Functions Without A PhD](http://blog.bruchez.name/2011/10/scala-partial-functions-without-phd.html)
[Scala API](http://www.scala-lang.org/api/2.10.2/index.html#scala.PartialFunction)
