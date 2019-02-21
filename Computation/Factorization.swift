//
//  Factorization.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 15/01/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt

public struct Factorization {
    var factors: [Factor] = []
    let integer: BigInt
    public init(_ integer: BigInt) {
        self.integer = integer
    }
    public mutating func factor() {
        var n = integer
        guard n > 1 else { return }
        guard !n.isPrime() else {
            factors.append(Factor(1))
            factors.append(Factor(n))
            return
        }
        let wheel: [BigInt] = [2, 3, 5, 7]
        for k in wheel {
            var count: BigInt = 0
            while n % k == 0 {
                count += 1
                n /= k
            }
            if count > 0 {
                factors.append(Factor(k, count))
            }
        }
        var k: BigInt = 7, i = 1
        let increments: [BigInt] = [4, 2, 4, 2, 6, 2, 6]
        while k * k <= n {
            var count: BigInt = 0
            if n % k == 0 {
                count += 1
                n /= k
            } else {
                if count > 0 {
                    factors.append(Factor(k, count))
                }

                k += increments[i]
                if i < 8 {
                    i += 1
                } else {
                    i = 1
                }
            }
        }
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
    let factor: BigInt
    let count: BigInt
    public init(_ factor: BigInt, _ count: BigInt) {
        self.factor = factor
        self.count = count
    }
    public init(_ factor: BigInt) {
        self.init(factor, 1)
    }
}
