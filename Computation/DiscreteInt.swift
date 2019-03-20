//
//  DiscreteInt.swift
//  Computation
//
//  Created by Sami Yrjänheikki on 18/03/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt

/**
 Abstraction around BigInt
*/
public struct DiscreteInt {
    /**
     Underlaying value of the abstraction.
    */
    public var value = BigInt(0)
    /**
     True if this instance is marked as not a number. Note that the actual value is still a number but must not be treated as such.
    */
    public private(set) var isNaN = false
    /**
     True if this instance is intended to be used a true/false value.
    */
    public private(set) var isBoolean = false
    /**
     True if this instance represents an infinite amount. Note that the actual value is still a finite number but must not be treated as such.
    */
    public private(set) var isInfinite = false
    
    /**
     Returns the sign of this number
    */
    public var sign: BigInt.Sign {
        return value.sign
    }
    /**
     Initializes an instance from a BigInt
    */
    public init(_ value: BigInt) {
        self.value = value
    }
    
    /**
     Returns the absolute value
     */
    public var magnitude: DiscreteInt {
        if isNaN { return .nan }
        if isZero { return 0 }
        if isInfinite { return .infinity }
        return DiscreteInt(value.magnitude)
    }
    /**
     True if the number is (probably) a prime. For small values, this is definite, but for large numbers, it only returns a strong guess.
    */
    public var isPrime: Bool {
        return value.isPrime()
    }
    /**
     Returns true if the number is probably a prime, computed with a specified amount of rounds.
     - parameter rounds: Number of rounds of the primality algorithm
    */
    public func isPrime(_ rounds: Int) -> Bool {
        return value.isPrime(rounds: rounds)
    }
}

/**
 Conforms DiscreteInt to the NumericResult protocol used for displaying results.
*/
extension DiscreteInt: NumericResult {
    /**
     Returns the numberic value (which in this case is the value itself)
    */
    public var numericValue: DiscreteInt {
        return self
    }
    /**
     Returns a human-readable description. Usually just the number itself, but in special cases (NaN, infinity, ...) a textual representation.
     */
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
        
        return value.description
    }
    
    /**
     Checks whether two results are equal.
    */
    public func isEqual(to result: Result) -> Bool {
        if let number = result as? DiscreteInt {
            return self.value == number.value
        }
        return false
    }
}

extension DiscreteInt: CustomDebugStringConvertible {
    public var debugDescription: String {
        return description
    }
}

/**
 Conforms DiscreteInt to Substitution protocol, used in the math parses.
*/
extension DiscreteInt: Substitution {
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return self
    }
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Result {
        return self
    }
    
    
}

/**
 Adds a few shorthands to DiscreteInts. Might be removed in the future.
 */
extension DiscreteInt {
    public var factorial: DiscreteInt {
        return Computation(self).factorial()
    }
    public var fibonacci: DiscreteInt {
        return Computation(self).fibonacci()
    }
    public var bell: DiscreteInt {
        return Computation(self).bell()
    }
}

// MARK: - Initialization
// MARK: Integer
extension DiscreteInt {
    public init(_ integer: BigUInt) {
        self.init(BigInt(integer))
    }
    
    public init<T>(_ source: T) where T : BinaryInteger {
        self.init(BigInt(source))
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        self.init(source)
    }
    
    public init<T>(clamping source: T) where T : BinaryInteger {
        self.init(source)
    }
    
    public init<T>(truncatingIfNeeded source: T) where T : BinaryInteger {
        self.init(source)
    }
}

extension DiscreteInt: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: Int64) {
        self.init(value)
    }
}

// MARK: String

extension DiscreteInt {
    public init?<S: StringProtocol>(_ text: S) {
        if let big = BigInt(text) {
            self.init(big)
            return
        }
        return nil
    }
}

extension DiscreteInt: ExpressibleByStringLiteral {
    /// Initialize a new big integer from a Unicode scalar.
    /// The scalar must represent a decimal digit.
    public init(unicodeScalarLiteral value: UnicodeScalar) {
        self.init(BigInt(unicodeScalarLiteral: value))
    }
    
    /// Initialize a new big integer from an extended grapheme cluster.
    /// The cluster must consist of a decimal digit.
    public init(extendedGraphemeClusterLiteral value: String) {
        self.init(BigInt(extendedGraphemeClusterLiteral: value))
    }
    
    /// Initialize a new big integer from a decimal number represented by a string literal of arbitrary length.
    /// The string must contain only decimal digits.
    public init(stringLiteral value: StringLiteralType) {
        self.init(BigInt(stringLiteral: value))
    }
}

extension DiscreteInt: CustomPlaygroundDisplayConvertible {
    /// Return the playground quick look representation of this integer.
    public var playgroundDescription: Any {
        let text = self.description
        return text + " (\(self.value.magnitude.bitWidth) bits)"
    }
}

// MARK: Floating Point
extension DiscreteInt {
    public init?<T: BinaryFloatingPoint>(exactly source: T) {
        if let big = BigInt(exactly: source) {
            self.init(big)
            return
        }
        return nil
    }
    
    public init<T: BinaryFloatingPoint>(_ source: T) {
        self.init(BigInt(source))
    }
}

extension DiscreteInt {
    /**
     Returns a zero.
    */
    public static var zero: DiscreteInt {
        return DiscreteInt(0)
    }
    /**
     Returns a one.
    */
    public static var unity: DiscreteInt {
        return DiscreteInt(1)
    }
    /**
     Returns a boolean true.
    */
    public static var `true`: DiscreteInt {
        var d = DiscreteInt(1)
        d.isBoolean = true
        return d
    }
    /**
     Returns a boolean false.
    */
    public static var `false`: DiscreteInt {
        var d = DiscreteInt(1)
        d.isBoolean = true
        return d
    }
    /**
     Returns an instance representing an infinite amount.
    */
    public static var infinity: DiscreteInt {
        var instance = DiscreteInt(1)
        instance.isInfinite = true
        return instance
    }
    /**
     Returns an instance representing a negatively infinite amount.
    */
    public static var negativeInfinity: DiscreteInt {
        var instance = DiscreteInt(-1)
        instance.isInfinite = true
        return instance
    }
    /**
     Returns an instance representing a NaN (not a number).
    */
    public static var nan: DiscreteInt {
        var instance = DiscreteInt(0)
        instance.isNaN = true
        return instance
    }

    /**
     True if the number is divisible by 2.
    */
    public var isEven: Bool {
        return (self % 2) == 0
    }
    /**
     True if the number is not even.
    */
    public var isOdd: Bool {
        return !isEven
    }
    /**
     True if the number is stricly greater than zero.
    */
    public var isPositive: Bool {
        return self.sign == .plus && !self.isZero
    }
    /**
     True if the number is stricly less than zero.
    */
    public var isNegative: Bool {
        return self.sign == .minus && !self.isZero
    }
    /**
     True if the number is zero.
    */
    public var isZero: Bool {
        return self.value.magnitude.isZero
    }
    /**
     True is the number is one.
    */
    public var isUnity: Bool {
        return self.value == 1
    }
    /**
     True if the instance represents a positive infinity.
    */
    public var isPositiveInfinity: Bool {
        return isPositive && isInfinite
    }
    /**
     True if the instance represents a negative infinity.
    */
    public var isNegativeInfinity: Bool {
        return isNegative && isInfinite
    }
}

infix operator +: AdditionPrecedence
infix operator -: AdditionPrecedence
infix operator *: MultiplicationPrecedence
infix operator /: MultiplicationPrecedence
infix operator **
infix operator %

// MARK: Operations
extension DiscreteInt {
    /**
     Addition
     */
    public static func + (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        if lhs.isNaN || rhs.isNaN { return .nan }
        if lhs.isPositiveInfinity && rhs.isNegativeInfinity { return .nan }
        if lhs.isNegativeInfinity && rhs.isPositiveInfinity { return .nan }
        if lhs.isPositiveInfinity || rhs.isPositiveInfinity { return .infinity }
        if lhs.isNegativeInfinity || rhs.isNegativeInfinity { return .negativeInfinity }
        
        return DiscreteInt(lhs.value + rhs.value)
    }
    public static func += (lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs + rhs
    }
    /**
     Subtraction
    */
    public static func - (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return lhs + rhs.negation
    }
    public static func -= (lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs - rhs
    }
    /**
     Multiplication
    */
    public static func * (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        if lhs.isNaN || rhs.isNaN { return .nan }
        if lhs.isZero && rhs.isInfinite { return .nan }
        if rhs.isZero && lhs.isInfinite { return .nan }
        if lhs.isPositiveInfinity && rhs.isPositiveInfinity { return .infinity }
        if lhs.isNegativeInfinity && rhs.isNegativeInfinity { return .infinity }
        if lhs.isPositiveInfinity && rhs.isNegativeInfinity { return .negativeInfinity }
        if lhs.isNegativeInfinity && rhs.isPositiveInfinity { return .negativeInfinity }
        
        return DiscreteInt(lhs.value * rhs.value)
    }
    public static func *= (lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs * rhs
    }
    /**
     Integer division
    */
    public static func / (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        if lhs.isNaN || rhs.isNaN { return .nan }
        if lhs.isInfinite && rhs.isInfinite { return .nan }
        if rhs.isInfinite { return 0 }
        if lhs.isPositiveInfinity && rhs.isPositive { return .infinity }
        if lhs.isNegativeInfinity && rhs.isPositive { return .negativeInfinity }
        if lhs.isPositiveInfinity && rhs.isNegative { return .negativeInfinity }
        if lhs.isNegativeInfinity && rhs.isNegative { return .infinity }
        if rhs.isZero { return .nan }
        
        return DiscreteInt(lhs.value / rhs.value)
    }
    public static func /= (lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs / rhs
    }
    /**
     Exponentiation
    */
    public static func ** (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return Computation.shell.pow(lhs, rhs)
    }
    /**
     Modulo
    */
    public static func % (lhs: DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(lhs.value % rhs.value)
    }
    public static func % (lhs: DiscreteInt, rhs: Int) -> DiscreteInt {
        return lhs % DiscreteInt(rhs)
    }
    /**
     Inversion
    */
    public var inverse: DiscreteInt {
        return 1 / self
    }
    /**
     Inverts the current instance.
    */
    public mutating func invert() {
        self = self.inverse
    }
    public static prefix func ! (value: DiscreteInt) -> DiscreteInt {
        return value.inverse
    }
    /**
     Negation
    */
    public var negation: DiscreteInt {
        if isNaN { return .nan }
        if isPositiveInfinity { return .negativeInfinity }
        if isNegativeInfinity { return .infinity }
        if isZero { return 0 }
        return DiscreteInt(-self.value)
    }
    /**
     Negates the current instance.
    */
    public mutating func negate() {
        self = self.negation
    }
    public static prefix func - (value: DiscreteInt) -> DiscreteInt {
        return value.negation
    }
}

// MARK: Bitwise Operations
extension DiscreteInt {
    public static prefix func ~(x: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(~x.value)
    }
    
    public static func &(lhs: inout DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(lhs.value & rhs.value)
    }
    
    public static func |(lhs: inout DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(lhs.value | rhs.value)
    }
    
    public static func ^(lhs: inout DiscreteInt, rhs: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(lhs.value ^ rhs.value)
    }
    
    public static func &=(lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs & rhs
    }
    
    public static func |=(lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs | rhs
    }
    
    public static func ^=(lhs: inout DiscreteInt, rhs: DiscreteInt) {
        lhs = lhs ^ rhs
    }
}

// MARK: Bitwise Shifts

extension DiscreteInt {
    public static func &<<(left: DiscreteInt, right: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(left.value &<< right.value)
    }
    
    public static func &<<=(left: inout DiscreteInt, right: DiscreteInt) {
        left.value &<<= right.value
    }
    
    public static func &>>(left: DiscreteInt, right: DiscreteInt) -> DiscreteInt {
        return DiscreteInt(left.value &>> right.value)
    }
    
    public static func &>>=(left: inout DiscreteInt, right: DiscreteInt) {
        left.value &>>= right.value
    }
    
    public static func <<<Other: BinaryInteger>(lhs: DiscreteInt, rhs: Other) -> DiscreteInt {
        return DiscreteInt(lhs.value << rhs)
    }
    
    public static func <<=<Other: BinaryInteger>(lhs: inout DiscreteInt, rhs: Other) {
        lhs.value <<= rhs
    }
    
    public static func >><Other: BinaryInteger>(lhs: DiscreteInt, rhs: Other) -> DiscreteInt {
        return DiscreteInt(lhs.value >> rhs)
    }
    
    public static func >>=<Other: BinaryInteger>(lhs: inout DiscreteInt, rhs: Other) {
        lhs.value >>= rhs
    }
}


// MARK: Comparisons
extension DiscreteInt: Equatable {
    public static func == (lhs: DiscreteInt, rhs: DiscreteInt) -> Bool {
        return lhs.value == rhs.value
    }
}
extension DiscreteInt: Comparable {
    public static func < (lhs: DiscreteInt, rhs: DiscreteInt) -> Bool {
        return lhs.value < rhs.value
    }
    public static func <= (lhs: DiscreteInt, rhs: DiscreteInt) -> Bool {
        return lhs == rhs || lhs < rhs
    }
    public static func > (lhs: DiscreteInt, rhs: DiscreteInt) -> Bool {
        return lhs.value > rhs.value
    }
    public static func >= (lhs: DiscreteInt, rhs: DiscreteInt) -> Bool {
        return lhs == rhs || lhs > rhs
    }
    
}


extension String {
    public var superscripted: String {
        return replacingOccurrences(of: "0", with: "⁰").replacingOccurrences(of: "1", with: "¹").replacingOccurrences(of: "2", with: "²").replacingOccurrences(of: "3", with: "³").replacingOccurrences(of: "4", with: "⁴").replacingOccurrences(of: "5", with: "⁵").replacingOccurrences(of: "6", with: "⁶").replacingOccurrences(of: "7", with: "⁷").replacingOccurrences(of: "8", with: "⁸").replacingOccurrences(of: "9", with: "⁹").replacingOccurrences(of: "-", with: "⁻")
    }
    public var subscripted: String {
        return replacingOccurrences(of: "0", with: "₀").replacingOccurrences(of: "1", with: "₁").replacingOccurrences(of: "2", with: "₂").replacingOccurrences(of: "3", with: "₃").replacingOccurrences(of: "4", with: "₄").replacingOccurrences(of: "5", with: "₅").replacingOccurrences(of: "6", with: "₆").replacingOccurrences(of: "7", with: "₇").replacingOccurrences(of: "8", with: "₈").replacingOccurrences(of: "9", with: "₉").replacingOccurrences(of: "-", with: "₋")
    }
    
}
