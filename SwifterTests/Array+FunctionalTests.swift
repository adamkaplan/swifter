//
//  Array+FunctionalTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/2/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class Array_FunctionalTests: XCTestCase {

    func testCollect() -> () {
        let sample = [0, 1, 2, 3, 4, 5, 6, 7, 8]
        
        let acceptEven = PartialFunction<Int, Int> { (i: Int, _) in
            if i % 2 == 0 {
                return .Defined(i)
            } else {
                return .Undefined
            }
        }
        
        let acceptOdd = PartialFunction<Int, Int> { (i: Int, _) in
            if i % 2 != 0 {
                return .Defined(i)
            } else {
                return .Undefined
            }
        }
        
        assertArraysEqual(sample.collect(acceptEven), [0, 2, 4, 6, 8])
        assertArraysEqual(sample.collect(acceptOdd), [1, 3, 5, 7])
        assertArraysEqual(sample.filter(acceptOdd.isDefinedAt), sample.collect(acceptOdd))
        assertArraysEqual(sample.collect(acceptEven.orElse(acceptOdd)), sample)
        assertArraysEqual(sample.collect(acceptEven.andThen(acceptOdd)), [])
    }

}
