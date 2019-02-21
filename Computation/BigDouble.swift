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


public struct BigDouble: CustomDebugStringConvertible, ExpressibleByIntegerLiteral, ExpressibleByFloatLiteral, NumericResult {
    public typealias FloatLiteralType = Double
    public typealias IntegerLiteralType = Int
    
    public fileprivate(set) var numerator: BigInt
    public fileprivate(set) var denominator: BigInt
    
    public var integer: BigInt { return numerator }
    
    public private(set) var exponentRepresentation: ExponentRepresentation?
    
    public internal(set) var isApproximation = false
    public fileprivate(set) var isNaN = false
    public fileprivate(set) var isInfinite = false
    public private(set) var isBoolean = false
    
    internal var decimalPlaces = 12
    
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
            let decimal = decimalApproximation(to: decimalPlaces)
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
            let displayMode = Preferences.shared.largeNumberDisplayMode
            let decimal = fractionalString(numerator, denominator)
            let exponent = representation.exponent.description.superscripted
            let mantissa = fractionalString(representation.mantissa.numerator, representation.mantissa.denominator)
            let scientific = "\(mantissa) × \(representation.base)\(exponent)"
            switch displayMode {
            case .automatic: return scientific.count < decimal.count ? scientific : decimal
            case .scientific: return scientific
            case .decimal: return decimal
            }
        }
        // Describe with a representation if possible
        if let representation = exponentRepresentation {
            return scientificString(numerator, denominator, representation)
        }
        // If not, check if it's an approximation
        if isApproximation {
            return decimalApproximation(to: decimalPlaces).decimal
        }
        // If not that either, it must be just a regular fraction
        return fractionalString(numerator, denominator)
    }
    public var debugDescription: String {
        return description
    }
    public var value: BigDouble {
        return self
    }
    public var signString: String {
        return isApproximation ? "≈" : "="
    }
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return self
    }
    
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Result {
        return self
    }
    public func isEqual(to result: Result) -> Bool {
        if let number = result as? BigDouble {
            return self == number
        }
        return false
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
        var index = BigDouble(quotientString.count)
        let computation = Computation.shell
        while (quotientString.count - 2) < decimals {
            iteratedRemainder = longDivision(iteratedRemainder.remainder * computation.pow(10, index).numerator, denominator)
            let string = "\(iteratedRemainder.quotient)".replacingOccurrences(of: "-", with: "")
            let delta = index - BigDouble(string.count)
            if delta > 0 {
                var k = BigDouble.zero
                while k < delta {
                    quotientString.append("0")
                    k += 1
                }
            }
            quotientString.append(string)
            index = BigDouble(quotientString.count)
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
    
    public init(numerator: BigInt, denominator: BigInt, checkDivisor: Bool = true, checkExponentRepresentation: Bool = true) {
        assert(!denominator.isZero, "Denominator cannot be zero")
        if checkDivisor {
            let divisor = Computation.shell.gcd(numerator, denominator)
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
        if checkExponentRepresentation {
            let num = self.numerator.description
            let trimmedNum = num.replacingOccurrences(of: "0*$", with: "", options: .regularExpression)
            let numPower = num.count - trimmedNum.count
            let den = self.denominator.description
            let trimmedDen = den.replacingOccurrences(of: "0*$", with: "", options: .regularExpression)
            let denPower = den.count - trimmedDen.count
            let exponent = numPower - denPower
            
            if exponent.magnitude > 6, let mantissaNum = BigInt(trimmedNum), let mantissaDen = BigInt(trimmedDen) {
                exponentRepresentation = ExponentRepresentation(mantissa: (mantissaNum, mantissaDen), base: 10, exponent: BigInt(numPower - denPower))
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
                            exponentRepresentation = ExponentRepresentation(mantissa: (BigInt(mantissa), 1), base: 10, exponent: BigInt(newDigits.count))
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
                let representation = ExponentRepresentation(mantissa: (significand.numerator, 1), base: 10, exponent: exponent.numerator)
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
        var c = Computation.shell(EvaluationParameters(decimals: 5370, angleMode: .radians)).pi()
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
    public var mantissa: (numerator: BigInt, denominator: BigInt) = (1, 1)
    public var base: BigInt
    public var exponent: BigInt
}


