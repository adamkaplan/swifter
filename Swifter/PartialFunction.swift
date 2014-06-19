//
//  PartialFunction.swift
//  Swifter
//
//  Created by Adam Kaplan on 6/3/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

enum DefinedResult<Z> {
    case Defined(Z) // Defined(A,Z)
    case Undefined  // Undefined(A)
}

@objc class PartialFunction<A,B> {
    
    typealias PF = PartialFunction<A,B>
    
    typealias Z = B // The final return type, provided to be overriden
    
    typealias DefaultPF = PartialFunction<A,Z>
    
    let applyOrCheck: (A, Bool) -> DefinedResult<Z>
    
    init(f: (A, Bool) -> DefinedResult<Z>) {
        self.applyOrCheck = f
    }
    
    func apply(a: A) -> B? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return p
        case .Undefined:
            return nil
        }
    }
    
    /* Applies this PartialFunction to `a`, and in the case that 'a' is undefined
     * for the function, applies defaultPF to `a`. */
    func applyOrElse(a: A, defaultPF: DefaultPF) -> Z? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return p
        default:
            return defaultPF.apply(a)
        }
    }
    
    /* Returns true if this PartialFunction can be applied to `a` */
    func isDefinedAt(a: A) -> Bool {
        switch applyOrCheck(a, true) {
        case .Defined(_):
            return true
        case .Undefined:
            return false
        }
    }
    
    func orElse(otherPF: PF) -> PF {
        return OrElse(f1: self, f2: otherPF)
    }
    
    func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return AndThen<A,B,C>(f1: self, f2: nextPF)
    }
    
//    // class constants are not yet available with generic classes
//    class let null: PartialFunction<Any,Any> = PartialFunction( { _ in .Undefined } )
//    class let iden: PartialFunction<A,A> = PartialFunction( { .Defined($0.0) } )
}

/* TODO: make this private. Apple has promised Swift will get access modifiers */
class OrElse<A,B> : PartialFunction<A,B> {
    
    let f1, f2: PF
    
    init(f1: PF, f2: PF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
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

/* TODO: make this private. Apple has promised Swift will get access modifiers */
class AndThen<A,B,C> : PartialFunction<A,C> {
    
    typealias NextPF = PartialFunction<B,C>
    
    typealias Z = C
    
    let f1: PartialFunction<A,B>
    
    let f2: NextPF
    
    init(f1: PartialFunction<A,B>, f2: NextPF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
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

/* Creates a PartialFunction from body for a specific domain. */
operator infix =|= {precedence 255}
@infix func =|= <A,B> (domain: ((a: A) -> Bool), body: ((a: A) -> B)) -> PartialFunction<A,B> {
    return PartialFunction<A,B>( { (a: A, _) in
        if domain(a:a) {
            return .Defined(body(a: a))
        } else {
            return .Undefined
        }
        })
}

/* Joins two PartialFunctions via PartialFunction.andThen(). */
operator infix => {precedence 128 associativity left}
@infix func => <A,B,C> (pf: PartialFunction<A, B>, nextPF: PartialFunction<B,C>) -> PartialFunction<A,C>{
    return pf.andThen(nextPF)
}

/* Joins two PartialFunctions via PartialFunction.orElse(). */
operator infix | {precedence 64 associativity left}
@infix func | <A,B> (pf: PartialFunction<A,B>, otherPF: PartialFunction<A,B>) -> PartialFunction<A,B> {
    return pf.orElse(otherPF)
}

/* Applies a value to the PartialFunction. */
operator infix ~|> {precedence 32}
@infix func ~|> <A,B> (value: A, pf: PartialFunction<A,B>) -> B? {
    return pf.apply(value)
}
