//
//  GroupedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/13/15.
//
//

import Foundation
import BigInt

public struct GroupedToken {
    public enum Kind {
        case number(DiscreteInt)
        case variable(String)
        case `operator`(Operator)
        case function(String, Array<GroupedToken>)
        case group(Array<GroupedToken>)
    }
    
    public let kind: Kind
    public let range: Range<Int>
}
