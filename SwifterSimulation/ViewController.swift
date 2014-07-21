//
//  ViewController.swift
//  SwifterSimulation
//
//  Created by Daniel Hanggi on 7/15/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSTimer.scheduledTimerWithTimeInterval(10, userInfo: self, repeats: true, closure: {
            _ in
            self.view.subviews.map {
                (v: AnyObject) -> AnyObject in
                if let label = v as? UILabel {
                    label.removeFromSuperview()
                }
                return v
            }
            self.testFuture()
            })
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    func testFuture() -> () {
        self.view.backgroundColor = UIColor.whiteColor()
        let label = UILabel(frame:self.view.frame)
        label.textAlignment = .Center
        self.view.addSubview(label)
        self.view.autoresizesSubviews = true
        label.autoresizingMask = UIViewAutoresizing.FlexibleBottomMargin | .FlexibleHeight | .FlexibleWidth
        let future1: Future<Int> = Future<Int>(value: 0)
        let future2: Future<Int> = future1.map {
            var i: Int = $0
            do { i++ } while i < Int.max
            return i
        }
        future2.onComplete( { _ in true } =|= {
            (try: Try<Int>) -> String in
            NSOperationQueue.mainQueue().addOperationWithBlock {
                label.text = "Finished with \(try.unwrap())"
                self.view.backgroundColor = UIColor.purpleColor()
                self.view.setNeedsDisplay()
            }
            return "Done"
            })
    }

}

