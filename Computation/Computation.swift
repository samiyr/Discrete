//
//  Computation.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 04/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit

public class Computation: NSObject {
    public let number: DiscreteInt
    public let parameters: EvaluationParameters
    fileprivate var executionLock: Bool {
        return ComputationLock.shared.executionLock
    }
    public init(_ number: DiscreteInt, _ parameters: EvaluationParameters = .default) {
        self.number = number
        self.parameters = parameters
    }
    public static var shell: Computation {
        return Computation(0)
    }
    public static func shell(_ params: EvaluationParameters) -> Computation {
        return Computation(0, params)
    }
    
}

private let _lockInstance = ComputationLock()
public class ComputationLock: NSObject {
    
    public static var shared: ComputationLock {
        return _lockInstance
    }
    public func requestLock() {
        executionLock = true
    }
    public func removeLock() {
        executionLock = false
    }
    public private(set) var executionLock = false
    public override init() {
        super.init()
    }
}

extension Computation {
    /**
     Calculates the factorial
     */
    public func factorial() -> DiscreteInt {
        if number.isZero {
            return 1
        } else  {
            var n = number
            var result = DiscreteInt(1)
            while n > 1 {
                if executionLock { return .nan }
                result *= n
                n -= 1
            }
            return result
        }
    }
    /**
     Calculates n:th Fibonacci number.
     */
    public func fibonacci() -> DiscreteInt {
        let n = number
        if n.isNegative {
            let sign: DiscreteInt = (1 - n).isEven ? 1 : -1
            return Computation(-n).fibonacci() * sign
        }
        if number < DiscreteInt(Constants.fibonacciSequence.count) {
            for i in 0 ..< Constants.fibonacciSequence.count {
                if DiscreteInt(i) == n { return Constants.fibonacciSequence[i] }
            }
        }

        if n.isEven {
            return (2 * (Computation(n / 2 - 1).fibonacci()) + Computation(n / 2).fibonacci()) * Computation(n / 2).fibonacci()
        } else {
            return ((Computation((n + 1) / 2).fibonacci()) ** 2) + ((Computation(n / 2 - 1).fibonacci()) ** 2)
        }
    }
    public func stirlingCycles(_ n: DiscreteInt, _ k: DiscreteInt) -> DiscreteInt {
        if executionLock { return .nan }
        if n.isNegative || k.isNegative { return .nan }
        
        if n.isZero, k.isZero { return 1 }
        if n.isZero || k.isZero { return 0 }
        if k == 1 { return (n - 1).factorial }
        if n == k { return 1 }
        if k == n - 1 { return binomial(n, 2) }
        
        return (n - 1) * stirlingCycles(n - 1, k) + stirlingCycles(n - 1, k - 1)
    }
    public func stirlingPartition(_ n: DiscreteInt, _ k: DiscreteInt) -> DiscreteInt {
        if executionLock { return .nan }
        if n.isNegative || k.isNegative { return .nan }
        
        if n == k { return 1 }
        if k > n { return 0 }
        if k.isZero { return 0 }
        if k == 1 { return 1 }
        if k == n - 1 { return binomial(n, 2) }
        
        return k * stirlingPartition(n - 1, k) + stirlingPartition(n - 1, k - 1)
    }
    public func lah(_ n: DiscreteInt, _ k: DiscreteInt) -> DiscreteInt {
        if executionLock { return .nan }
        if n.isNegative || k.isNegative { return .nan }
        
        if n.isZero, k.isZero { return 1 }
        if k > n { return 0 }
        if k == 1 { return n.factorial }
        if k == 2 { return ((n - 1) * n.factorial) / 2}
        if k == n - 1 { return n * (n - 1) }
        if n == k { return 1 }
        return ((n - k + 1) / (k * (k - 1))) * lah(n, k - 1)
    }
    public func bell() -> DiscreteInt {
        if number < DiscreteInt(Constants.bellSequence.count) {
            for i in 0 ..< Constants.bellSequence.count {
                if DiscreteInt(i) == number { return DiscreteInt(Constants.bellSequence[i]) ?? .nan }
            }
        }
        func iterate(_ a: DiscreteInt) -> DiscreteInt {
            if executionLock { return .nan }
            let n = a
            var i = DiscreteInt.zero
            var sum = DiscreteInt.zero
            while i < n {
                if executionLock { return .nan }
                sum += (binomial(n, i) * iterate(a - 1))
                i += 1
            }
            return sum
        }
        return iterate(number)
    }
    public func derivative() -> DiscreteInt {
        if executionLock { return 1 }
        if number.isZero { return 0 }
        if number == 1 { return 0 }
        if number.isPrime { return 1 }
        
        var factorization = Factorization(number)
        factorization.factor()
        let sum = factorization.factors.reduce(0) { (previous: DiscreteInt, factor: Factor) -> DiscreteInt in
            return previous + factor.count / factor.factor
        }
        return sum * number
        
    }
    public func gcd(_ a: DiscreteInt, _ b: DiscreteInt) -> DiscreteInt {
        if a.isNaN || b.isNaN || a.isInfinite || b.isInfinite { return .nan }
        return DiscreteInt(a.value.greatestCommonDivisor(with: b.value))
    }
    public func binomial(_ n: DiscreteInt, _ k: DiscreteInt) -> DiscreteInt {
        if k.isZero { return DiscreteInt(1) }
        if n == k { return DiscreteInt(1) }
        
        var product = DiscreteInt(1)
        var k = k
        while k > 0 {
            if executionLock { return .nan }
            product *= (n + 1 - k) / k
            k -= 1
        }
        
        return product
    }
    public func pow(_ lhs: DiscreteInt, _ rhs: DiscreteInt) -> DiscreteInt {
        if lhs.isZero && rhs.isZero { return .nan }
        if rhs.isZero { return 1 }
        if rhs == 1 { return lhs }
        if rhs.isNegative {
            return lhs == 1 ? 1 : 0
        }
        if lhs <= 1 { return lhs }
        var result = DiscreteInt.unity
        var b = lhs
        var e = rhs
        while e > 0 {
            if e & DiscreteInt.unity == 1 {
                result *= b
            }
            e >>= 1
            b *= b
        }
        return result
    }
    public func tetriation(_ a: DiscreteInt, _ n: DiscreteInt) -> DiscreteInt {
        if n.isZero { return 1 }
        if executionLock { return .nan }
        return a ** tetriation(a, n - 1)
    }
}
