//
//  PersistentDataStructure.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/16/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

// This file is dedicated to created a framework for implementation of immutable,
// persistent data structures. It will be based on the algorithm designed by Sleator,
// Tarjan, et al. This algorithm and the PersistentData class are in use by List,
// but is currently solely implemented in that class.
//
// The algorithm is based on each node of data being contained within a 'modification box'.
// Each node contains an original element, stored at initialization, and can optionally
// contain a modification made for some newer version of the data structure. When traversing 
// a node, a data structure will use its overall version to choose the correct datum stored 
// in the node. If a third change is made to a node, the node is copied, and the third datum
// is stored as the first datum in the new node. New versions and nodes are passed
// through the data structure, updating references, until the end is reached, creating a new 
// version of the overall data structure.

import Foundation

/** PersistentData is the 'modification box' that stores the immutable data for
    a particular data structure. */
internal class PersistentData<T> {
    
    typealias Version = NSDate
    
    let fstValue: T
    
    var version: Version?
    var sndValue: T!
    
    init(_ fstValue: T) {
        self.fstValue = fstValue
    }
    
    func get(version: Version) -> T {
        if self.version != nil {
            switch self.version!.compare(version) {
            case .OrderedDescending:
                return self.fstValue
            case .OrderedSame, .OrderedAscending:
                return self.sndValue
            }
        } else {
            return self.fstValue
        }
    }
    
    func set(sndValue: T) -> PersistentData<T>? {
        if self.version != nil {
            return PersistentData<T>(sndValue)
        } else {
            self.version = Version()
            self.sndValue = sndValue
            return nil
        }
    }
    
}
