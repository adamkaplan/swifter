//
//  Tree.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/22/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A generic, immutable binary tree. */
class Tree<T> : LogicValue {
    
    func getLogicValue() -> Bool  {
        return false
    }
    
    func fold<L>(leafValue: L, f: (L,T,L) -> L) -> L {
        return leafValue
    }
    
    func node() -> T? {
        return nil
    }

    func isEmpty() -> Bool {
        return self.fold(true) {
            (_, _, _) -> Bool in
            return false
        }
    }
    
    func map<S>(f: (T) -> S) -> Tree<S> {
        return self.fold(Leaf()) {
            (left: Tree<S>, node: T, right: Tree<S>) -> Tree<S> in
            return Node(left, f(node), right)
        }
    }
    
    func contains(value: T, eq: ((T,T) -> Bool)) -> Bool {
        return self.fold(false) {
            (left: Bool, node: T, right: Bool) -> Bool in
            return left || eq(node, value) || right
        }
    }
    
    func count() -> Int {
        return self.fold(0) {
            (left: Int, _, right: Int) -> Int in
            return left + 1 + right
        }
    }
    
    func equal(other: Tree<T>, eq: (T,T) -> Bool) -> Bool {
        return other.isEmpty()
    }
    
    func leftSubtree() -> Tree<T>? {
        return nil
    }
    
    func rightSubtree() -> Tree<T>? {
        return nil
    }
    
}

class Leaf<T> : Tree<T> {}

class Node<T> : Tree<T> {
    
    override func getLogicValue() -> Bool  {
        return true
    }
    
    typealias Data = (Tree<T>, T, Tree<T>)
    
    let data: Data
    
    init(_ left: Tree<T>, _ node: T, _ right: Tree<T>) {
        self.data = (left, node, right)
    }
    
    override func fold<L>(leafValue: L, f: (L,T,L) -> L) -> L {
        let (left, node, right) = self.data
        return f(left.fold(leafValue, f), node, right.fold(leafValue, f))
    }
    
    override func node() -> T? {
        let (_, node, _) = self.data
        return node
    }
    
    override func equal(other: Tree<T>, eq: (T,T) -> Bool) -> Bool {
        let (sLeft, sNode, sRight) = self.data
        if let (oLeft, oNode, oRight) = (other as? Node)?.data {
            return sLeft.equal(oLeft, eq) && eq(sNode, oNode) && sRight.equal(oRight, eq)
        } else {
            return false
        }
    }
    
    override func leftSubtree() -> Tree<T>? {
        let (left, _, _) = self.data
        return left
    }

    override func rightSubtree() -> Tree<T>? {
        let (_, _, right) = self.data
        return right
    }
    
}

extension Tree : Printable {
    
    var description: String {
    get {
        return self.fold(".") { "[\($0)^\($1)^\($2)]" }
    }
    }
    
}
