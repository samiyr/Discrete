//
//  ResolvedToken.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/8/15.
//
//

import Foundation
import BigInt

public struct ResolvedToken {
    public enum Kind {
        case number(DiscreteInt)
        case variable(String)
        case identifier(String)
        case `operator`(Operator)
    }
    
    public let kind: Kind
    public let string: String
    public let range: Range<Int>
}

public extension ResolvedToken.Kind {
    
    var number: DiscreteInt? {
        guard case .number(let o) = self else { return nil }
        return o
    }
    
    var variable: String? {
        guard case .variable(let v) = self else { return nil }
        return v
    }
    
    var identifier: String? {
        guard case .identifier(let i) = self else { return nil }
        return i
    }
    
    var resolvedOperator: Operator? {
        guard case .operator(let o) = self else { return nil }
        return o
    }
    
    var builtInOperator: BuiltInOperator? {
        return resolvedOperator?.builtInOperator
    }

    var isNumber: Bool { return number != nil }
    var isVariable: Bool { return variable != nil }
    var isIdentifier: Bool { return identifier != nil }
    var isOperator: Bool { return resolvedOperator != nil }
}
