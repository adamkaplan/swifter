//
//  TimerTests.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/10/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import XCTest

class Timer_FunctionalTests: XCTestCase {

    func test() -> () {
        var onComplete: Bool = false
        let timer = NSTimer.scheduledTimerWithTimeInterval(5.0, userInfo: nil, repeats: true, closure: {
            _ in
            onComplete = true
            })
        while !onComplete {
            mainRunLoop.runMode(NSDefaultRunLoopMode, beforeDate: NSDate(timeIntervalSinceNow: 0))
        }
    }
    
}
