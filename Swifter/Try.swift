//
//  Try.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/23/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

enum Try<T> {
    
    typealias E = NSException
    
    case Success(T)
    case Failure(E)
    
    /* Applies success to a .Success(T) and failure to a .Failure(E). */
    func fold<S>(success: ((T) -> S), failure: ((E) -> S)) -> S {
        switch self {
        case .Success(let s):
            return success(s)
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
    
    /* Converts a .Success(T) to a Failure(E) if p is not satisfied, or otherwise
     * propagates the Try. */
    func filter(p: ((T) -> Bool)) -> Try<T> {
        return self.fold({ p($0) ? .Success($0) : .Failure(NSException()) }, { .Failure($0) })
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
        return self.fold({ .Success(f($0)) }, { .Failure($0) })
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
                return .Success(pf.apply($0)!)
            } else {
                return self
            }
            })
    }
    
}
