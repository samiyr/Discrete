//
//  FractionNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/30/15.
//
//

import Foundation
import BigInt

internal struct FractionNumberExtractor: TokenExtractor {
    
    internal static let fractions: Dictionary<Character, DiscreteInt> = [:]
    
    func matchesPreconditions(_ buffer: TokenCharacterBuffer) -> Bool {
        guard let peek = buffer.peekNext() else { return false }
        guard let _ = FractionNumberExtractor.fractions[peek] else { return false }
        return true
    }
    
    func extract(_ buffer: TokenCharacterBuffer) -> Tokenizer.Result {
        let start = buffer.currentIndex
        
        // consume the character
        buffer.consume()
        
        let range: Range<Int> = start ..< buffer.currentIndex
        let raw = buffer[range]
        return .value(FractionNumberToken(string: raw, range: range))
    }
    
}
