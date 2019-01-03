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
        // Special cases
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
        }
        func fractionalString(_ numerator: BigInt, _ denominator: BigInt) -> String {
            if denominator == 1 { return numerator.description }
            var fraction = numerator.description + "/" + denominator.description
            if Preferences.shared.fractionDisplayMode == .small {
                fraction = numerator.description.superscripted + "/" + denominator.description.subscripted
            }
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
        func scientificString(_ numerator: BigInt, _ denominator: BigInt, _ representation: ExponentRepresentation) -> String {
            let displayMode = Preferences.shared.displayMode
            let decimal = fractionalString(numerator, denominator)
            let exponent = representation.exponent.description.superscripted
            let scientific = "\(representation.mantissa) × \(representation.base)\(exponent)"
            switch displayMode {
            case .automatic: return scientific.count < decimal.count ? scientific : decimal
            case .fractional: return scientific
            case .decimal: return decimal
            }
        }
        // Describe with a representation if possible
        if let representation = exponentRepresentation {
            return scientificString(numerator, denominator, representation)
        }
        // If not, check if it's an approximation
        if isApproximation {
            return decimalApproximation(to: 12).decimal
        }
        // If not that either, it must be just a regular fraction
        return fractionalString(numerator, denominator)
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
        var index = quotientString.count
        while (quotientString.count - 2) < decimals {
            iteratedRemainder = longDivision(iteratedRemainder.remainder * BigInt(Int(pow(10, Double(index)))), denominator)
            let string = "\(iteratedRemainder.quotient)".replacingOccurrences(of: "-", with: "")
            let delta = index - string.count
            if delta > 0 {
                for _ in 0..<delta {
                    quotientString.append("0")
                }
            }
            quotientString.append(string)
            index = quotientString.count
            if iteratedRemainder.remainder.isZero {
                isFinite = true
                break
            }
        }
        if quotientString.count > decimals - 2 {
            quotientString = String(quotientString[quotientString.startIndex...quotientString.index(quotientString.startIndex, offsetBy: decimals + 2)])
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
            if divisor == 1 || divisor.isNaN {
                self.numerator = numerator
                self.denominator = denominator
            } else {
                self.numerator = numerator / divisor.numerator
                self.denominator = denominator / divisor.numerator
            }
        } else {
            self.numerator = numerator
            self.denominator = denominator
        }
        if self.denominator.description.replacingOccurrences(of: "1", with: "").replacingOccurrences(of: "0", with: "").isEmpty {
            let string = "\(self.numerator)"
            if string.contains(".") {
                let components = string.components(separatedBy: ".")
                if let first = components.first, let last = components.last, let mantissa = BigInt(first + last) {
                    exponentRepresentation = ExponentRepresentation(mantissa: mantissa, base: 10, exponent: BigInt(last.count))
                }
            } else {
                let trimmedDecimals = string.replacingOccurrences(of: "0+", with: "", options: .regularExpression)
                let trailingZeroes = string.count - trimmedDecimals.count
                if let mantissa = BigInt(trimmedDecimals) {
                    exponentRepresentation = ExponentRepresentation(mantissa: mantissa, base: 10, exponent: BigInt(trailingZeroes))
                }
            }
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
                let representation = ExponentRepresentation(mantissa: significand.numerator, base: 10, exponent: exponent.numerator)
                self.init(significand * (10 ** exponent))
                self.exponentRepresentation = representation
                return
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
        if isNaN { return false }
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
        return Computation.shell.pow(lhs, rhs)
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
public func stirlingCycles(_ n: BigDouble , _ k: BigDouble) -> BigDouble {
    return Computation.shell.stirlingCycles(n, k)
}
public func stirlingPartition(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
    return Computation.shell.stirlingPartition(n, k)
}
public func lah(_ n: BigDouble, _ k: BigDouble) -> BigDouble {
    return Computation.shell.lah(n, k)
}
public func tetriation(_ a: BigDouble, _ b: BigInt) -> BigDouble {
    return Computation.shell.tetriation(a, b)
}
public func root(_ a: BigDouble, _ n: BigDouble) -> BigDouble {
    return Computation(a).root(n: n)
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
    if ComputationLock.shared.executionLock { return BigDouble.nan }
    let quotient = x.numerator.quotientAndRemainder(dividingBy: x.denominator).quotient
    return BigDouble(quotient + 1)
}
public func floor(_ x: BigDouble) -> BigDouble {
    if ComputationLock.shared.executionLock { return BigDouble.nan }
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
    public var superscripted: String {
        return replacingOccurrences(of: "0", with: "⁰").replacingOccurrences(of: "1", with: "¹").replacingOccurrences(of: "2", with: "²").replacingOccurrences(of: "3", with: "³").replacingOccurrences(of: "4", with: "⁴").replacingOccurrences(of: "5", with: "⁵").replacingOccurrences(of: "6", with: "⁶").replacingOccurrences(of: "7", with: "⁷").replacingOccurrences(of: "8", with: "⁸").replacingOccurrences(of: "9", with: "⁹").replacingOccurrences(of: "-", with: "⁻")
    }
    public var subscripted: String {
        return replacingOccurrences(of: "0", with: "₀").replacingOccurrences(of: "1", with: "₁").replacingOccurrences(of: "2", with: "₂").replacingOccurrences(of: "3", with: "₃").replacingOccurrences(of: "4", with: "₄").replacingOccurrences(of: "5", with: "₅").replacingOccurrences(of: "6", with: "₆").replacingOccurrences(of: "7", with: "₇").replacingOccurrences(of: "8", with: "₈").replacingOccurrences(of: "9", with: "₉").replacingOccurrences(of: "-", with: "₋")
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
    public func gcd(a: BigInt, _ b: BigInt) -> BigDouble {
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
        let series = TaylorSeries(series: .exp, to: parameters.decimals)
        return series.calculate(at: number)
    }
    public func expm1() -> BigDouble {
        let series = TaylorSeries(series: .expm1, to: parameters.decimals)
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
        let series = TaylorSeries(series: .ln, to: parameters.decimals)
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
        let series = TaylorSeries(series: .sin, to: parameters.decimals)
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
