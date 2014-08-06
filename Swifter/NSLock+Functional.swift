//
//  NSLock+Functional.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/14/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

extension NSLock {
    
    public func perform<T>(block: (() -> T)) -> T {
        self.lock()
        let result = block()
        self.unlock()
        return result
    }
    
}
