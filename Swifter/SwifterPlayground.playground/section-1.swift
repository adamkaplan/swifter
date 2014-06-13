// Playground - noun: a place where people can play

// TODO: Is there a benefit to using Any over parametrized enums?
enum DefinedResult<Z> {
    case Defined(Z)
    case Undefined
}

class PartialFunction<A,B> {
    
    typealias PF = PartialFunction<A,B>
    
    typealias Z = B // this type is the final return type, provided to be overriden
    
    typealias DefaultPF = PartialFunction<A,Z>
    
    let applyOrCheck: (A, Bool) -> DefinedResult<Z>
    
    init(f: (A, Bool) -> DefinedResult<Z>) {
        self.applyOrCheck = f
    }
    
    func apply(a: A) -> B? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            // apply: match
            return p
        case .Undefined:
            // apply: no match
            return nil
        default:
            // apply: bad stuff
            return nil
        }
    }
    
    /* Apply this PartialFunction to `a` if a is defined for it.
    * Otherwise, applies defaultFun to `a` */
    func applyOrElse(a: A, defaultFun: DefaultPF) -> Z? {
        switch applyOrCheck(a, false) {
        case .Defined(let p):
            return p
        default:
            return defaultFun.apply(a)
        }
    }
    
    /* Returns true if this PartialFunction can be applied to `a` */
    func isDefinedAt(a: A) -> Bool {
        switch applyOrCheck(a, true) {
        case .Defined(_):
            return true
        case .Undefined:
            return false
        }
    }
    
    func orElse(otherPF: PF) -> PF {
        return OrElse(f1: self, f2: otherPF)
    }
    
    func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return AndThen<A,B,C>(f1: self, f2: nextPF)
    }
}

/* TODO: make this private. Apple has promised Swift will get access modifiers */
class OrElse<A,B> : PartialFunction<A,B> {
    
    let f1, f2: PF
    
    init(f1: PF, f2: PF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
            let result1 = self.f1.applyOrCheck(a, checkOnly)
            switch result1 {
            case .Defined(_):
                return result1
            case .Undefined:
                return self.f2.applyOrCheck(a, checkOnly)
            }
            })
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return f1.isDefinedAt(a) || f2.isDefinedAt(a)
    }
    
    override func orElse(f3: PF) -> PF {
        return OrElse(f1: f1, f2: f2.orElse(f3))
    }
    
    override func applyOrElse(a: A, defaultFun: PF) -> B? {
        switch f1.applyOrCheck(a, false) {
        case .Defined(let result1):
            return result1
        default:
            return f2.applyOrElse(a, defaultFun: defaultFun)
        }
    }
    
    override func andThen<C>(nextPF: PartialFunction<B,C>) -> PartialFunction<A,C> {
        return OrElse<A,C>(
            f1: AndThen<A,B,C>(f1: f1, f2: nextPF),
            f2: AndThen<A,B,C>(f1: f2, f2: nextPF))
    }
}

/* TODO: make this private. Apple has promised Swift will get access modifiers */
class AndThen<A,B,C> : PartialFunction<A,C> {
    
    typealias NextPF = PartialFunction<B,C>
    
    typealias Z = C
    
    let f1: PartialFunction<A,B>
    
    let f2: NextPF
    
    init(f1: PartialFunction<A,B>, f2: NextPF) {
        self.f1 = f1
        self.f2 = f2
        
        super.init( { [unowned self] (a, checkOnly) in
            let result1 = self.f1.applyOrCheck(a, checkOnly)
            switch result1 {
            case .Defined(let r1):
                let result2 = f2.applyOrCheck(r1, checkOnly)
                switch result2 {
                case .Undefined:
                    return .Undefined
                case .Defined(_):
                    return result2
                }
            default:
                return .Undefined
            }
            })
    }
    
    override func isDefinedAt(a: A) -> Bool {
        return f1.isDefinedAt(a) && f2.isDefinedAt(f1.apply(a)!) // TODO
    }
    
    override func applyOrElse(a: A, defaultFun: DefaultPF) -> Z? {
        switch f1.applyOrCheck(a, false) {
        case .Defined(let r1):
            return f2.apply(r1)
        default:
            return defaultFun.apply(a)
        }
    }
}

let sample = [0, 1, 2, 3, 4, 5, 6, 7, 8];

let acceptEven = PartialFunction<Int, Int> { (i: Int, _) in
    if i % 2 == 0 {
        return .Defined(i)
    } else {
        return .Undefined
    }
}

sample.filter(acceptEven.isDefinedAt)

let acceptOdd = PartialFunction<Int, Int> { (i: Int, _) in
    if i % 2 != 0 {
        return .Defined(i)
    } else {
        return .Undefined
    }
}

sample.filter(acceptOdd.isDefinedAt)

let acceptNaturalNumbers = acceptEven.orElse(acceptOdd)

sample.filter(acceptNaturalNumbers.isDefinedAt)

sample.map(acceptOdd.orElse(acceptEven).isDefinedAt)

let acceptNoNaturalNumbers = acceptEven.andThen(acceptOdd);

sample.map(acceptNoNaturalNumbers.apply)

sample.map(acceptNoNaturalNumbers.isDefinedAt)

operator infix /~ {}
@infix func /~ (num: Int, denom: Int) -> Int? {
    let divide = PartialFunction<(Int, Int), Int>( { (ints: (Int, Int), _) in
        let (num, denom) = ints
        if denom != 0 {
            return .Defined(num/denom)
        } else {
            return .Undefined
        }
        })
    
    return divide.apply(num, denom)
}

6 /~ 7

// TODO: simple pattern matching

let byTen = PartialFunction<Any, Int>( { (a: Any, _) in
    switch a {
    case let n as Int:
        return .Defined(10 * n)
    case let s as String where s.toInt():
        return .Defined(10 * s.toInt()!)
    default:
        return .Undefined
    }
    })

let example: Array<Any> = [1, "1", 2, "2", "cat", "120"]

example.map(byTen.apply)

// EXAMPLE
// match n with
// | n when n % 2 = 0 && n <= 10-> Some n
// | n when n % 2 != 0 && n <= 10 -> Some n
// | _ -> None

let firstPattern = PartialFunction<Int, Int?>({ (n: Int, _) in
    if n % 2 == 0 && n <= 10 {
        return .Defined(n)
    } else {
        return .Undefined
    }
    })

let firstExpression = PartialFunction<Int?, Int?>({ (n, _) in
    return .Defined(n)
    })

let firstCase = firstPattern.andThen(firstExpression)

let secondPattern = PartialFunction<Int, Int?>({ (n: Int, _) in
    if n % 2 != 0 && n <= 10 {
        return .Defined(n)
    } else {
        return .Undefined
    }
    })

let secondExpression = PartialFunction<Int?, Int?>({ (n, _) in
    return .Defined(n)
    })

let secondCase = secondPattern.andThen(secondExpression)

let defaultPattern = PartialFunction<Int, Int?>({ _ in return .Undefined})

let defaultExpression = PartialFunction<Int?, Int?>({ (n, _) in
    return .Defined(n)
    })

let defaultCase = defaultPattern.andThen(defaultExpression)

let wholeMatch = firstCase.orElse(secondCase).orElse(defaultCase)

wholeMatch.apply(-5)
wholeMatch.apply(4)
wholeMatch.apply(10)
wholeMatch.apply(11)

// LIST EXAMPLE
// match list with
// | 1::2::_ -> Some "Hello"
// | 0::1::_ -> Some "Goodbye"
// | [3, a, 5] -> Some (string_of_int a)
// | _ -> None

let case1 = PartialFunction<Int[], Int?>( { (m: Int[], _) in
    if m[0] == 1 && m[1] == 2 && m.count > 2 {
        return .Defined(nil)
    } else {
        return .Undefined
    }
    })
let case2 = PartialFunction<Int[], Int?>( { (m: Int[], _) in
    if m[0] == 0 && m[1] == 1 && m.count > 2 {
        return .Defined(nil)
    } else {
        return .Undefined
    }
    })
let case3 = PartialFunction<Int[], Int?>( { (m: Int[], _) in
    if m[0] == 3 && m[2] == 5 && m.count == 3 {
        return .Defined(m[1])
    } else {
        return .Undefined
    }
    })
let caseD = PartialFunction<Int[], Int?>( { _ in return .Defined(nil) })
// There is no need for a default pattern match?
// How to check for exhaustiveness without default case??

let expr1 = PartialFunction<Int?, String?>( { _ in .Defined("Hello") })
let expr2 = PartialFunction<Int?, String?>( { _ in .Defined("Goodbye") })
let expr3 = PartialFunction<Int?, String?>( { (i: Int?, _) in .Defined("\(i!)") })
let exprD = PartialFunction<Int?, String?>( { _ in .Defined(nil) })

let patt1 = case1.andThen(expr1)
let patt2 = case2.andThen(expr2)
let patt3 = case3.andThen(expr3)
let pattD = caseD.andThen(exprD)

let patt = patt1.orElse(patt2).orElse(patt3).orElse(pattD)

patt.apply([1, 2, 3, 4, 5, 6])
