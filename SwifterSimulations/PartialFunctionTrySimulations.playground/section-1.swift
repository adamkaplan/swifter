// PartialFunctionTrySimulations.playground
// A demonstration of the PartialFunction<A,B> and Try<T> capabilities

import Foundation

// Implementation
// Try
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

infix operator  ~~ {precedence 128}
func ~~ <T> (value: Any, type: T.Type) -> Bool {
    return (value as? T) != nil
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

// Simulation
// PartialFunction, Optional, Custom Operators
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

let patt3: PartialFunction<Any,String> = { $0 ~~ String.self } >< { $0 as String }
let patt4: PartialFunction<Any,String> = { $0 ~~ Int.self } >< { "\($0)" }
let patt5: PartialFunction<Any,String> = { $0 ~~ Bool.self } >< { $0 as Bool ? "true" : "false" }

func toString(elem: Any) -> String {
    return match(elem) {
        patt3 |
        patt4 |
        patt5 }!
}
// Include: apply, andThen, orElse, =>, |, match, ><, ~~ Class.self

// Pattern matching
// Exception paradigm switch
// Collection
// Try + PatternMatch failures ~~
