//
//  Evaluation.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 02/01/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import UIKit

public class Evaluation: NSObject {
    public let expression: String
    public let substitutions: Substitutions
    public var parameters: EvaluationParameters
    
    public private(set) var result: Result? = nil
    public private(set) var error: EvaluationError? = nil
    
    public init(expression: String, substitutions: Substitutions, parameters: EvaluationParameters = .default) {
        self.expression = expression
        self.substitutions = substitutions
        self.parameters = parameters
    }
    
    public func evaluate() throws {
        do {
            let expressionToken = try Expression(string: expression)
            var evaluator = Evaluator(caseSensitive: true)
            switch Preferences.shared.angleMode {
            case .radians: evaluator.angleMeasurementMode = .radians
            case .degrees: evaluator.angleMeasurementMode = .degrees
            }
            evaluator.parameters = parameters
            result = try evaluator.evaluate(expressionToken, substitutions: substitutions)
        } catch {
            if let error = error as? MathParserError {
                self.error = EvaluationError(error: error)
            }
            throw error
        }
    }
}

public struct EvaluationError {
    public let error: MathParserError
    public var description: String {
        switch error.kind {
        case .cannotParseNumber: return "Cannot parse number"
        case .cannotParseHexNumber: return "Cannot parse hex number"
        case .cannotParseOctalNumber: return "Cannot parse octal number"
        case .cannotParseFractionalNumber: return "Cannot parse fraction"
        case .cannotParseExponent: return "Cannot parse exponent"
        case .cannotParseIdentifier: return "Cannot parse identifier"
        case .cannotParseVariable: return "Cannot parse variable"
        case .cannotParseQuotedVariable:return "Cannot parse variable"
        case .cannotParseOperator: return "Cannot parse operator"
        case .zeroLengthVariable: return "Zero length variable"
        case .cannotParseLocalizedNumber: return "Cannot parse number"
        case .unknownOperator: return "Unknown operator"
        case .ambiguousOperator: return "Ambiguous operator"
        case .missingOpenParenthesis: return "Missing open parenthesis"
        case .missingCloseParenthesis: return "Missing closing parenthesis"
        case .emptyFunctionArgument: return "Empty function argument"
        case .emptyGroup: return "Empty group"
        case .invalidFormat: return "Invalid format"
        case .missingLeftOperand(let operand): return "Missing left operand '\(operand.description)'"
        case .missingRightOperand(let operand): return "Missing right operand '\(operand.description)'"
        case .unknownFunction(let function): return "Unknown function '\(function)'"
        case .unknownVariable(let variable): return "Unknown variable '\(variable)'"
        case .divideByZero: return "Division by zero"
        case .invalidArguments: return "Invalid arguments"
        case .argumentNotInteger: return "Argument(s) must be integer(s)"
        case .argumentNotPositive: return "Argument(s) must be positive"
        case .argumentNotLogicalValue: return "Argument(s) must be either true/1 or false/0"
        }
    }
    public var range: Range<Int> {
        return error.range
    }
    
}
public struct EvaluationParameters {
    public static let `default` = EvaluationParameters()
    public var decimals: Int = 12
    public var angleMode = Preferences.shared.angleMode
}
