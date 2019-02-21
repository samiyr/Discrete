//
//  FractionNumberExtractor.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/30/15.
//
//

import Foundation

internal struct FractionNumberExtractor: TokenExtractor {
    
    internal static let fractions: Dictionary<Character, BigDouble> = [
        "½": BigDouble(1,2),
        "⅓": BigDouble(1,3),
        "⅔": BigDouble(2,3),
        "¼": BigDouble(1,4),
        "¾": BigDouble(3,4),
        "⅕": BigDouble(1,5),
        "⅖": BigDouble(2,5),
        "⅗": BigDouble(3,5),
        "⅘": BigDouble(4,5),
        "⅙": BigDouble(1,6),
        "⅚": BigDouble(5,6),
        "⅛": BigDouble(1,8),
        "⅜": BigDouble(3,8),
        "⅝": BigDouble(5,8),
        "⅞": BigDouble(7,8)
    ]
    
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
