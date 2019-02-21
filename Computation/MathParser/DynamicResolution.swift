//
//  DynamicResolution.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/24/15.
//
//

import Foundation

public protocol FunctionOverrider {
    func overrideFunction(_ function: String, state: EvaluationState) throws -> Result?
}

public protocol FunctionResolver {
    func resolveFunction(_ function: String, state: EvaluationState) throws -> Result?
}

public protocol VariableResolver {
    func resolveVariable(_ variable: String) -> BigDouble?
}

public protocol Substitution {
    func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Result
    func substitutionValue(using evaluator: Evaluator) throws -> Result
    
    func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution
    func simplified(using evaluator: Evaluator) -> Substitution
}

public extension Substitution {
    func substitutionValue(using evaluator: Evaluator) throws -> Result {
        return try substitutionValue(using: evaluator, substitutions: [:])
    }
    
    func simplified(using evaluator: Evaluator) -> Substitution {
        return simplified(using: evaluator, substitutions: [:])
    }
}

public typealias Substitutions = Dictionary<String, Substitution>
