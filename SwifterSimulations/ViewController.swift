//
//  ViewController.swift
//  SwifterSimulations
//
//  Created by Daniel Hanggi on 8/1/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let future1 = Future<UIView>(UIView(frame: self.view.frame))
        let future2 = future1 >>| {
            sleep(5)
            return $0
        } >>| {
            (view: UIView) -> UInt32 in
            self.view.addSubview(view)
            view.backgroundColor = UIColor.purpleColor()
            return 5
        }
        future2 >>| {
            (i: UInt32) -> () in
            sleep(i)
            _ = (self.view.subviews as [UIView]).map { $0.backgroundColor = UIColor.greenColor() }
        }
        future2 >>| {
            sleep($0)
            let frame = self.view.frame
            let (x, y) = (frame.origin.x + frame.size.width/4, frame.origin.y + frame.size.height/4)
            let (w, h) = (frame.size.width/2, frame.size.height/2)
            self.view.addSubview(UILabel(frame: CGRect(x: x, y: y, width: w, height: h)))
        } >>| {
            () -> () in
            let subviews: [UIView] = self.view.subviews.map { $0 as UIView }
            let labels: List<UILabel> = (^subviews).filter { $0 is UILabel }.map { $0 as UILabel }
            labels.iter { $0.text = "Swifter Demo"; $0.textAlignment = .Center }
        }
        
        self.view.backgroundColor = UIColor.blueColor()
    }

}
