//
//  Array+Functional.swift
//  Swifter
//
//  Created by Daniel Hanggi on 6/18/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

extension Array {
    
    /** Returns an array of all defined elements returned from the PartialFunction. */
    internal func collect<B>(pf: PartialFunction<T,B>) -> Array<B> {
        return self.filter(pf.isDefinedAt).map { pf.apply($0)! }
    }
    
}
