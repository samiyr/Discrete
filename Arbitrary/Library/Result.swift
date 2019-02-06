//
//  Result.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 04/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit

public protocol Result {
    var description: String { get }
    var signString: String { get }
}
public protocol NumericResult: Result {
    var value: BigDouble { get }
    var isApproximation: Bool { get }
}
