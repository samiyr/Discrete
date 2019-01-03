//
//  SubstitutionExtensions.swift
//  DDMathParser
//
//  Created by Florian Friedrich on 29.04.17.
//
//

import Foundation

extension BigDouble: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> BigDouble {
        return self
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return self
    }
}

extension Int: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> BigDouble {
        return BigDouble(self)
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        return BigDouble(self)
    }
}

extension String: Substitution {
    public func substitutionValue(using evaluator: Evaluator, substitutions: Substitutions) throws -> BigDouble {
        return try evaluate(using: evaluator, substitutions)
    }
    
    public func simplified(using evaluator: Evaluator, substitutions: Substitutions) -> Substitution {
        // If it's just a BigDouble as String -> Return it as such
        if let double = BigDouble(self) {
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
