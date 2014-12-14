//
//  NSLock+FunctionalTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/15/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class LockTester {
    
    var _counter: Int = 0
    var counter: Int {
    get {
        return self._counter
    }
    set(newValue) {
        self._counter = newValue
    }
    }
    
    var _status: Int = 0
    var status: Int {
    get {
        return self._status
    }
    set(newValue) {
        self.counter++
        self._status = newValue
    }
    }
    
}

class NSLock_FunctionalTests: XCTestCase {

    func testPerform() {
        let lock = NSLock()
        let queue1 = NSOperationQueue()
        let queue2 = NSOperationQueue()
        let queue3 = NSOperationQueue()
        let maxStatus = 100
        
        // Unlocked (>1:1 correspondence between counter and status)
        let unlockedTester = LockTester()
        let unlockedBlock: () -> () = {
            while unlockedTester.status < maxStatus {
                unlockedTester.status++
            }
        }
        queue1.addOperationWithBlock(unlockedBlock)
        queue2.addOperationWithBlock(unlockedBlock)
        queue3.addOperationWithBlock(unlockedBlock)
        queue1.waitUntilAllOperationsAreFinished()
        queue2.waitUntilAllOperationsAreFinished()
        queue3.waitUntilAllOperationsAreFinished()
        XCTAssert(unlockedTester.counter >= maxStatus)
        
        // Locked (1:1 correspondence between counter and status)
        let lockedTester = LockTester()
        let lockedBlock: () -> () = {
            lock.perform {
                while lockedTester.status < maxStatus {
                    lockedTester.status++
                }
            }
        }
        queue1.addOperationWithBlock(lockedBlock)
        queue2.addOperationWithBlock(lockedBlock)
        queue3.addOperationWithBlock(lockedBlock)
        queue1.waitUntilAllOperationsAreFinished()
        queue2.waitUntilAllOperationsAreFinished()
        queue3.waitUntilAllOperationsAreFinished()
        XCTAssert(lockedTester.counter == maxStatus)
    }

}
