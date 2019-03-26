//
//  StandardFunctions.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation
import BigInt

public extension Function {
    
    
    static let standardFunctions: Array<Function> = [
        add, subtract, multiply, divide,
        modulo, greatestCommonDivisor, negate, factorial, factorial2, choose, variations, prime, cycles, stirling, lahNumber, arithmeticDerivative, factor,
        pow, tetriate,
        random, abs, percent,
        and, or, not, xor, lshift, rshift,
        sum, product,
        count, minimum, maximum,
        digits,
        `true`, `false`,
        l_and, l_or, l_not, l_eq, l_neq, l_implication, l_equivalence, l_lt, l_gt, l_ltoe, l_gtoe, l_if,
        fibonacci, lucas, catalan, bell,
        thermalOverride
    ]
    
    // MARK: - Basic functions
    
    static let add = Function(name: "add", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] + args[1]
    })
    
    static let subtract = Function(name: "subtract", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] - args[1]
    })
    
    static let multiply = Function(names: ["multiply", "implicitMultiply"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] * args[1]
    })
    
    static let divide = Function(name: "divide", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        guard args[1] != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return args[0] / args[1]
    })
    
    static let modulo = Function(names: ["mod", "modulo"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] % args[1]
    })
    static let greatestCommonDivisor = Function(name: "gcd", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        
        guard arg1.isPositive, arg2.isPositive else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange) }

        let computation = Computation.shell(state.evaluator.parameters)
        return computation.gcd(arg1, arg2)
    })

    static let negate = Function(name: "negate", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return -args[0]
    })
 
    static let factorial = Function(name: "factorial", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0].factorial
    })
    
    static let factorial2 = Function(name: "factorial2", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1 >= 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        if arg1 % 2 == 0 {
            let k = arg1 / 2
            return (2 ** k) * k.factorial
        } else {
            let k = (arg1 + 1) / 2
            
            let numerator = (2 * k).factorial
            let denominator = (2 ** k) * k.factorial
            
            guard denominator != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
            return numerator / denominator
        }
    })
    
    static let pow = Function(name: "pow", evaluator: { state throws -> Result in
        if state.arguments.count == 2 {
            let args = try state.defaultArguments()
            let arg1 = args[0]
            let arg2 = args[1]

            return arg1**arg2
        } else if state.arguments.count == 3 {
            let args = try state.defaultArguments()
            let arg1 = args[0]
            let arg2 = args[1]
            let n = args[2]
            
            return DiscreteInt(arg1.value.power(arg2.value, modulus: n.value))
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    static let tetriate = Function(names: ["tetr", "tetriation"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let a = args[0]
        let n = args[1]
        guard a.isPositive, !n.isNegative else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return Computation.shell(state.evaluator.parameters).tetriation(a, n)
    })

    
    
    
    static let random = Function(name: "random", evaluator: { state throws -> Result in
        if state.arguments.count == 1 {
            let args = try state.defaultArguments()
            let n = args[0]
            if n.isZero { return DiscreteInt.zero }
            guard n.isPositive else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange) }
            return DiscreteInt(BigUInt.randomInteger(lessThan: args[0].value.magnitude))
        } else if state.arguments.count == 2 {
            let args = try state.defaultArguments()
            var lower = args[0]
            var upper = args[1]
            if lower > upper { swap(&lower, &upper) }
            let delta = upper.value.magnitude - lower.value.magnitude
            let random = BigUInt.randomInteger(lessThan: delta)
            return DiscreteInt(random) + lower
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
 
    static let abs = Function(name: "abs", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return arg1.magnitude
    })
    
    static let percent = Function(name: "percent", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let percentArgument = state.arguments[0]
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let percent = arg1 / 100
        
        let percentExpression = percentArgument.parent
        let percentContext = percentExpression?.parent
        
        guard let contextKind = percentContext?.kind else { return percent }
        guard case let .function(f, contextArgs) = contextKind else { return percent }
        
        // must be XXXX + n% or XXXX - n%
        guard let builtIn = BuiltInOperator(rawValue: f), builtIn == .add || builtIn == .minus else { return percent }
        
        // cannot be n% + XXXX or n% - XXXX
        guard contextArgs[1] === percentExpression else { return percent }
        
        let context = try state.evaluator.evaluate(contextArgs[0], substitutions: state.substitutions)
        
        guard let numeric = context as? NumericResult else { return percent }
        
        return numeric.numericValue * percent
    })
    
    // MARK: - Bitwise functions
    
    static let and = Function(name: "and", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return DiscreteInt(arg1.value & arg2.value)
    })
    
    static let or = Function(name: "or", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return DiscreteInt(arg1.value | arg2.value)
    })
    
    static let not = Function(name: "not", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return DiscreteInt(~arg1.value)
    })
    
    static let xor = Function(name: "xor", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return DiscreteInt(arg1.value ^ arg2.value)
    })
    
    static let rshift = Function(name: "rshift", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return DiscreteInt(arg1.value >> arg2.value)
    })
    
    static let lshift = Function(name: "lshift", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return DiscreteInt(arg1.value << arg2.value)
    })
    
    // MARK: - Aggregate functions
    
    
    static let sum = Function(names: ["sum", "∑"], evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DiscreteInt(0)
        for arg in state.arguments {
            value += (try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult)?.numericValue ?? 0
        }
        return value
    })
    
    static let product = Function(names: ["product", "∏"], evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DiscreteInt(1)
        for arg in state.arguments {
            value *= (try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult)?.numericValue ?? 1
        }
        return value
    })
    
    static let count = Function(name: "count", evaluator: { state throws -> Result in
        return DiscreteInt(state.arguments.count)
    })
    
    static let minimum = Function(name: "min", evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DiscreteInt.infinity
        for arg in state.arguments {
            guard let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range) }
            
            value = min(value, argValue.numericValue)
        }
        return value
    })
    
    static let maximum = Function(name: "max", evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = DiscreteInt.negativeInfinity
        for arg in state.arguments {
            guard let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range) }
            value = max(value, argValue.numericValue)
        }
        return value
    })
    
    
    
    // MARK: - Constant functions
    
    static let `true` = Function(names: ["true", "yes"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return DiscreteInt.true
    })
    
    static let `false` = Function(names: ["false", "no"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return DiscreteInt.false
    })
    
    
    // MARK: - Logical Functions

    static let l_and = Function(name: "l_and", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(arg1), logicalValues.contains(arg2) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return (arg1 == .true && arg2 == .true) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_or = Function(name: "l_or", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(arg1), logicalValues.contains(arg2) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return (arg1 == .true || arg2 == .true) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_not = Function(name: "l_not", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(arg1) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return arg1 == .false ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_eq = Function(name: "l_eq", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 == arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_neq = Function(name: "l_neq", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 != arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_lt = Function(name: "l_lt", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 < arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_gt = Function(name: "l_gt", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 > arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_ltoe = Function(name: "l_ltoe", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 <= arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_gtoe = Function(name: "l_gtoe", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 >= arg2) ? DiscreteInt.true : DiscreteInt.false
    })
    
    static let l_if = Function(names: ["l_if", "if"], evaluator: { state throws -> Result in
        guard state.arguments.count == 3 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(arg1) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}

        if arg1 == .true {
            return try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        } else {
            return try state.evaluator.evaluate(state.arguments[2], substitutions: state.substitutions)
        }
    })
    
    // MARK: Custom functions
    static let fibonacci = Function(names: ["fibonacci", "F"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.fibonacci()
    })
    static let lucas = Function(names: ["lucas", "L"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]


        if arg1 == 0 { return DiscreteInt(2) }
        if arg1 == 1 { return DiscreteInt(1) }
        
        let c1 = Computation(arg1 - 1, state.evaluator.parameters)
        let c2 = Computation(arg1 + 1, state.evaluator.parameters)
        return c1.fibonacci() + c2.fibonacci()
    })
    static let catalan = Function(name: "catalan", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]

        if n.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        
        var product = DiscreteInt(1)
        var k = n
        while k > 1 {
            product *= (n + k) / k
            k -= 1
        }
        
        return product
    })
    static let bell = Function(names: ["B", "bell"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]

        if n.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }

        let computation = Computation(n, state.evaluator.parameters)
        return computation.bell()
    })

    static let choose = Function(names: ["C", "choose"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.binomial(n, k)
    })
    static let variations = Function(name: "P", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let c1 = Computation(n, state.evaluator.parameters)
        let c2 = Computation(n - k, state.evaluator.parameters)
        return c1.factorial() / c2.factorial()
    })

    static let l_implication = Function(name: "l_impl", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let p = args[0]
        let q = args[1]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(p), logicalValues.contains(q) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        
        if p == .true, q == .false {
            return DiscreteInt.false
        } else {
            return DiscreteInt.true
        }
    })
    static let l_equivalence = Function(name: "l_eqv", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let p = args[0]
        let q = args[1]

        let logicalValues = [DiscreteInt.true, DiscreteInt.false]
        guard logicalValues.contains(p), logicalValues.contains(q) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        
        return (p == q) ? DiscreteInt.true : DiscreteInt.false
    })
    static let prime = Function(names: ["p", "prime"], evaluator: { state throws -> Result in
        if state.arguments.count == 1 {
            let args = try state.defaultArguments()
            let n = args[0]
            return n.isPrime ? DiscreteInt.true : DiscreteInt.false
        } else if state.arguments.count == 2 {
            let args = try state.defaultArguments()
            let n = args[0]
            let k = args[1]
            return n.isPrime ? DiscreteInt.true : DiscreteInt.false
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    static let digits = Function(name: "digits", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        return DiscreteInt(n.value.magnitude.count)
    })
    static let cycles = Function(names: ["s", "StirlingS1"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.stirlingCycles(n, k)
    })
    static let stirling = Function(names: ["S", "StirlingS2"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.stirlingPartition(n, k)
    })

    static let lahNumber = Function(names: ["lah"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.lah(n, k)
    })
    static let arithmeticDerivative = Function(names: ["derivative"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let computation = Computation(n, state.evaluator.parameters)
        return computation.derivative()
    })
    
    static let factor = Function(names: ["factor"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        var factorization = Factorization(n)
        factorization.factor()
        return factorization
    })



    // MARK: Overrides
    static let thermalOverride = Function(name: "thermalOverride", evaluator: { state throws -> Result in
        if state.arguments.count == 0 {
            return Preferences.shared.thermalOverride ? DiscreteInt.true : DiscreteInt.false
        } else if state.arguments.count == 1 {
            let value = try state.defaultArguments()[0]
            
            let flag = value == DiscreteInt.true
            Preferences.shared.thermalOverride = flag
            return flag ? DiscreteInt.true : DiscreteInt.false
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
        
    })
    static let irrationalFunctionOverride = Function(name: "irrationalFunctionOverride", evaluator: { state throws -> Result in
        if state.arguments.count == 0 {
            return Preferences.shared.thermalOverride ? DiscreteInt.true : DiscreteInt.false
        } else if state.arguments.count == 1 {
            let value = try state.defaultArguments()[0]

            let flag = value == DiscreteInt.true
            Preferences.shared.irrationalFunctionOverride = flag
            return flag ? DiscreteInt.true : DiscreteInt.false
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
        
    })
}
