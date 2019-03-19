//
//  SubstitutionExtensions.swift
//  DDMathParser
//
//  Created by Florian Friedrich on 29.04.17.
//
//

import Foundation
import BigInt


extension Int: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Result {
        return DiscreteInt(self)
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return DiscreteInt(self)
    }
}

extension String: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> Result {
        return try evaluate(using: evaluator, substitutions)
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        // If it's just a DiscreteInt as String -> Return it as such
        if let double = DiscreteInt(self) {
            return double
        }
        
        // If it can be expressed as exression, return the simplified expression
        if let exp = try? Expression(string: self) {
            return exp.simplified(using: evaluator, substitutions: substitutions)
        }
        
        // If it's neither, return self. This will likely fail in evaluation later.
        return self
    }
}
