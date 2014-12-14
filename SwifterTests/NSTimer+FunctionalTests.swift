//
//  TimerTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/10/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class Timer_FunctionalTests: XCTestCase {

    func testScheduledTimerWithTimeInterval() -> () {
        var onComplete = false
        let timer = NSTimer.scheduledTimerWithTimeInterval(5.0, userInfo: nil, repeats: true) {
            _ in
            onComplete = true
        }
        while !onComplete {
            NSRunLoop.mainRunLoop().runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
    }
 
    func testHasFired() -> () {
        let timer = NSTimer.scheduledTimerWithTimeInterval(2, userInfo: nil, repeats: true) { _ in () }
        XCTAssertFalse(timer.hasFired())
        sleep(2)
        XCTAssertTrue(timer.hasFired())
    }
    
}
