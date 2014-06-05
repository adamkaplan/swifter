//
//  PartialFunction.swift
//  Swifter
//
//  Created by Adam Kaplan on 6/3/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

enum MatchResult {
    case Match(Any)
    case NoMatch
}

/* Todo: make this private. Apple has promised Swift will get access modifiers */
class OrElse<A,B> : PartialFunction<A,B> {
    
    let f1, f2: PF
    
    init(f1: PF, f2: PF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
            let result = self.f1.applyOrCheck(a, checkOnly)
            switch result {
            case .NoMatch:
                return self.f2.applyOrCheck(a, checkOnly)
            case .Match(_):
                return result
            }
            })
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return f1.isDefinedAt(a) || f2.isDefinedAt(a)
    }
    
    override func orElse(f3: PF) -> PF {
        return OrElse(f1: f1, f2: f2.orElse(f3))
    }
    
    override func applyOrElse(a: A, defaultFun: PF) -> B? {
        switch f1.applyOrCheck(a, false) {
        case .Match(let r1 as B):
            return r1
        default:
            return f2.applyOrElse(a, defaultFun: defaultFun)
        }
    }
    
    override func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return OrElse<A,C>(
            f1: AndThen<A,B,C>(f1: f1, f2: nextPF),
            f2: AndThen<A,B,C>(f1: f2, f2: nextPF))
    }
}


/* Todo: make this private. Apple has promised Swift will get access modifiers */
class AndThen<A,B,C> : PartialFunction<A,C> {
    
    typealias NextPF = PartialFunction<B,C>
    
    typealias Z = C
    
    let f1: PartialFunction<A,B>
    
    let f2: NextPF
    
    init(f1: PartialFunction<A,B>, f2: NextPF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
            let result = self.f1.applyOrCheck(a, checkOnly)
            switch result {
            case .Match(let r as B):
                let nextResult = f2.applyOrCheck(r, checkOnly)
                switch nextResult {
                case .NoMatch:
                    return .NoMatch
                case .Match(_):
                    return nextResult
                }
            default:
                return .NoMatch
            }
            })
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return f1.isDefinedAt(a)
    }
    
    override func applyOrElse(a: A, defaultFun: DefaultPF) -> Z? {
        switch f1.applyOrCheck(a, false) {
        case .Match(let r1 as B):
            return f2.apply(r1)
        default:
            return defaultFun.apply(a)
        }
    }
}

class PartialFunction<A,B> {
    
    typealias PF = PartialFunction<A,B>
    
    typealias Z = B // this type is the final return type, provided to be overriden
    
    typealias DefaultPF = PartialFunction<A,Z>
    
    let applyOrCheck: (A, Bool) -> MatchResult
    
    init(f: (A, Bool) -> MatchResult) {
        self.applyOrCheck = f
    }
    
    func apply(a: A) -> B? {
        switch applyOrCheck(a, false) {
        case .Match(let p as B):
            //println("apply: match")
            return p
        case .NoMatch:
            //println("apply: no match")
            return nil
        default:
            //println("apply: bad stuff")
            return nil
        }
    }
    
    /* Apply this PartialFunction to `a` if a is defined for it.
    Otherwise, applies defaultFun to `a` */
    func applyOrElse(a: A, defaultFun: DefaultPF) -> Z? {
        switch applyOrCheck(a, false) {
        case .Match(let p as B):
            return p
        default:
            return defaultFun.apply(a)
        }
    }
    
    /* Returns true if this PartialFunction can be applied to `a` */
    func isDefinedAt(a: A) -> Bool {
        switch applyOrCheck(a, true) {
        case .Match(_):
            return true
        case .NoMatch:
            return false
        }
    }
    
    func orElse(that: PF) -> PF {
        return OrElse(f1: self, f2: that)
    }
    
    func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return AndThen<A,B,C>(f1: self, f2: nextPF)
    }
}