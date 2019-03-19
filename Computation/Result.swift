//
//  Result.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 04/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import BigInt

public protocol Result {
    var description: String { get }
    func isEqual(to result: Result) -> Bool
}
public protocol NumericResult: Result, Substitution {
    var numericValue: DiscreteInt { get }
}
