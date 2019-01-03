//
//  TaylorSeries.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 30/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

public struct TaylorSeries {
    public enum Expansion {
        case sin, ln, exp, expm1
    }
    public let decimals: Int
    public let series: Expansion
    
    public init(series: Expansion, to decimals: Int) {
        self.series = series
        self.decimals = decimals
    }
    private func iterations(for series: Expansion, to decimals: Int, at x: BigDouble) -> BigDouble {
        func error(t: BigDouble, x: BigDouble, M: BigDouble, n: BigDouble) -> BigDouble {
            let k = n + 1
            return (M * ((x - t) ** k)) / k.factorial
        }
        
        switch series {
        default:
            return 2 * x * BigDouble(decimals)
        }
    }
    public func calculate(at x: BigDouble) -> BigDouble {
        let iterations = self.iterations(for: series, to: decimals, at: x)
        var sum = BigDouble.zero
        var k = BigDouble.zero
        while k < iterations {
            switch series {
            case .sin: sum += sine(k, x)
            case .ln: sum += log(k, x)
            case .exp: sum += exp(k, x)
            case .expm1: sum += expm1(k, x)
            }
            k += 1
        }
        /*for k in 0...outer {
                for i in (k * inner)..<((k + 1) * inner) {
                    let index = BigDouble(i)
                    switch series {
                    case .sin: sum += sine(index, x)
                    case .ln: sum += log(index, x)
                    }
            }
        }*/

        sum.isApproximation = true
        return sum
    }
    
    private func sine(_ k: BigDouble, _ x: BigDouble) -> BigDouble {
        let sign = k.isEven ? BigDouble(1) : BigDouble(-1)
        let t = 2 * k + 1
        let numerator = x ** t
        let denominator = t.factorial
        return (sign * numerator) / denominator
    }
    private func log(_ k: BigDouble, _ x: BigDouble) -> BigDouble {
        let t = x - 1
        var numerator = t ** k
        let denominator = k
        if k.isEven { numerator.negate() }
        return numerator / denominator
    }
    private func exp(_ k: BigDouble, _ x: BigDouble) -> BigDouble {
        let a = x ** k
        let b = k.factorial
        return a / b
    }
    private func expm1(_ k: BigDouble, _ x: BigDouble) -> BigDouble {
        return exp(k + 1, x)
    }
}
