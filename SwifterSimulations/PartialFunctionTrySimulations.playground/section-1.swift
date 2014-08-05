// PartialFunctionTrySimulations.playground
// A demonstration of the PartialFunction<A,B> and Try<T> capabilities

import Foundation

//
// IMPLEMENTATION
//

public protocol TryFailure {
    
    /** Performs some side effect when the Try.Failure is unwrapped (e.g., NSException.raise()) */
    func fail() -> ()
    
}

extension NSException : TryFailure {
    
    public func fail() -> () {
        self.raise()
    }
    
}

public class PredicateNotSatisfiedException : TryFailure {
    
    public func fail() -> () {
        NSException(name: "PredicateNotSatisfiedException", reason: nil, userInfo: nil).raise()
    }
    
}

public class TryDidFailException : TryFailure {
    
    public func fail() -> () {
        NSException(name: "TryDidFailException", reason: nil, userInfo: nil).raise()
    }
    
}

public class TryDidNotFailException : TryFailure {
    
    public func fail() -> () {
        NSException(name: "TryDidNotFailException", reason: nil, userInfo: nil).raise()
    }
    
}

public enum Try<T> { // TODO REFACTOR TO TRY<T,E>
    
    case Success([T]) // TODO REMOVE WORKAROUND [T] -> T
    case Failure(TryFailure)
    
    /** Applies success to a .Success(T) and failure to a .Failure(E). */
    public func fold<S>(success: T -> S, failure: TryFailure -> S) -> S {
        switch self {
        case .Success(let s):
            return success(s[0])
        case .Failure(let e):
            return failure(e)
        }
    }
    
    /** Returns whether this Try is a .Success(T). */
    public func isSuccess() -> Bool {
        return self.fold({ _ in true }, { _ in false })
    }
    
    /** Returns whether this Try is a .Failure(E). */
    public func isFailure() -> Bool {
        return self.fold({ _ in false }, { _ in true })
    }
    
    /** Converts this Try to some T if it is a .Success(T), or otherwise nil. */
    public func toOption() -> T? {
        return self.fold({ $0 }, { _ in nil })
    }
    
    /** Forcedly unwraps this Try, throwing the exception contained in .Failure(E). */
    public func unwrap() -> T {
        return self.fold({ $0 }, {
            ($0 as NSException).raise();
            return self.toOption()!
        })
    }
    
    /** Optionally returns the TryFailure contained in this .Failure. */
    public func getFailure() -> TryFailure! {
        return self.fold({ _ in nil }, { $0 })
    }
    
    /** Converts a .Success(T) to a Failure(PNSE) if p is not satisfied, or otherwise
    propagates the Try. */
    public func filter(p: ((T) -> Bool)) -> Try<T> {
        return self.fold({ p($0) ? self : .Failure(PredicateNotSatisfiedException()) }, { _ in self })
    }
    
    /** Gets the value of this Try if it is a .Success(T), or otherwise defaultT. */
    public func getOrElse(defaultT: T) -> T {
        return self.fold({ $0 }, { _ in defaultT })
    }
    
    /** Returns this try if it is a .Success(T), or otherwise defaultTry. */
    public func orElse(defaultTry: Try<T>) -> Try<T> {
        return self.fold({ _ in self }, { _ in defaultTry })
    }
    
    /** Applies f to the value of this Try if it is a .Success(T), or otherwise
    propagates the .Failure(E). */
    public func map<S>(f: T -> S) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { .Failure($0) })
    }
    
    /** Applies f to the value of this Try if it is a .Success(T), or otherwise
    raises a TryDidFailException. */
    public func onSuccess<S>(f: T -> S) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { _ in .Failure(TryDidFailException()) })
    }
    
    /** Applies f to the value of this Try if it is a .Failure(E), or otherwise
    raises a TryDidFailException. */
    public func onFailure<S>(f: TryFailure -> S) -> Try<S> {
        return self.fold({ _ in .Failure(TryDidNotFailException()) }, { .Success([f($0)]) })
    }
    
    /** Applies f to the value of this Try if it is a .Success(T), or otherwise
    propagates the .Failure(E). */
    public func bind<S>(f: T -> Try<S>) -> Try<S> {
        return self.fold({ f($0) }, { .Failure($0) })
    }
    
    /** Returns this Try if it is a .Success(T), or otherwise attempts to recover
    the .Failure(E) by applying pf. */
    public func recover(pf: PartialFunction<TryFailure,T>) -> Try<T> {
        return self.fold( { _ in self }, {
            if pf.isDefinedAt($0) {
                return .Success([pf.apply($0)!])
            } else {
                return self
            }
        })
    }
    
}

extension Try : Printable {
    
    public var description: String {
        get {
            return self.fold({ _ in ".Success" }, { _ in ".Failure" })
        }
    }
    
}

extension Try : BooleanType {
    
    public var boolValue: Bool {
        get {
            return self.fold({ _ in true }, { _ in false })
        }
    }
    
}

// PartialFunction
public enum DefinedResult<Z> {
    case Defined(Z)
    case Undefined
}

public class UndefinedArgumentException : TryFailure {
    
    public func fail() -> () {
        NSException(name: "UndefinedArgumentException", reason: nil, userInfo: nil).raise()
    }
    
}

public class PartialFunction<A,B> {
    
    typealias PF = PartialFunction<A,B>
    typealias Z = B // The final return type, provided to be overriden
    typealias DefaultPF = PartialFunction<A,Z>
    
    private let applyOrCheck: (A, Bool) -> DefinedResult<Z>
    
    init(f: (A, Bool) -> DefinedResult<Z>) {
        self.applyOrCheck = f
    }
    
    /** Optionally applies this PartialFunction to `a` if it is in the domain. */
    public func apply(a: A) -> B? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return p
        case .Undefined:
            return nil
        }
    }
    
    /** Applies this PartialFunction to `a`, and in the case that 'a' is undefined
    for the function, applies defaultPF to `a`. */
    public func applyOrElse(a: A, defaultPF: DefaultPF) -> Z? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return p
        default:
            return defaultPF.apply(a)
        }
    }
    
    /** Attempts to apply this PartialFunction to `a` and returns a Try of the attempt. */
    public func tryApply(a: A) -> Try<B> {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return .Success([p])
        case .Undefined:
            return .Failure(UndefinedArgumentException())
        }
    }
    
    /** Returns true if this PartialFunction can be applied to `a` */
    public func isDefinedAt(a: A) -> Bool {
        switch applyOrCheck(a, true) {
        case .Defined(_):
            return true
        case .Undefined:
            return false
        }
    }
    
    /** Returns a PartialFunction that first applies this function, or else applies otherPF. */
    public func orElse(otherPF: PF) -> PF {
        return OrElse(f1: self, f2: otherPF)
    }
    
    /** Returns a PartialFunction that first applies this function, and if successful,
    next applies nextPF. */
    public func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return AndThen<A,B,C>(f1: self, f2: nextPF)
    }
    
}

private class OrElse<A,B> : PartialFunction<A,B> {
    
    let f1, f2: PF
    
    init(f1: PF, f2: PF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( {
            [unowned self] (a, checkOnly) in
            let result1 = self.f1.applyOrCheck(a, checkOnly)
            switch result1 {
            case .Defined(_):
                return result1
            case .Undefined:
                return self.f2.applyOrCheck(a, checkOnly)
            }
        })
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return f1.isDefinedAt(a) || f2.isDefinedAt(a)
    }
    
    override func orElse(f3: PF) -> PF {
        return OrElse(f1: f1, f2: f2.orElse(f3))
    }
    
    override func applyOrElse(a: A, defaultPF: PF) -> B? {
        switch f1.applyOrCheck(a, false) {
        case .Defined(let result1):
            return result1
        default:
            return f2.applyOrElse(a, defaultPF: defaultPF)
        }
    }
    
    override func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return OrElse<A,C>(
            f1: AndThen<A,B,C>(f1: f1, f2: nextPF),
            f2: AndThen<A,B,C>(f1: f2, f2: nextPF))
    }
}

private class AndThen<A,B,C> : PartialFunction<A,C> {
    
    typealias NextPF = PartialFunction<B,C>
    typealias Z = C
    
    let f1: PartialFunction<A,B>
    let f2: NextPF
    
    init(f1: PartialFunction<A,B>, f2: NextPF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( {
            [unowned self] (a, checkOnly) in
            let result1 = self.f1.applyOrCheck(a, checkOnly)
            switch result1 {
            case .Defined(let r1):
                let result2 = f2.applyOrCheck(r1, checkOnly)
                switch result2 {
                case .Defined(_):
                    return result2
                case .Undefined:
                    return .Undefined
                }
            case .Undefined:
                return .Undefined
            }
        })
    }
    
    override func applyOrElse(a: A, defaultPF: DefaultPF) -> Z? {
        switch self.applyOrCheck(a, false) {
        case .Defined(let result):
            return result
        case .Undefined:
            return defaultPF.apply(a)
        }
    }
}

infix operator  >< {precedence 255}
func >< <A,B> (domain: (a: A) -> Bool, body: (a: A) -> B) -> PartialFunction<A,B> {
    return PartialFunction<A,B>( {
        (a: A, _) in
        if domain(a: a) {
            return .Defined(body(a: a))
        } else {
            return .Undefined
        }
    })
}

infix operator  => {precedence 128 associativity left}
func => <A,B,C> (pf: PartialFunction<A, B>, nextPF: PartialFunction<B,C>) -> PartialFunction<A,C>{
    return pf.andThen(nextPF)
}

infix operator  | {precedence 64 associativity left}
func | <A,B> (pf: PartialFunction<A,B>, otherPF: PartialFunction<A,B>) -> PartialFunction<A,B> {
    return pf.orElse(otherPF)
}

func match<A,B>(value: A, patternMatch: () -> PartialFunction<A,B>) -> B? {
    return patternMatch().apply(value)
}

extension Array {
    
    /* Returns an array of all defined elements returned from the PartialFunction. */
    public func collect<B>(pf: PartialFunction<T,B>) -> Array<B> {
        return self.filter(pf.isDefinedAt).map { pf.apply($0)! }
    }
    
}

//
// DEMONSTRATION
//

// PartialFunction and custom operators
infix operator  /~ {}
func /~ (num: Int, denom: Int) -> Int? {
    let divide = PartialFunction<(Int, Int), Int>( {
        (ints: (Int, Int), _) in
        let (num, denom) = ints
        if denom != 0 {
            return .Defined(num/denom)
        } else {
            return .Undefined
        }
    })
    
    return divide.apply(num, denom)
}

let sample = [0, 1, 2, 3, 4, 5, 6, 7, 8]

let acceptEven = PartialFunction<Int, Int> {
    (i: Int, _) in
    if i % 2 == 0 {
        return .Defined(i)
    } else {
        return .Undefined
    }
}

sample.filter(acceptEven.isDefinedAt)
sample.collect(acceptEven)

let acceptOdd = PartialFunction<Int, Int> {
    (i: Int, _) in
    if i % 2 != 0 {
        return .Defined(i)
    } else {
        return .Undefined
    }
}

sample.filter(acceptOdd.isDefinedAt)

let acceptNaturalNumbers = acceptEven.orElse(acceptOdd)

sample.filter(acceptNaturalNumbers.isDefinedAt)

let acceptNoNaturalNumbers = acceptEven.andThen(acceptOdd);

sample.filter(acceptNoNaturalNumbers.isDefinedAt)
sample.collect(acceptNoNaturalNumbers)

6 /~ 00
6 /~ 05
6 /~ 15

// Pattern matching
// match with
// | n when n % 2 == 0 && n <= 10 -> Some +n
// | n when n % 2 != 0 && n <= 10 -> Some -n
// | _ -> None
let patt1: PartialFunction<Int,Int> = { $0 % 2 == 0 && $0 <= 10 } >< { +$0 }
let patt2: PartialFunction<Int,Int> = { $0 % 2 != 0 && $0 <= 10 } >< { -$0 }

match(05) { patt1 | patt2 }
match(04) { patt1 | patt2 }
match(10) { patt1 | patt2 }
match(11) { patt1 | patt2 }

let patt3: PartialFunction<Any,String> = { $0 is String } >< { $0 as String }
let patt4: PartialFunction<Any,String> = { $0 is Int } >< { "\($0)" }
let patt5: PartialFunction<Any,String> = { $0 is Bool } >< { $0 as Bool ? "true" : "false" }

class NoMatch : TryFailure {
    
    func fail() -> () {
        NSException(name: "NoMatch", reason: "There was not a match in the pattern", userInfo: nil).raise()
    }
    
}

let patt6: PartialFunction<Int,Try<Int>> = { $0 % 2 != 0 } >< { .Success([$0]) }
let patt7: PartialFunction<Int,Try<Int>> = { $0 % 2 == 0 && $0 < 10 } >< { .Success([$0 + 1]) }
let patt8: PartialFunction<Int,Try<Int>> = { _ in true } >< { _ in .Failure(NoMatch()) }

let patt9: PartialFunction<Try<Int>,Int> = { $0.isSuccess() } >< { $0.unwrap() }
let patt10: PartialFunction<Try<Int>,TryFailure> = { $0.isFailure() } >< { $0.getFailure() }
let patt11: PartialFunction<TryFailure,Int> = { $0 is PredicateNotSatisfiedException } >< { _ in 100 }
let patt12: PartialFunction<TryFailure,Int> = { $0 is NoMatch } >< { _ in 200 }
let patt13: PartialFunction<TryFailure,Int> = { _ in true } >< { _ in 300 }

let matchInt = {
    match( match($0) { patt6 | patt7 | patt8 }! ) {
        patt9 | patt10 => (patt11 | patt12 | patt13)
    }!
}

matchInt(4) // even -> 4 + 1 = 5
matchInt(5) // odd -> 5
matchInt(10) // NoMatch -> 200

// Try and failure handling
enum Exceptions :  TryFailure {
    case NotParseableAsInt
    case IndexOutOfBounds
    
    func fail() -> () {}
}

let f1: String -> Try<Int> = {
    if let i = $0.toInt() {
        return .Success([i])
    } else {
        return .Failure(Exceptions.NotParseableAsInt)
    }
}
let f2: Int -> Try<[Int]> = {
    let arr = [10, 45]
    if $0 >= 0 && $0 < arr.count {
        return .Success([[arr[$0]]])
    } else {
        return .Failure(Exceptions.IndexOutOfBounds)
    }
}
let f3: [Int] -> String = {
    return "\($0[0])"
}
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
