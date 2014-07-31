//
//  Try.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/23/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* This protocol is adopted by any entity that is to be encapsulated by Try.Failure. */
public protocol TryFailure {

    /* Performs some side effect when the Try.Failure is unwrapped (e.g., NSException.raise()) */
    func fail() -> ()

}

extension NSException : TryFailure {
    
    public func fail() -> () {
        self.raise()
    }
    
}

public class PredicateNotSatisfiedException : NSException {
    
    init() {
        super.init(name: "PredicateNotSatisfiedException", reason: nil, userInfo: nil)
    }
    
}

public class TryDidFailException : NSException {
    
    init() {
        super.init(name: "TryDidFailException", reason: nil, userInfo: nil)
    }
    
}

public class TryDidNotFailException : NSException {
    
    init() {
        super.init(name: "TryDidNotFailException", reason: nil, userInfo: nil)
    }
    
}

/* A Try<T> represents a successful computation of a T as a .Success(T),
 * or a failure to correctly compute the value as a .Failure(E). 
 * Try is implemented as an enum to allow easy construction, to mandate
 * pattern matching against both cases in switch statements, and because Try is
 * an immutable state. 
 * Try is used as an alternative to the exception try-catch paradigm; the user
 * is responsible for coding all possible exceptions as .Failures. */
public enum Try<T> : Printable { // TODO REFACTOR TO TRY<T,E>
    
    case Success([T]) // TODO REMOVE WORKAROUND [T] -> T
    case Failure(TryFailure)
    
    public var description: String {
    get {
        return self.fold({ _ in ".Success" }, { _ in ".Failure" })
    }
    }
    
    /* Applies success to a .Success(T) and failure to a .Failure(E). */
    public func fold<S>(success: T -> S, failure: TryFailure -> S) -> S {
        switch self {
        case .Success(let s):
            return success(s[0])
        case .Failure(let e):
            return failure(e)
        }
    }
    
    /* Returns whether this Try is a .Success(T). */
    public func isSuccess() -> Bool {
        return self.fold({ _ in true }, { _ in false })
    }
 
    /* Returns whether this Try is a .Failure(E). */
    public func isFailure() -> Bool {
        return self.fold({ _ in false }, { _ in true })
    }
    
    /* Converts this Try to some T if it is a .Success(T), or otherwise nil. */
    public func toOption() -> T? {
        return self.fold({ $0 }, { _ in nil })
    }
    
    /* Forcedly unwraps this Try, throwing the exception contained in .Failure(E). */
    public func unwrap() -> T {
        return self.fold({ $0 }, {
            ($0 as NSException).raise();
            return self.toOption()!
            })
    }
    
    /* Converts a .Success(T) to a Failure(PNSE) if p is not satisfied, or otherwise
     * propagates the Try. */
    public func filter(p: ((T) -> Bool)) -> Try<T> {
        return self.fold({ p($0) ? self : .Failure(PredicateNotSatisfiedException()) }, { _ in self })
    }
    
    /* Gets the value of this Try if it is a .Success(T), or otherwise defaultT. */
    public func getOrElse(defaultT: T) -> T {
        return self.fold({ $0 }, { _ in defaultT })
    }
    
    /* Returns this try if it is a .Success(T), or otherwise defaultTry. */
    public func orElse(defaultTry: Try<T>) -> Try<T> {
        return self.fold({ _ in self }, { _ in defaultTry })
    }

    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * propagates the .Failure(E). */
    public func map<S>(f: T -> S) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { .Failure($0) })
    }
    
    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * raises a TryDidFailException. */
    public func onSuccess<S>(f: T -> S) -> Try<S> {
        return self.fold({ .Success([f($0)]) }, { _ in .Failure(TryDidFailException()) })
    }

    /* Applies f to the value of this Try if it is a .Failure(E), or otherwise
    * raises a TryDidFailException. */
    public func onFailure<S>(f: TryFailure -> S) -> Try<S> {
        return self.fold({ _ in .Failure(TryDidNotFailException()) }, { .Success([f($0)]) })
    }
    
    /* Applies f to the value of this Try if it is a .Success(T), or otherwise
     * propagates the .Failure(E). */
    public func bind<S>(f: T -> Try<S>) -> Try<S> {
        return self.fold({ f($0) }, { .Failure($0) })
    }
    
    /* Returns this Try if it is a .Success(T), or otherwise attempts to recover
     * the .Failure(E) by applying pf. */
    public func recover(pf: PartialFunction<TryFailure,T>) -> Try<T> {
        return self.fold( { _ in self }, {
            if pf.isDefinedAt($0) {
                return .Success([pf.apply($0)!])
            } else {
                return self
            }
            })
    }
    
    public func toObject() -> TryObject<T> {
        return TryObject<T>(try: self)
    }
    
}

public class TryObject<T>  {
    
    private let tryEnum: Try<T>
    
    init(try: Try<T>) {
        self.tryEnum = try
    }
    
    public func toEnum() -> Try<T> {
        return self.tryEnum
    }
    
}
