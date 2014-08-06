//
//  List.swift
//  Swifter
//
//  Created by Daniel Hanggi on 7/16/14.
//  Copyright (c) 2014 Yahoo!. All rights reserved.
//

import Foundation

/* A generic, functional/persistent linked list based on the algorithm
 * designed by Sleator, Tarjan, et al. */
//enum List<T> {
//    case Nil
//    case Cons([T], [List<T>])
//    
//    static func empty<T>() -> List<T> {
//        return .Nil
//    }
//    
//    static func cons<T>(head: T, _ tail: List<T>) -> List<T> {
//        return .Cons([head], [tail])
//    }
//    
//    static func head<T>(list: List<T>) -> T? {
//        switch list {
//        case .Nil:
//            return nil
//        case .Cons(let head, let tail):
//            return head[0]
//        }
//    }
//    
//    static func tail<T>(list: List<T>) -> List<T>? {
//        switch list {
//        case .Nil:
//            return nil
//        case .Cons(let head, let tail):
//            return tail[0]
//        }
//    }
//    
//    static func fold<A,T>(acc: A, _ list: List<T>, _ f: ((A,T) -> A)) -> A {
//        switch list {
//        case .Nil:
//            return acc
//        case .Cons(let head, let tail):
//            return fold(f(acc, head[0]), tail[0], f)
//        }
//    }
//    
//    static func reverse<T>(list: List<T>) -> List<T> {
//        return reverseMap(list) { $0 }
//    }
//    
//    static func member<T : Equatable>(value: T, list: List<T>) -> Bool {
//        return fold(false, list) {
//            (isMember: Bool, element: T) -> Bool in
//            isMember || element == value
//        }
//    }
//    
//    static func nth<T>(n: Int, list: List<T>) -> T? {
//        return fold((n, nil), list, {
//            (acc: (Int, T?), element: T) -> (Int, T?) in
//            let (n, nth) = acc
//            if n == 0 {
//                return (n - 1, element)
//            } else {
//                return (n - 1, nth)
//            }
//        }).1
//    }
//    
//    static func length<T>(list: List<T>) -> Int {
//        return fold(0, list) { $0.0 + 1 }
//    }
//    
//    static func last<T>(list: List<T>) -> T? {
//        return fold(nil, list) { $0.1 }
//    }
//    static func partition<T>(list: List<T>, p: ((T) -> Bool)) -> (List<T>, List<T>) {
//        let (trues, falses) = fold((empty(), empty()), list) {
//            (acc: (List<T>, List<T>), element: T) -> (List<T>, List<T>) in
//            let (trues, falses) = acc
//            if p(element) {
//                return (List.cons(element, trues), falses)
//            } else {
//                return (trues, List.cons(element, falses))
//            }
//        }
//        return (List.reverse(trues), List.reverse(falses))
//    }
//    
//    static func map<T,S>(list: List<T>, f: ((T) -> S)) -> List<S> {
//        return List.reverse(List.map(list, f))
//    }
//    
//    static func reverseMap<T,S>(list: List<T>, f: ((T) -> S)) -> List<S> {
//        return fold(empty(), list) {
//            (acc: List<S>, head: T) -> List<S> in
//            return List.cons(f(head), acc)
//        }
//    }
//    
//    static func reverseFilter<T>(list: List<T>, p: ((T) -> Bool)) -> List<T> {
//        return fold(empty(), list) {
//            (acc: List<T>, head: T) -> List<T> in
//            if p(head) {
//                return List.cons(head, acc)
//            } else {
//                return acc
//            }
//        }
//    }
//    
//    static func filter(list: List<T>, p: ((T) -> Bool)) -> List<T> {
//        return List.reverse(List.reverseFilter(list, p))
//    }
//    
//    static func update<T>(n: Int, newElement: T, list: List<T>) -> List<T> {
//        return List.reverse(List.fold((n, empty()), list, {
//            (acc: (Int, List<T>), element: T) -> (Int, List<T>) in
//            let (n, list) = acc
//            if n == 0 {
//                return (n - 1, List.cons(newElement, list))
//            } else {
//                return (n - 1, List.cons(element, list))
//            }
//            }).1)
//    }
//    
//}
