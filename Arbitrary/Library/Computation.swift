//
//  Computation.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 04/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt

public class Computation: NSObject {
    public let number: BigDouble
    public let parameters: EvaluationParameters
    fileprivate var executionLock: Bool {
        return ComputationLock.shared.executionLock
    }
    public init(_ number: BigDouble, _ parameters: EvaluationParameters = .default) {
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
    // Roots
    public func sqrt() -> BigDouble {
        return root(n: 2)
    }
    public func cubeRoot() -> BigDouble {
        return root(n: 3)
    }
    /**
     Calculates n:th root up to epsilon precision using Halley's method
     */
    public func root(n: BigDouble) -> BigDouble {
        if number == 0 { return 0 }
        if number == 1 { return 1 }
        if n == 1 { return number }
        var i = BigDouble(2)
        while i < number {
            if executionLock { return BigDouble.nan }
            let square = i ** 2
            if square == number {
                return i
            }
            i = i + 1
        }
        
        func f(_ x: BigDouble) -> BigDouble {
            return (x ** n) - number
        }
        func df(_ x: BigDouble) -> BigDouble {
            return n * (x ** (n - 1))
        }
        func df2(_ x: BigDouble) -> BigDouble {
            return (n ** 2) * (x ** (n - 2))
        }
        func iterate(_ x: BigDouble) -> BigDouble {
            let numerator = 2 * (f(x) * df(x))
            let denominator = (2 * (df(x) ** 2)) - (f(x) * df2(x))
            return x - (numerator / denominator)
        }
        let initialGuess = number / n
        var iteratedValue = initialGuess
        var nextIteration = iterate(iteratedValue)
        let epsilon = 0.5 * (10 ** parameters.decimals)
        while distance(iteratedValue, y: nextIteration) >= epsilon {
            if executionLock { return BigDouble.nan }
            iteratedValue = nextIteration
            nextIteration = iterate(iteratedValue)
        }
        if !f(nextIteration).isZero {
            nextIteration.isApproximation = true
        }
        return nextIteration
    }
    /**
     Calculates the factorial
     */
    public func factorial() -> BigDouble {
        if number.isZero {
            return 1
        } else if number.isInteger {
            return integerFactorial(number.numerator)
        } else {
            return gamma(number + 1)
        }
    }
    private func integerFactorial(_ n: BigInt) -> BigDouble {
        var n = n
        var result = BigInt(1)
        while n > 1 {
            if executionLock { return BigDouble.nan }
            result *= n
            n -= 1
        }
        return BigDouble(result)
    }
    private func gamma(_ x: BigDouble) -> BigDouble {
        let a = BigDouble.pi.sqrt
        let b = Computation(x).exp().inverse
        let c = x ** x
        let d = 8 * (x ** 3)
        let e = 4 * (x ** 2)
        let f = BigDouble(1, 30)
        let g = (d + e + x + f) ** (BigDouble(1, 6))
        return a * (b / c) * g
    }
    /**
     Calculates n:th Fibonacci number.
     */
    public func fibonacci() -> BigDouble {
        if !number.isInteger { return BigDouble.nan }
        if number.isNaN { return BigDouble .nan }
        if number < BigDouble(Constants.fibonacciSequence.count), !number.isNegative {
            return Constants.fibonacciSequence[Int(number.approximation!)]
        }
        let n = floor(number)
        if n.isNegative {
            let sign: BigDouble = (1 - n).isEven ? 1 : -1
            return Computation(-n).fibonacci() * sign
        }
        if n.isEven {
            return (2 * (Computation(n / 2 - 1).fibonacci()) + Computation(n / 2).fibonacci()) * Computation(n / 2).fibonacci()
        } else {
            return ((Computation((n + 1) / 2).fibonacci()) ** 2) + ((Computation(n / 2 - BigDouble(1,2)).fibonacci()) ** 2)
        }
    }
    public func stirlingCycles(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
        if executionLock { return BigDouble.nan }
        if !n.isInteger || !k.isInteger { return BigDouble.nan }
        if n.isNegative || k.isNegative { return BigDouble.nan }
        
        if n.isZero, k.isZero { return 1 }
        if n.isZero || k.isZero { return 0 }
        if k == 1 { return (n - 1).factorial }
        if n == k { return 1 }
        if k == n - 1 { return binomial(n, 2) }
        
        return (n - 1) * stirlingCycles(n - 1, k) + stirlingCycles(n - 1, k - 1)
    }
    public func stirlingPartition(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
        if executionLock { return BigDouble.nan }
        if !n.isInteger || !k.isInteger { return BigDouble.nan }
        if n.isNegative || k.isNegative { return BigDouble.nan }
        
        if n == k { return 1 }
        if k > n { return 0 }
        if k.isZero { return 0 }
        if k == 1 { return 1 }
        if k == n - 1 { return binomial(n, 2) }
        
        return k * stirlingPartition(n - 1, k) + stirlingPartition(n - 1, k - 1)
    }
    public func lah(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
        if executionLock { return BigDouble.nan }
        if !n.isInteger || !k.isInteger { return BigDouble.nan }
        if n.isNegative || k.isNegative { return BigDouble.nan }
        
        if n.isZero, k.isZero { return 1 }
        if k > n { return 0 }
        if k == 1 { return n.factorial }
        if k == 2 { return ((n - 1) * n.factorial) / 2}
        if k == n - 1 { return n * (n - 1) }
        if n == k { return 1 }
        return ((n - k + 1) / (k * (k - 1))) * lah(n, k - 1)
    }
    public func bell() -> BigDouble {
        if number < BigDouble(Constants.bellSequence.count) {
            return BigDouble(Constants.bellSequence[Int(number.approximation!)])!
        }
        func iterate(_ a: BigDouble) -> BigDouble {
            if executionLock { return BigDouble.nan }
            let n = floor(a)
            var i = BigDouble.zero
            var sum = BigDouble.zero
            while i < n {
                if executionLock { return BigDouble.nan }
                sum += (binomial(n, i) * iterate(a - 1))
                i += 1
            }
            return sum
        }
        //        let n = number
        //        var k = BigDouble.zero
        //        var sum = BigDouble.zero
        //        while k < n {
        //            sum += stirlingPartition(n, k)
        //            k += 1
        //        }
        //        return sum
        return iterate(number)
    }
    public func derivative() -> BigDouble {
        if executionLock { return .nan }
        if number.isNaN { return .nan }
        if number.isApproximation { return .nan }
        if number.isZero { return 0 }
        if number == 1 { return 0 }
        if number.isPrime { return 1 }
        if !number.isInteger {
            let p = Computation(BigDouble(number.numerator), parameters)
            let q = Computation(BigDouble(number.denominator), parameters)
            return BigDouble((p.derivative() * q.number - p.number * q.derivative()).numerator, (q.number ** 2).numerator)
        } else {
            var factorization = Factorization(number.numerator)
            factorization.factor()
            let sum = factorization.factors.reduce(0) { (previous: BigDouble, factor: Factor) -> BigDouble in
                return previous + BigDouble(factor.count, factor.factor)
            }
            return sum * number
        }
    }
    public func gcd(_ a: BigInt, _ b: BigInt) -> BigDouble {
        var (a, b) = (a, b)
        while !b.isZero {
            if executionLock { return BigDouble.nan }
            (a, b) = (b, a % b)
        }
        return BigDouble(a)
    }
    public func binomial(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
        if k.isZero { return BigDouble(1) }
        if n == k { return BigDouble(1) }
        
        var product = BigDouble(1)
        var k = k
        while k > 0 {
            if executionLock { return BigDouble.nan }
            product *= (n + 1 - k) / k
            k -= 1
        }
        
        return product
    }
    public func pow(_ lhs: BigDouble, _ rhs: BigDouble) -> BigDouble {
        if lhs.isNaN || rhs.isNaN { return BigDouble.nan }
        if !lhs.isInteger { return pow(BigDouble(lhs.numerator), rhs) / pow(BigDouble(lhs.denominator), rhs) }
        if lhs.isZero, rhs.isZero { return BigDouble.nan }
        if lhs.isZero { return BigDouble.zero }
        if lhs == 1 { return 1 }
        if rhs.isZero {
            return 1
        } else if rhs.isPositive {
            if rhs.isInteger {
                var n = rhs
                var a = lhs
                var r = BigDouble(1)
                while n > 0 {
                    if executionLock { return BigDouble.nan }
                    if !n.isEven {
                        r *= a
                    }
                    a *= a
                    if executionLock { return BigDouble.nan }
                    n = floor(n / 2)
                }
                return r
            } else {
                let lnb = Computation(rhs).ln()
                return Computation(rhs * lnb).exp()
                var r = pow(Computation(lhs).root(n: BigDouble(rhs.denominator)), BigDouble(rhs.numerator))
                r.isApproximation = !r.isInteger
                return r
            }
        } else {
            if executionLock { return BigDouble.nan }
            return 1 / (lhs ** (-rhs))
        }
    }
    public func tetriation(_ a: BigDouble, _ n: BigInt) -> BigDouble {
        if n == 0 { return 1 }
        if executionLock { return BigDouble.nan }
        return a ** tetriation(a, n - 1)
    }
    /**
     Calculates e-based exponential
     */
    public func exp() -> BigDouble {
        if number.isZero { return 1 }
        if number == 1 { return BigDouble.e }
        let series = Series(series: .exp, to: parameters.decimals)
        return series.calculate(at: number)
    }
    public func expm1() -> BigDouble {
        let series = Series(series: .expm1, to: parameters.decimals)
        return series.calculate(at: number)
    }
    /*
     Natural log using Taylor series expansion
     */
    public func ln() -> BigDouble {
        // Special cases
        if number == 1 { return 0 }
        if number == 2 { return BigDouble.ln2 }
        if number == BigDouble.e { return 1 }
        
        // Domain
        if number.isZero { return BigDouble.negativeInfinity }
        if number < 0 { return BigDouble.nan }
        
        // Simplification
        if let representation = number.exponentRepresentation, representation.mantissa.numerator > 0, representation.mantissa.denominator > 0, representation.base > 0, representation.exponent > 0 {
            // ln(a*b^c)=ln(a)+c*ln(b)
            let a = BigDouble(representation.mantissa.numerator, representation.mantissa.denominator)
            let b = BigDouble(representation.base)
            let c = BigDouble(representation.exponent)
            return Computation(a).ln() + c * Computation(b).ln()
        }
        
        // Reflection
        if number > 1 { return -Computation(number.inverse).ln() }
        
        // Series expansion
        let series = Series(series: .ln, to: parameters.decimals)
        return series.calculate(at: number)
    }
    public func log(_ b: BigDouble, _ x: BigDouble) -> BigDouble {
        if b == 1 { return BigDouble.nan }
        if b == BigDouble.e { return Computation(x).ln() }
        if b == x { return BigDouble(1) }
        #warning("Missing bounds checks for base")
        if let representation = x.exponentRepresentation, representation.mantissa.numerator > 0, representation.mantissa.denominator > 0, representation.base > 0, representation.exponent > 0 {
            // ln(a*b^c)=ln(a)+c*ln(b)
            let a = BigDouble(representation.mantissa.numerator, representation.mantissa.denominator)
            let base = BigDouble(representation.base)
            let c = BigDouble(representation.exponent)
            if a == 1 && b == base {
                var r = c
                r.isApproximation = false
                return r
            }
            return log(b, a) + c * log(b, base)
        }
        
        return Computation(x).ln() / Computation(b).ln()
    }
    // MARK: Trigonometry
    
    public func sin() -> BigDouble {
        func f(_ k: BigDouble, _ r: BigDouble) -> BigDouble {
            let sign = k.isEven ? BigDouble(1) : BigDouble(-1)
            let t = 2 * k + 1
            let numerator = r ** t
            let denominator = Computation(t).factorial()
            return (sign * numerator) / denominator
        }
        if number.isNegative { return Computation(-number).sin() }
        let remainder = number % BigDouble.tau // 0 <= x <= 2pi
        if remainder.isZero { return 0 }
        if remainder == BigDouble.pi / 6 { return 0.5 }
        if remainder == BigDouble.pi / 2 { return 1 }
        if remainder == 5 * BigDouble.pi / 6 { return 0.5 }
        if remainder == BigDouble.pi { return 0 }
        if remainder == 7 * BigDouble.pi / 6 { return -0.5 }
        if remainder == 3 * BigDouble.pi / 2 { return -1 }
        if remainder == 11 * BigDouble.pi / 6 { return -0.5 }
        let series = Series(series: .sin, to: parameters.decimals)
        return series.calculate(at: remainder)
    }
    public func cos() -> BigDouble {
        return Computation(BigDouble.pi / 2 - number).sin()
    }
    public func tan() -> BigDouble {
        let c = Computation(number)
        return c.sin() / c.cos()
    }
    public func sinh() -> BigDouble {
        return 0.5 * (Computation(number).exp() - Computation(-number).exp())
    }
    public func cosh() -> BigDouble {
        return 0.5 * (Computation(number).exp() + Computation(-number).exp())
    }
    public func tanh() -> BigDouble {
        let c = Computation(number)
        return c.sinh() / c.cosh()
    }
    
    // MARK: Constants
    public func pi() -> BigDouble {
        if parameters.decimals < Constants.piExpansion.count {
            return Constants.pi
        }
        var pi = Series(series: .pi, to: parameters.decimals).calculate(at: 0)
        pi.isApproximation = true
        return pi
    }
}
