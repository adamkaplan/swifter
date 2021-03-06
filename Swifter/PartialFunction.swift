//
//  PartialFunction.swift
//  Swifter
//
//  Created by Adam Kaplan on 6/3/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

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
    
    deinit {
        DLog(.PartialFunction, "Deinitializing PartialFunction")
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
    
    let _f1, _f2: PF
    
    init(f1: PF, f2: PF) {
        _f1 = f1
        _f2 = f2
        
        super.init( {
            (a, checkOnly) in
            let result1 = f1.applyOrCheck(a, checkOnly)
            switch result1 {
            case .Defined(_):
                return result1
            case .Undefined:
                return f2.applyOrCheck(a, checkOnly)
            }
        })
    }
    
    deinit {
        DLog(.PartialFunction, "Deinitializing OrElse")
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return _f1.isDefinedAt(a) || _f2.isDefinedAt(a)
    }
    
    override func orElse(f3: PF) -> PF {
        return OrElse(f1: _f1, f2: _f2.orElse(f3))
    }
    
    override func applyOrElse(a: A, defaultPF: PF) -> B? {
        switch _f1.applyOrCheck(a, false) {
        case .Defined(let result1):
            return result1
        default:
            return _f2.applyOrElse(a, defaultPF: defaultPF)
        }
    }
    
    override func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return OrElse<A,C>(
            f1: AndThen<A,B,C>(f1: _f1, f2: nextPF),
            f2: AndThen<A,B,C>(f1: _f2, f2: nextPF))
    }
}

private class AndThen<A,B,C> : PartialFunction<A,C> {
    
    typealias NextPF = PartialFunction<B,C>
    typealias Z = C
    
    let _f1: PartialFunction<A,B>
    let _f2: NextPF
    
    init(f1: PartialFunction<A,B>, f2: NextPF) {
        _f1 = f1
        _f2 = f2
        
        super.init( {
            (a, checkOnly) in
            let result1 = f1.applyOrCheck(a, checkOnly)
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
    
    deinit {
        DLog(.PartialFunction, "Deinitializing AndThen")
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

/* Creates a non-side-effect PartialFunction from body for a specific domain. */
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

/** Joins two PartialFunctions via PartialFunction.andThen(). */
infix operator  => {precedence 128 associativity left}
func => <A,B,C> (pf: PartialFunction<A, B>, nextPF: PartialFunction<B,C>) -> PartialFunction<A,C>{
    return pf.andThen(nextPF)
}

/** Joins two PartialFunctions via PartialFunction.orElse(). */
infix operator  | {precedence 64 associativity left}
func | <A,B> (pf: PartialFunction<A,B>, otherPF: PartialFunction<A,B>) -> PartialFunction<A,B> {
    return pf.orElse(otherPF)
}

/** Matches the value with the PartialFunction.
    Example usage:
        match(5) {
            { $0 ~~ String.self } =|= { "Kitty says " + $0 }
            { $0 ~~ Int.self } =|= { "This is an integer: \($0)" }
        } // returns "This is an integer: 5" */
func match<A,B>(value: A, patternMatch: () -> PartialFunction<A,B>) -> B? {
    return patternMatch().apply(value)
}
