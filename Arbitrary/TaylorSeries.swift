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
        case sin, ln
    }
    public let iterations: Int
    public let series: Expansion
    
    public init(series: Expansion, iterations: Int) {
        self.series = series
        self.iterations = iterations
    }
    
    public func calculate(at x: BigDouble) -> BigDouble {
        var sum = BigDouble.zero
        for k in 0...iterations {
            let index = BigDouble(k)
            switch series {
            case .sin: sum += sine(index, x)
            case .ln: sum += log(index, x)
            }
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
}
