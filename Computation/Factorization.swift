//
//  Factorization.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 15/01/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit

public struct Factorization {
    var factors: [Factor] = []
    let integer: DiscreteInt
    public init(_ integer: DiscreteInt) {
        self.integer = integer
    }
    fileprivate var executionLock: Bool {
        return ComputationLock.shared.executionLock
    }
    /**
     Factors a given integer (positive of negative) into its prime factors. Interrupting will still produce a partial factorization, ideal for large numbers. Algorithm is still pretty basic.
    */
    // TODO: is checking for primality going to be faster that just trying to factor it?
    public mutating func factor() {
        func abortFactoring(_ current: [DiscreteInt] = []) {
            self.factors = process(factors: current)
            self.factors.append(Factor(.nan))
        }
        func process(factors: [DiscreteInt]) -> [Factor] {
            var returnValue = [Factor]()
            let uniqueFactors = factors.removeDuplicates()
            for factor in uniqueFactors {
                let count = factors.reduce(0) { $1 == factor ? $0 + 1 : $0}
                returnValue.append(Factor(factor, DiscreteInt(count)))
            }
            return returnValue
        }
        if integer.isZero { self.factors = [Factor(0)]; return }
        var factors: [DiscreteInt] = []
        var d: DiscreteInt = 2
        var n = integer
        if integer.isNegative {
            self.factors.append(Factor(-1))
            n = integer.magnitude
        }
        while n > 1 {
            if executionLock { abortFactoring(factors); return }
            while n % d == 0 {
                if executionLock { abortFactoring(factors); return }
                factors.append(d)
                n /= d
            }
            d += 1
            if executionLock { abortFactoring(factors); return }
            if (d ** 2) > integer.magnitude {
                if n > 1 {
                    factors.append(n)
                }
                break
            }
        }
        self.factors.append(contentsOf: process(factors: factors))
    }
}

extension Factorization: Result {
    public func isEqual(to result: Result) -> Bool {
        if let factorization = result as? Factorization {
            return factors == factorization.factors && integer == factorization.integer
        }
        return false
    }
    
    public var description: String {
        var string = ""
        for factor in factors {
            let superscript = factor.count == 1 ? "" : factor.count.description.superscripted
            string.append(factor.factor.description + superscript + " × ")
        }
        return String(string.dropLast().dropLast().dropLast())
    }
    
    public var isApproximation: Bool {
        return false
    }
    public var signString: String {
        return "="
    }
    
}

public struct Factor: Equatable {
    let factor: DiscreteInt
    let count: DiscreteInt
    public init(_ factor: DiscreteInt, _ count: DiscreteInt) {
        self.factor = factor
        self.count = count
    }
    public init(_ factor: DiscreteInt) {
        self.init(factor, 1)
    }
}

extension Array where Element : Equatable {
    func removeDuplicates() -> [Element] {
        var result = [Element]()
        
        for value in self {
            if result.contains(value) == false {
                result.append(value)
            }
        }
        
        return result
    }
}
