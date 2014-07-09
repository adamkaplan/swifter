//
//  Try.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/23/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

class PredicateNotSatisfiedException : NSException {
    
    init() {
        super.init(name: "PredicateNotSatisfiedException", reason: nil, userInfo: nil)
    }
    
}

class TryDidFailException : NSException {
    
    init() {
        super.init(name: "TryDidFailException", reason: nil, userInfo: nil)
    }
    
}

class TryDidNotFailException : NSException {
    
    init() {
        super.init(name: "TryDidNotFailException", reason: nil, userInfo: nil)
    }
    
}

/* A Try<T> represents a successful computation of a T as a .Success(T),
 * or a failure to correctly compute the value as a .Failure(E). */
enum Try<T> : Printable {
    
    typealias E = NSException
    typealias PNSE = PredicateNotSatisfiedException
    typealias TDFE = TryDidFailException
    typealias TDNFE = TryDidNotFailException
    
    case Success([T])
    case Failure(E)
    
    var description: String {
    get {
        return self.fold({ _ in ".Success" }, { _ in ".Failure" })
    }
    }
    
    /* Applies success to a .Success(T) and failure to a .Failure(E). */
    func fold<S>(success: ((T) -> S), failure: ((E) -> S)) -> S {
        switch self {
        case .Success(let s):
            return success(s[0])
        case .Failure(let e):
            return failure(e)
        }
    }
    
    /* Returns whether this Try is a .Success(T). */
    func isSuccess() -> Bool {
        return self.fold({ _ in true }, { _ in false })
    }
 
    /* Returns whether this Try is a .Failure(E). */
    func isFailure() -> Bool {
        return self.fold({ _ in false }, { _ in true })
    }
    
    /* Converts this Try to some T if it is a .Success(T), or otherwise nil. */
    func toOption() -> T? {
        return self.fold({ $0 }, { _ in nil })
    }
    
    /* Forcedly unwraps this Try, throwing the exception contained in .Failure(E). */
    func unwrap() -> T {
        return self.fold({ $0 }, {
            ($0 as NSException).raise();
            return self.toOption()!
            })
    }
    
    /* Converts a .Success(T) to a Failure(PNSE) if p is not satisfied, or otherwise
     * propagates the Try. */
    func filter(p: ((T) -> Bool)) -> Try<T> {
        return self.fold({ p($0) ? self : .Failure(PNSE()) }, { _ in self })
    }
    
    /* Gets the value of this Try if it is a .Success(T), or otherwise defaultT. */
    func getOrElse(defaultT: T) -> T {
        return self.fold({ $0 }, { _ in defaultT })
    }
    
    /* Returns this try if it is a .Success(T), or otherwise defaultTry. */
    func orElse(defaultTry: Try<T>) -> Try<T> {
        return self.fold({ _ in self }, { _ in defaultTry })
    }

    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * propagates the .Failure(E). */
    func map<S>(f: ((T) -> S)) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { .Failure($0) })
    }
    
    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * raises a TryDidFailException. */
    func onSuccess<S>(f: ((T) -> S)) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { _ in .Failure(TDFE()) })
    }

    /* Applies f to the value of this Try if it is a .Failure(E), or otherwise
    * raises a TryDidFailException. */
    func onFailure<S>(f: ((E) -> S)) -> Try<S> {
        return self.fold({ _ in .Failure(TDNFE()) }, { .Success([f($0)]) })
    }
    
    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * propagates the .Failure(E). */
    func bind<S>(f: ((T) -> Try<S>)) -> Try<S> {
        return self.fold({ f($0) }, { .Failure($0) })
    }
    
    /* Returns this Try if it is a .Success(T), or otherwise attempts to recover
     * the .Failure(E) by applying pf. */
    func recover(pf: PartialFunction<E,T>) -> Try<T> {
        return self.fold({ _ in self }, {
            if pf.isDefinedAt($0) {
                return .Success([pf.apply($0)!])
            } else {
                return self
            }
            })
    }
    
    func toObject() -> TryObject<T> {
        return TryObject<T>(try: self)
    }
    
}

class TryObject<T> : Printable {
    
    var description: String {
    get {
        return self.tryEnum.description
    }
    }
    
    let tryEnum: Try<T>
    
    init(try: Try<T>) {
        self.tryEnum = try
    }
    
    func toEnum() -> Try<T> {
        return self.tryEnum
    }
    
}
