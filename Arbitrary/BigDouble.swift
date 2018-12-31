//
//  BigDouble.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 26/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt
import Darwin

public let BigDoubleComputationHaltNotification = Notification.Name("BigDoubleComputationHaltNotification")

private let fibonacciSequence: [BigDouble] =
    [0,1,1,2,3,5,8,13,21,34,55,89,144,233,377,610,987,
     1597,2584,4181,6765,10946,17711,28657,46368,75025,
     121393,196418,317811,514229,832040,1346269,
     2178309,3524578,5702887,9227465,14930352,24157817,
     39088169,63245986,102334155]
private let bellSequence: [String] = ["1", "1", "2", "5", "15", "52", "203", "877", "4140", "21147", "115975", "678570", "4213597", "27644437", "190899322", "1382958545", "10480142147", "82864869804", "682076806159", "5832742205057", "51724158235372", "474869816156751", "4506715738447323", "44152005855084346", "445958869294805289", "4638590332229999353", "49631246523618756274", "545717047936059989389", "6160539404599934652455", "71339801938860275191172", "846749014511809332450147"]

public struct BigDouble: CustomDebugStringConvertible, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral {
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    
    public fileprivate(set) var numerator: BigInt
    public fileprivate(set) var denominator: BigInt
    
    public private(set) var exponentRepresentation: ExponentRepresentation?
    
    public internal(set) var isApproximation = false
    public fileprivate(set) var isNaN = false
    public fileprivate(set) var isInfinite = false
    public private(set) var isBoolean = false
    
    public var description: String {
        if isNaN {
            return "NaN"
        }
        if isInfinite {
            if isPositive {
                return "∞"
            } else {
                return "-∞"
            }
        }
        if isBoolean {
            return isZero ? "false" : "true"
        }
        if isZero {
            return "0"
        } else if isInteger {
            return "\(numerator)"
        } else if isApproximation {
            return decimalApproximation(to: 12).decimal
        }
        let fraction = "\(numerator)/\(denominator)"
        let decimal = decimalApproximation(to: 12)
        let displayMode = Preferences.shared.displayMode
        switch displayMode {
        case .automatic:
            if decimal.isFinite, fraction.count > decimal.decimal.count {
                return decimal.decimal
            } else {
                return fraction
            }
        case .fractional:
            return fraction
        case .decimal:
            return decimal.decimal
        }
    }
    public var debugDescription: String {
        return description
    }
    public func decimalApproximation(to decimals: Int) -> (decimal: String, isFinite: Bool) {
        func longDivision(_ num: BigInt, _ den: BigInt) -> (quotient: BigInt, remainder: BigInt) {
            return num.quotientAndRemainder(dividingBy: den)
        }
        var isFinite = false
        let division = longDivision(numerator, denominator)
        let quotient = division.quotient
        let remainder = division.remainder
        if remainder.isZero {
            return ("\(quotient)", true)
        }
        var iteratedRemainder = longDivision(remainder, denominator)
        var quotientString = "\(quotient)."
        var index = 1
        while (quotientString.count - 2) < decimals {
            iteratedRemainder = longDivision(iteratedRemainder.remainder * BigInt(Int(pow(10, Double(index)))), denominator)
            let string = "\(iteratedRemainder.quotient)".replacingOccurrences(of: "-", with: "")
            quotientString.append(string)
            index += 1
            if iteratedRemainder.remainder.isZero {
                isFinite = true
                break
            }
        }
        
        return (quotientString, isFinite)
    }
    public var approximation: Double? {
        let decimal = decimalApproximation(to: 32).decimal
        return Double(decimal)
    }
    
    public init(numerator: BigInt, denominator: BigInt, checkDivisor: Bool = true) {
        assert(!denominator.isZero, "Denominator cannot be zero")
        if checkDivisor {
            let divisor = Computation.shell.gcd(a: numerator, denominator)
            if divisor == 1 {
                self.numerator = numerator
                self.denominator = denominator
            } else {
                self.numerator = numerator / divisor
                self.denominator = denominator / divisor
            }
        } else {
            self.numerator = numerator
            self.denominator = denominator
        }
    }
    public init(_ numerator: BigInt, _ denominator: BigInt) {
        self.init(numerator: numerator, denominator: denominator)
    }
    public init(_ value: BigDouble) {
        self.init(numerator: value.numerator, denominator: value.denominator)
    }
    public init(_ value: BigInt) {
        self.init(numerator: value, denominator: 1, checkDivisor: false)
    }
    public init(_ value: Int) {
        self.init(BigInt(value))
    }
    public init(_ value: UInt) {
        self.init(BigInt(value))
    }
    public init?(_ value: String) {
        if let numerator = BigInt(value) {
            self.init(numerator)
            return
        } else if value.numberOfOccurances(of: ".") == 1, !value.contains("e") {
            let components = value.components(separatedBy: ".")
            if let digits = components.first, let decimals = components.last {
                let trimmedDecimals = decimals.replacingOccurrences(of: "^0+", with: "", options: .regularExpression)
                if trimmedDecimals.isEmpty, let numerator = BigInt(digits) {
                    self.init(numerator)
                    if digits.count > 1 {
                        var newDigits = digits
                        newDigits.remove(at: newDigits.startIndex)
                        if newDigits.numberOfOccurances(of: "0") == newDigits.count, let firstDigit = digits.first, let mantissa = Int(String(firstDigit)) {
                            exponentRepresentation = ExponentRepresentation(mantissa: BigInt(mantissa), base: 10, exponent: BigInt(newDigits.count))
                        }
                    }
                    return
                } else {
                    let power = decimals.count
                    if let whole = BigInt(digits), let fractional = BigInt(trimmedDecimals) {
                        let wholePart = BigDouble(whole)
                        let fractionalPart = BigDouble(numerator: fractional, denominator: BigInt(10).power(power))
                        self.init(wholePart + fractionalPart)
                        return
                    }
                }
            }
        } else if value.contains("/") {
            let components = value.components(separatedBy: "/")
            if let numeratorString = components.first, let denominatorString = components.last, numeratorString.isNumeric, denominatorString.isNumeric, let numerator = BigInt(numeratorString), let denominator = BigInt(denominatorString) {
                self.init(numerator: numerator, denominator: denominator)
                return
            }
        } else if value.contains("e") {
            let components = value.components(separatedBy: "e")
            if let significandString = components.first, let exponentString = components.last, let significand = BigDouble(significandString), let exponent = BigDouble(exponentString) {
                
            }
        }
        return nil
    }
    public init?(_ value: Double) {
        self.init("\(value)")
    }
    
    public init(integerLiteral value: Int) {
        self.init(value)
    }
    public init(floatLiteral value: Double) {
        if let temp = BigDouble(value) {
            self.init(temp)
        } else {
            self.init(0)
        }
    }
    
    public static var nan: BigDouble {
        var instance = BigDouble(0)
        instance.isNaN = true
        return instance
    }
    public static var zero: BigDouble {
        return BigDouble(0)
    }
    public static var infinity: BigDouble {
        var instance = BigDouble(1)
        instance.isInfinite = true
        return instance
    }
    public static var negativeInfinity: BigDouble {
        var instance = BigDouble(-1)
        instance.isInfinite = true
        return instance
    }
    public static var `true`: BigDouble {
        var instance = BigDouble(1)
        instance.isBoolean = true
        return instance
    }
    public static var `false`: BigDouble {
        var instance = BigDouble(0)
        instance.isBoolean = true
        return instance
    }
}

// MARK: Properties
extension BigDouble {
    public var isPositive: Bool {
        return numerator.sign == .plus && denominator.sign == .plus
    }
    public var isNegative: Bool {
        return !isZero && !isPositive
    }
    public var isInteger: Bool {
        return denominator == 1
    }
    public var isZero: Bool {
        return numerator.isZero
    }
    public var isEven: Bool {
        return (self % 2) == 0
    }
    
    /**
     Checks whether self is prime, or for large numbers, whether self is a probabilistic prime
    */
    public var isPrime: Bool {
        if !self.isInteger { return false }
        if !self.isPositive { return false }
        let n = self.numerator
        
        return n.isPrime(rounds: 20)
    }
}

infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator *: MultiplicationPrecedence
infix operator /: MultiplicationPrecedence
infix operator **
infix operator %

// MARK: Operations
extension BigDouble {
    // Addition
    public static func + (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        let a = lhs.numerator
        let b = lhs.denominator
        let c = rhs.numerator
        let d = rhs.denominator
        var r = BigDouble(numerator: (a * d) + (b * c), denominator: b * d)
        r.isApproximation = lhs.isApproximation || rhs.isApproximation
        return r
    }
    public static func += (lhs: inout BigDouble, rhs: BigDouble) {
        lhs = lhs + rhs
    }
    // Subtraction
    public static func - (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        let a = lhs.numerator
        let b = lhs.denominator
        let c = rhs.numerator
        let d = rhs.denominator
        var r = BigDouble(numerator: (a * d) - (b * c), denominator: b * d)
        r.isApproximation = lhs.isApproximation || rhs.isApproximation
        return r
    }
    public static func -= (lhs: inout BigDouble, rhs: BigDouble) {
        lhs = lhs - rhs
    }
    // Multiplication
    public static func * (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        let a = lhs.numerator
        let b = lhs.denominator
        let c = rhs.numerator
        let d = rhs.denominator
        var r = BigDouble(numerator: a * c, denominator: b * d)
        r.isApproximation = lhs.isApproximation || rhs.isApproximation
        return r
    }
    public static func *= (lhs: inout BigDouble, rhs: BigDouble) {
        lhs = lhs * rhs
    }
    // Division
    public static func / (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        if rhs.isZero { return BigDouble.nan }
        return lhs * rhs.inverse
    }
    public static func /= (lhs: inout BigDouble, rhs: BigDouble) {
        lhs = lhs / rhs
    }
    // Integer exponentiation
    public static func ** (lhs: BigDouble, rhs: Int) -> BigDouble {
        var r = BigDouble(numerator: lhs.numerator.power(rhs), denominator: lhs.denominator.power(rhs))
        r.isApproximation = lhs.isApproximation
        return r
    }
    public static func ** (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        if rhs.isInteger {
            if rhs.isZero {
                if lhs.isZero { return BigDouble.nan }
                return 1
            } else if rhs.isPositive {
                var n = rhs
                var a = lhs
                var r = BigDouble(1)
                while n > 0 {
                    if !n.isEven {
                        r *= a
                    }
                    a *= a
                    n = floor(n / 2)
                }
                return r
            } else {
                return 1 / (lhs ** (-rhs))
            }
        }
        return BigDouble.nan
    }
    // Modulo
    public static func % (lhs: BigDouble, rhs: BigDouble) -> BigDouble {
        return mod(lhs, rhs)
    }
    public static func % (lhs: BigDouble, rhs: Int) -> BigDouble {
        return lhs % BigDouble(rhs)
    }
    // Inversion
    public var inverse: BigDouble {
        var c = BigDouble(numerator: denominator, denominator: numerator)
        c.isApproximation = self.isApproximation
        return c
    }
    public mutating func invert() {
        self = self.inverse
    }
    public static prefix func ! (value: BigDouble) -> BigDouble {
        return value.inverse
    }
    // Negation
    public var negation: BigDouble {
        if self.isZero { return BigDouble.zero }
        let isPositive = self.isPositive
        var abs = self.magnitude
        if isPositive { abs.numerator.negate() }
        var c = BigDouble(numerator: abs.numerator, denominator: abs.denominator)
        c.isApproximation = self.isApproximation
        return c
    }
    public mutating func negate() {
        self = self.negation
    }
    public static prefix func - (value: BigDouble) -> BigDouble {
        return value.negation
    }
    // Absolute value
    public var magnitude: BigDouble {
        var c = BigDouble(numerator: BigInt(numerator.magnitude), denominator: BigInt(denominator.magnitude))
        c.isApproximation = self.isApproximation
        return c
    }
}
// MARK: Protocol Conformance
extension BigDouble: Equatable {
    public static func == (lhs: BigDouble, rhs: BigDouble) -> Bool {
        return lhs.numerator == rhs.numerator && lhs.denominator == rhs.denominator
    }
}
extension BigDouble: Comparable {
    public static func < (lhs: BigDouble, rhs: BigDouble) -> Bool {
        let a = lhs.numerator
        let b = lhs.denominator
        let c = rhs.numerator
        let d = rhs.denominator
        return (a * d) < (c * b)
    }
    public static func <= (lhs: BigDouble, rhs: BigDouble) -> Bool {
        return lhs == rhs || lhs < rhs
    }
    public static func > (lhs: BigDouble, rhs: BigDouble) -> Bool {
        return !(lhs <= rhs)
    }
    public static func >= (lhs: BigDouble, rhs: BigDouble) -> Bool {
        return !(lhs < rhs)
    }

}

// MARK: Constants
extension BigDouble {
    public static var pi: BigDouble {
        var c = BigDouble(Double.pi)!
        c.isApproximation = true
        return c
    }
    public static var tau: BigDouble {
        return 2 * pi
    }
    public static var e: BigDouble {
        var c = BigDouble(M_E)!
        c.isApproximation = true
        return c
    }
    public static var phi: BigDouble {
        var c = 0.5 * (1 + BigDouble.sqrt5)
        c.isApproximation = true
        return c
    }
    public static var log2e: BigDouble {
        var c = BigDouble(M_LOG2E)!
        c.isApproximation = true
        return c
    }
    public static var log10e: BigDouble {
        var c = BigDouble(M_LOG10E)!
        c.isApproximation = true
        return c
    }
    public static var ln2: BigDouble {
        var c = BigDouble(M_LN2)!
        c.isApproximation = true
        return c
    }
    public static var ln10: BigDouble {
        var c = BigDouble(M_LN10)!
        c.isApproximation = true
        return c
    }
    public static var sqrt5: BigDouble {
        return BigDouble("2.236067977499789696409173668731276235440618359611525724270")!
    }

}

// MARK: Function shorthands
extension BigDouble {
    public var factorial: BigDouble {
        return Computation(self).factorial()
    }
    public var sqrt: BigDouble {
        return Computation(self).sqrt()
    }
    public var cubeRoot: BigDouble {
        return Computation(self).cubeRoot()
    }
    public var fibonacci: BigDouble {
        return Computation(self).fibonacci()
    }
    public var bell: BigDouble {
        return Computation(self).bell()
    }
}
public func binomial(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
    return Computation.shell.binomial(n, k)
}
public func tetriation(_ a: BigDouble, _ b: BigInt) -> BigDouble {
    return Computation.shell.tetriation(a, b)
}
public func root(_ a: BigDouble, _ n: BigDouble) -> BigDouble {
    return Computation(a).root(n: n, to: 1e-3)
}
public func log(_ b: BigDouble, _ x: BigDouble) -> BigDouble {
    return Computation.shell.log(b, x)
}
public func ln(_ x: BigDouble) -> BigDouble {
    return Computation(x).ln()
}
public func exp(_ x: BigDouble) -> BigDouble {
    return Computation(x).exp()
}
public func sin(_ x: BigDouble) -> BigDouble {
    return Computation(x).sin()
}
public func cos(_ x: BigDouble) -> BigDouble {
    return Computation(x).cos()
}
public func tan(_ x: BigDouble) -> BigDouble {
    return Computation(x).tan()
}
public func sinh(_ x: BigDouble) -> BigDouble {
    return Computation(x).sinh()
}
public func cosh(_ x: BigDouble) -> BigDouble {
    return Computation(x).cosh()
}
public func tanh(_ x: BigDouble) -> BigDouble {
    return Computation(x).tanh()
}
// More functions
public func distance(_ x: BigDouble, y: BigDouble) -> BigDouble {
    return (x - y).magnitude
}
public func min(_ a: BigDouble, _ b: BigDouble) -> BigDouble {
    if a < b {
        return a
    } else {
        return b
    }
}
public func max(_ a: BigDouble, _ b: BigDouble) -> BigDouble {
    if a > b {
        return a
    } else {
        return b
    }
}
public func ceil(_ x: BigDouble) -> BigDouble {
    let quotient = x.numerator.quotientAndRemainder(dividingBy: x.denominator).quotient
    return BigDouble(quotient + 1)
}
public func floor(_ x: BigDouble) -> BigDouble {
    let quotient = x.numerator.quotientAndRemainder(dividingBy: x.denominator).quotient
    return BigDouble(quotient)
}
public func mod(_ a: BigDouble, _ n: BigDouble) -> BigDouble {
    return a - n * floor(a / n)
}

// MARK: Helpers

extension String {
    public var isNumeric: Bool {
        return CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: self))
    }
    public func index(of: String) -> Int? {
        if let range = range(of: of) {
            return distance(from: startIndex, to: range.lowerBound)
        }
        return nil
    }
    public func numberOfOccurances(of string: String) -> Int {
        let tokens = components(separatedBy: string)
        return tokens.count - 1
    }
}

// MARK: Exponent representation

public struct ExponentRepresentation {
    public var mantissa: BigInt = 1
    public var base: BigInt
    public var exponent: BigInt
}

// MARK: Operations & computation

public class Computation: NSObject {
    public let number: BigDouble
    
    public init(_ number: BigDouble) {
        self.number = number
    }
    public static var shell: Computation {
        return Computation(0)
    }
    
    // Roots
    public func sqrt() -> BigDouble {
        return root(n: 2, to: 1e-3)
    }
    public func cubeRoot() -> BigDouble {
        return root(n: 3, to: 1e-3)
    }
    /**
     Calculates n:th root up to epsilon precision using Halley's method
     */
    public func root(n: BigDouble, to epsilon: BigDouble) -> BigDouble {
        if number == 0 { return 0 }
        if number == 1 { return 1 }
        if n == 1 { return number }
        var i = BigDouble(2)
        while i < number {
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
        while distance(iteratedValue, y: nextIteration) >= epsilon {
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
            return gamma(number - 1)
        }
    }
    private func integerFactorial(_ n: BigInt) -> BigDouble {
        var n = n
        var result = BigInt(1)
        while n > 1 {
            result *= n
            n -= 1
        }
        return BigDouble(result)
    }
    private func gamma(_ x: BigDouble) -> BigDouble {
        let p = [676.5203681218851
            ,-1259.1392167224028
            ,771.32342877765313
            ,-176.61502916214059
            ,12.507343278686905
            ,-0.13857109526572012
            ,9.9843695780195716e-6
            ,1.5056327351493116e-7
        ]
        
        if x < 0.5 {
            return BigDouble.pi / (Computation(BigDouble.pi * x).sin() * gamma(1 - x))
        } else {
            var z = x - 1
            var k = BigDouble(0.99999999999980993)!
            for (index, element) in p.enumerated() {
                k = k + ((BigDouble(element) ?? 0) / ((z + BigDouble(index)) + 1))
            }
            let t = (z + BigDouble(p.count)) - 0.5
            //let y = sqrt(BigDouble.tau) * t**(z+0.5) * exp(-t) * x
            let y = BigDouble(1)
            return y
        }
        
    }
    /**
     Calculates n:th Fibonacci number using a closed form
     */
    public func fibonacci() -> BigDouble {
        if number < BigDouble(fibonacciSequence.count) {
            return fibonacciSequence[Int(number.approximation!)]
        }
        let n = floor(number)
        return floor(((BigDouble.phi ** n) / BigDouble.sqrt5) + 0.5)
    }
    public func bell() -> BigDouble {
        if number < BigDouble(bellSequence.count) {
            return BigDouble(bellSequence[Int(number.approximation!)])!
        }
        func iterate(_ a: BigDouble) -> BigDouble {
            let n = floor(a)
            var i = BigDouble.zero
            var sum = BigDouble.zero
            while i < n {
                sum += (binomial(n, i) * iterate(a - 1))
                i += 1
            }
            return sum
        }
        return iterate(number)
    }
    public func gcd(a: BigInt, _ b: BigInt) -> BigInt {
        var (a, b) = (a, b)
        while !b.isZero {
            (a, b) = (b, a % b)
        }
        return a
    }
    public func binomial(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
        if k.isZero { return BigDouble(1) }
        if n == k { return BigDouble(1) }
        
        var product = BigDouble(1)
        var k = k
        while k > 0 {
            product *= (n + 1 - k) / k
            k -= 1
        }
        
        return product
    }
    public func tetriation(_ a: BigDouble, _ n: BigInt) -> BigDouble {
        if n == 0 { return 1 }
        return a ** tetriation(a, n - 1)
        
    }
    /**
     Calculates e-based exponential
    */
    public func exp() -> BigDouble {
        return BigDouble.e ** number
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
        if let representation = number.exponentRepresentation, representation.mantissa > 0, representation.base > 0, representation.exponent > 0 {
            // ln(a*b^c)=ln(a)+c*ln(b)
            let a = BigDouble(representation.mantissa)
            let b = BigDouble(representation.base)
            let c = BigDouble(representation.exponent)
            return Computation(a).ln() + c * Computation(b).ln()
        }
        
        // Reflection
        if number > 1 { return -Computation(number.inverse).ln() }
        
        // Series expansion
        let series = TaylorSeries(series: .ln, iterations: 50)
        return series.calculate(at: number)
    }
    public func log(_ b: BigDouble, _ x: BigDouble) -> BigDouble {
        if b == 1 { return BigDouble.nan }
        if b == BigDouble.e { return Computation(x).ln() }
        if b == x { return BigDouble(1) }
        #warning("Missing bounds checks for base")
        if let representation = x.exponentRepresentation, representation.mantissa > 0, representation.base > 0, representation.exponent > 0 {
            // ln(a*b^c)=ln(a)+c*ln(b)
            let a = BigDouble(representation.mantissa)
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
        let series = TaylorSeries(series: .sin, iterations: 50)
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
}
