// Playground - noun: a place where people can play

import Cocoa
/*
let acceptEven = PartialFunction<Int, String> { (i: Int, Bool) in
    if i % 2 == 0 {
        return .Match("\(i) is even")
    } else {
        return .NoMatch
    }
}

let acceptOdd = PartialFunction<Int, String> { (i: Int, Bool) in
    if i % 2 != 0 {
        return .Match("\(i) is odd")
    } else {
        return .NoMatch
    }
}

let acceptNone = PartialFunction<Int, String> { (i: Int, Bool) in
    return .NoMatch
}

let uppercaseStr = PartialFunction<String, String> { (str: String, Bool) in
    return .Match(str.uppercaseString)
}

let combined = acceptEven.orElse(acceptNone).orElse(acceptOdd).andThen(uppercaseStr)

for i in 0...10 {
    println(combined.apply(i))
}
*/