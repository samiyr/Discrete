//
//  Result.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 04/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt

/**
 Highest-level abstraction for a computation result, supporting a textual representation and equatability.
 */
public protocol Result {
    /**
     Returns a textual representation of the result.
    */
    var description: String { get }
    /**
     True if two results are equal.
    */
    func isEqual(to result: Result) -> Bool
}

/**
 Abstraction for any numerical result. Currently used only on DiscreteInt.
 */
public protocol NumericResult: Result, Substitution {
    /**
     Returns the numberic value.
    */
    var numericValue: DiscreteInt { get }
}
