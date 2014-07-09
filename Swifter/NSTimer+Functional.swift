//
//  Timer.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/10/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

extension NSTimer {
    
    class SwifterTimerExecutor {
        
        let closure: ((NSTimer!) -> ())
        
        init(closure: ((NSTimer!) -> ())) {
            Log(.Timer, "SwifterTimerExecutor initialized")
            self.closure = closure
        }
        
        deinit {
            DLog(.Timer, "Deinitializing SwifterTimerExecutor")
        }
        
        @objc(executeClosure:) func executeClosure(timer: NSTimer!) {
            Log(.Timer, "Executing SwifterTimerExecturo.closure")
            self.closure(timer)
        }
    }
    
    class func scheduledTimerWithTimeInterval(interval: NSTimeInterval, userInfo: AnyObject!, repeats: Bool, closure: ((NSTimer!) -> ())) -> NSTimer! {
        return NSTimer.scheduledTimerWithTimeInterval(interval, target: SwifterTimerExecutor(closure), selector: "executeClosure:", userInfo: userInfo, repeats: repeats)
    }
    
}
