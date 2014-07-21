////
////  PersistentDataStructure.swift
////  Swifter
////
////  Created by Daniel Hanggi on 7/16/14.
////  Copyright (c) 2014 Yahoo!. All rights reserved.
////
//
//import Foundation
//
///* A generic, functional, persistent data structure framework based on the algorithm
// * designed by Sleator, Tarjan, et al. */
//class PersistentData<T> {
//    
//    typealias Timestamp = NSDate
//    
//    let fstValue: T!
//    var timestamp: Timestamp?
//    var sndValue: T!
//    
//    init(_ fstValue: T) {
//        self.fstValue = fstValue
//    }
//    
//    func get(timestamp: Timestamp) -> T {
//        if let comparison = self.timestamp?.compare(timestamp) {
//            switch comparison {
//            case .OrderedDescending, .OrderedSame:
//                return self.sndValue
//            case .OrderedAscending:
//                return self.fstValue
//            }
//        } else {
//            return self.fstValue
//        }
//    }
//    
//    func set(sndValue: T, timestamp: Timestamp) -> () {
//        self.timestamp = timestamp
//        self.sndValue = sndValue
//    }
//    
//    func isModified() -> Bool {
//        return self.timestamp ? true : false
//    }
//    
//}
//
//class PersistentDataStructure<T> {
//    
//    typealias PDSImpl = PersistentDataStructure<T>
//    typealias Timestamp = NSTimeInterval
//    
//    let timestamp: Timestamp!
//    let _data: PersistentData<T>!
//    
//}
//
//protocol Persistent {
//    
//    typealias Data
//    
//}
//
//class List<T> : PersistentDataStructure<T>, Persistent {
//    
//    typealias Data = Int
//    
//}
//
//class Nil<T> : List<T> {
//    
//    typealias Data = ()
//
//}
//
//class Cons<T>: List<T> {
//    
//    typealias Data = (T, List<T>)
//
//}
