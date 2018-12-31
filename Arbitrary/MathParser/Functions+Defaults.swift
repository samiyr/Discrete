//
//  StandardFunctions.swift
//  DDMathParser
//
//  Created by Dave DeLong on 8/20/15.
//
//

import Foundation

public extension Function {
    
    // MARK: - Angle mode helpers
    
    internal static func _dtor(_ d: BigDouble, evaluator: Evaluator) -> BigDouble {
        guard evaluator.angleMeasurementMode == .degrees else { return d }
        return d / 180 * BigDouble.pi
    }
    
    internal static func _rtod(_ d: BigDouble, evaluator: Evaluator) -> BigDouble {
        guard evaluator.angleMeasurementMode == .degrees else { return d }
        return d / BigDouble.pi * 180
    }
    
    public static let standardFunctions: Array<Function> = [
        add, subtract, multiply, divide,
        modulo, negate, factorial, factorial2, choose, variations, prime,
        pow, tetriate, sqrt, cuberoot, nthroot,/*
        random,*/ abs, percent,
        logarithm, loge, log2, exponential,
        and, or, not, xor, lshift, rshift,
        sum, product,
        count, minimum, maximum, average, median, stddev,
        ceiling, truncation,
        sine, cosine, tangent, /*asin, acos, atan, atan2,*/
        csc, sec, cotan, /*acsc, asec, acotan,*/
        sineh, cosineh, tangenth, asinh, acosh, atanh,
        csch, sech, cotanh, acsch, asech, acotanh,
        versin, vercosin, coversin, covercosin, haversin, havercosin, hacoversin, hacovercosin, exsec, excsc, crd,
        dtor, rtod,
        `true`, `false`,
        phi, pi, pi_2, pi_4, tau, sqrt2, e, log2e, log10e, ln2, ln10,
        l_and, l_or, l_not, l_eq, l_neq, l_implication, l_equivalence, l_lt, l_gt, l_ltoe, l_gtoe, l_if,
        fibonacci, lucas, catalan, bell
    ]
    
    // MARK: - Basic functions
    
    public static let add = Function(name: "add", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 + arg2
    })
    
    public static let subtract = Function(name: "subtract", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 - arg2
    })
    
    public static let multiply = Function(names: ["multiply", "implicitmultiply"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return arg1 * arg2
    })
    
    public static let divide = Function(name: "divide", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        guard arg2 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return arg1 / arg2
    })
    
    public static let modulo = Function(names: ["mod", "modulo"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return mod(arg1, arg2)
    })
    
    public static let negate = Function(name: "negate", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return -arg1
    })
 
    public static let factorial = Function(name: "factorial", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1.factorial
    })
    
    public static let factorial2 = Function(name: "factorial2", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 >= 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        guard arg1 == floor(arg1) else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
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
    
    public static let pow = Function(name: "pow", evaluator: { state throws -> BigDouble in
        if state.arguments.count == 2 {
            let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
            let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
            
            return arg1**arg2
        } else if state.arguments.count == 3 {
            let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
            let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
            let n = try state.evaluator.evaluate(state.arguments[2], substitutions: state.substitutions)
            guard arg1.isInteger, arg2.isInteger, n.isInteger else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
            
            return BigDouble(arg1.numerator.power(arg2.numerator, modulus: n.numerator))
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    public static let tetriate = Function(names: ["tetr", "tetriation"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let a = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let n = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        guard a.isPositive, n.isInteger, !n.isNegative else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return tetriation(a, n.numerator)
    })

    
    public static let sqrt = Function(name: "sqrt", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let value = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return value.sqrt
    })
    
    public static let cuberoot = Function(name: "cuberoot", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return arg1.cubeRoot
    })
    
    public static let nthroot = Function(name: "nthroot", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        
        guard arg2 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        
        return root(arg1, arg2)
        
        /*
        if arg1 < 0 && arg2.truncatingRemainder(dividingBy: 2) == 1 {
            // for negative numbers with an odd root, the result will be negative
            let root = Darwin.pow(-arg1, 1/arg2)
            return -root
        } else {
            return Darwin.pow(arg1, 1/arg2)
        }*/
        
    })
    
    /*
    public static let random = Function(name: "random", evaluator: { state throws -> BigDouble in
        guard state.arguments.count <= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var argValues = Array<BigDouble>()
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            argValues.append(argValue)
        }
        
        let lowerBound = argValues.count > 0 ? argValues[0] : BigDouble.leastNormalMagnitude
        let upperBound = argValues.count > 1 ? argValues[1] : BigDouble.greatestFiniteMagnitude
        
        guard lowerBound < upperBound else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let range = upperBound - lowerBound
        
        return (drand48().truncatingRemainder(dividingBy: range)) + lowerBound
    })
 */
    public static let logarithm = Function(names: ["log", "lg"], evaluator: { state throws -> BigDouble in
        if state.arguments.count == 1 {
            let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
            return log(10, arg1)
        } else if state.arguments.count == 2 {
            let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
            guard arg1.isInteger else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
            let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
            return log(arg1, arg2)
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    
    public static let loge = Function(name: "ln", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return ln(arg1)
    })
    
    public static let log2 = Function(names: ["log2", "lb"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return log(2, arg1)
    })

    
    public static let exponential = Function(name: "exp", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return exp(arg1)
    })
    
    public static let abs = Function(name: "abs", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1.magnitude
    })
    
    public static let percent = Function(name: "percent", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let percentArgument = state.arguments[0]
        let percentValue = try state.evaluator.evaluate(percentArgument, substitutions: state.substitutions)
        let percent = percentValue / 100
        
        let percentExpression = percentArgument.parent
        let percentContext = percentExpression?.parent
        
        guard let contextKind = percentContext?.kind else { return percent }
        guard case let .function(f, contextArgs) = contextKind else { return percent }
        
        // must be XXXX + n% or XXXX - n%
        guard let builtIn = BuiltInOperator(rawValue: f), builtIn == .add || builtIn == .minus else { return percent }
        
        // cannot be n% + XXXX or n% - XXXX
        guard contextArgs[1] === percentExpression else { return percent }
        
        let context = try state.evaluator.evaluate(contextArgs[0], substitutions: state.substitutions)
        
        return context * percent
    })
    
    // MARK: - Bitwise functions
    
    public static let and = Function(name: "and", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return BigDouble(Int(arg1.approximation ?? 0) & Int(arg2.approximation ?? 0))
    })
    
    public static let or = Function(name: "or", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return BigDouble(Int(arg1.approximation ?? 0) | Int(arg2.approximation ?? 0))
    })
    
    public static let not = Function(name: "not", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return BigDouble(~Int(arg1.approximation ?? 0))
    })
    
    public static let xor = Function(name: "xor", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return BigDouble(Int(arg1.approximation ?? 0) ^ Int(arg2.approximation ?? 0))
    })
    
    public static let rshift = Function(name: "rshift", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return BigDouble(Int(arg1.approximation ?? 0) >> Int(arg2.approximation ?? 0))
    })
    
    public static let lshift = Function(name: "lshift", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return BigDouble(Int(arg1.approximation ?? 0) << Int(arg2.approximation ?? 0))
    })
    
    // MARK: - Aggregate functions
    
    public static let average = Function(names: ["average", "avg", "mean"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let value = try sum.evaluator(state)
        
        return value / BigDouble(state.arguments.count)
    })
    
    public static let sum = Function(names: ["sum", "∑"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble(0)
        for arg in state.arguments {
            value += try state.evaluator.evaluate(arg, substitutions: state.substitutions)
        }
        return value
    })
    
    public static let product = Function(names: ["product", "∏"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble(1)
        for arg in state.arguments {
            value *= try state.evaluator.evaluate(arg, substitutions: state.substitutions)
        }
        return value
    })
    
    public static let count = Function(name: "count", evaluator: { state throws -> BigDouble in
        return BigDouble(state.arguments.count)
    })
    
    public static let minimum = Function(name: "min", evaluator: { state throws -> BigDouble in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble.infinity
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            value = min(value, argValue)
        }
        return value
    })
    
    public static let maximum = Function(name: "max", evaluator: { state throws -> BigDouble in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble.negativeInfinity
        for arg in state.arguments {
            let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            value = max(value, argValue)
        }
        return value
    })
    
    public static let median = Function(name: "median", evaluator: { state throws -> BigDouble in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var evaluated = Array<BigDouble>()
        for arg in state.arguments {
            evaluated.append(try state.evaluator.evaluate(arg, substitutions: state.substitutions))
        }
        if evaluated.count % 2 == 1 {
            let index = evaluated.count / 2
            return evaluated[index]
        } else {
            let highIndex = evaluated.count / 2
            let lowIndex = highIndex - 1
            
            return BigDouble((evaluated[highIndex] + evaluated[lowIndex]) / 2)
        }
    })
    
    public static let stddev = Function(name: "stddev", evaluator: { state throws -> BigDouble in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let avg = try average.evaluator(state)
        
        var stddev = BigDouble.zero
        for arg in state.arguments {
            let value = try state.evaluator.evaluate(arg, substitutions: state.substitutions)
            let diff = avg - value
            stddev += (diff * diff)
        }
        
        return (stddev / BigDouble(state.arguments.count)).sqrt
    })
    
    public static let ceiling = Function(name: "ceil", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return ceil(arg1)
    })
    
    public static let truncation = Function(names: ["floor", "trunc"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return floor(arg1)
    })
    
    // MARK: - Trigonometric functions
    
    public static let sine = Function(name: "sin", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let cosine = Function(name: "cos", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let tangent = Function(name: "tan", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return tan(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    /*public static let asin = Function(names: ["asin", "sin⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.asin(arg1), evaluator: state.evaluator)
    })
    
    public static let acos = Function(names: ["acos", "cos⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.acos(arg1), evaluator: state.evaluator)
    })
    
    public static let atan = Function(names: ["atan", "tan⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan(arg1), evaluator: state.evaluator)
    })
    
    public static let atan2 = Function(name: "atan2", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan2(arg1, arg2), evaluator: state.evaluator)
    })*/
    
    public static let csc = Function(name: "csc", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sec = Function(name: "sec", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotan = Function(name: "cotan", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = tan(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    /*public static let acsc = Function(names: ["acsc", "csc⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.asin(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let asec = Function(names: ["asec", "sec⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.acos(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let acotan = Function(names: ["acotan", "cotan⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.atan(1.0 / arg1), evaluator: state.evaluator)
    })
    */
    // MARK: - Hyperbolic trigonometric functions
    
    public static let sineh = Function(name: "sinh", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return sinh(arg1)
    })
    
    public static let cosineh = Function(name: "cosh", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return cosh(arg1)
    })
    
    public static let tangenth = Function(name: "tanh", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return tanh(arg1)
    })
    
    public static let asinh = Function(names: ["asinh", "arsinh", "sinh⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return ln(arg1 + ((arg1 ** 2) + 1).sqrt)
    })
    
    public static let acosh = Function(names: ["acosh", "arcosh", "cosh⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return ln(arg1 + ((arg1 ** 2) - 1).sqrt)
    })
    
    public static let atanh = Function(names: ["atanh", "artanh", "tanh⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 0.5 * ln((1 + arg1) / (1 - arg1))
    })
    
    public static let csch = Function(name: "csch", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = sinh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sech = Function(name: "sech", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = cosh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotanh = Function(name: "cotanh", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg = tanh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsch = Function(names: ["acsch", "arcsch", "csch⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return ln(arg1.inverse + ((arg1 ** 2).inverse + 1).sqrt)
    })
    
    public static let asech = Function(names: ["asech", "arsech", "sech⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return ln(arg1.inverse + ((arg1 ** 2).inverse - 1).sqrt)
    })
    
    public static let acotanh = Function(names: ["acotanh", "arcotanh", "cotanh⁻¹"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 0.5 * ln((1 - arg1) / (1 + arg1))
    })
    
    // MARK: - Geometric functions
    
    public static let versin = Function(names: ["versin", "vers", "ver"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 - cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let vercosin = Function(names: ["vercosin", "vercos"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 + cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let coversin = Function(names: ["coversin", "cvs"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 - sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let covercosin = Function(name: "covercosin", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return 1.0 + sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let haversin = Function(name: "haversin", evaluator: { state throws -> BigDouble in
        return try versin.evaluator(state) / 2.0
    })
    
    public static let havercosin = Function(name: "havercosin", evaluator: { state throws -> BigDouble in
        return try vercosin.evaluator(state) / 2.0
    })
    
    public static let hacoversin = Function(name: "hacoversin", evaluator: { state throws -> BigDouble in
        return try coversin.evaluator(state) / 2.0
    })
    
    public static let hacovercosin = Function(name: "hacovercosin", evaluator: { state throws -> BigDouble in
        return try covercosin.evaluator(state) / 2.0
    })
    
    public static let exsec = Function(name: "exsec", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let cosArg1 = cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard cosArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/cosArg1) - 1.0
    })
    
    public static let excsc = Function(name: "excsc", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg1 = sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/sinArg1) - 1.0
    })
    
    public static let crd = Function(names: ["crd", "chord"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let sinArg1 = sin(Function._dtor(arg1, evaluator: state.evaluator) / 2.0)
        return 2 * sinArg1
    })
    
    public static let dtor = Function(name: "dtor", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1 / 180.0 * BigDouble.pi
    })
    
    public static let rtod = Function(name: "rtod", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return arg1 / BigDouble.pi * 180
    })
    
    // MARK: - Constant functions
    
    public static let `true` = Function(names: ["true", "yes"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.true
    })
    
    public static let `false` = Function(names: ["false", "no"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.false
    })
    
    public static let phi = Function(names: ["phi", "ϕ"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.phi
    })
    
    public static let pi = Function(names: ["pi", "π", "tau_2"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi
    })
    
    public static let pi_2 = Function(names: ["pi_2", "tau_4"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi / 2
    })
    
    public static let pi_4 = Function(names: ["pi_4", "tau_8"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi / 4
    })
    
    public static let tau = Function(names: ["tau", "τ"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.tau
    })
    
    public static let sqrt2 = Function(name: "sqrt2", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble(2).sqrt
    })
    
    public static let e = Function(name: "e", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.e
    })
    
    public static let log2e = Function(name: "log2e", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.log2e
    })
    
    public static let log10e = Function(name: "log10e", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.log10e
    })
    
    public static let ln2 = Function(name: "ln2", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.ln2
    })
    
    public static let ln10 = Function(name: "ln10", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.ln10
    })
    
    // MARK: - Logical Functions
    
    public static let l_and = Function(name: "l_and", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != 0 && arg2 != 0) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_or = Function(name: "l_or", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != 0 || arg2 != 0) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_not = Function(name: "l_not", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return (arg1 == 0) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_eq = Function(name: "l_eq", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 == arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_neq = Function(name: "l_neq", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 != arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_lt = Function(name: "l_lt", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 < arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_gt = Function(name: "l_gt", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 > arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_ltoe = Function(name: "l_ltoe", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 <= arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_gtoe = Function(name: "l_gtoe", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (arg1 >= arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_if = Function(names: ["l_if", "if"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 3 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        if arg1 != 0 {
            return try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        } else {
            return try state.evaluator.evaluate(state.arguments[2], substitutions: state.substitutions)
        }
    })
    
    // MARK: Custom functions
    public static let fibonacci = Function(names: ["fibonacci", "F"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        return arg1.fibonacci
    })
    public static let lucas = Function(names: ["lucas", "L"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        if arg1 == 0 { return 2 }
        if arg1 == 1 { return 1 }
        
        return (arg1 - 1).fibonacci + (arg1 + 1).fibonacci
    })
    public static let catalan = Function(name: "catalan", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let n = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        if !n.isInteger { return BigDouble.nan }
        if n.isNegative { return BigDouble.nan }
        
        var product = BigDouble(1)
        var k = n
        while k > 1 {
            product *= (n + k) / k
            k -= 1
        }
        
        return product
    })
    public static let bell = Function(names: ["B", "bell"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let n = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        
        if !n.isInteger { return BigDouble.nan }
        if n.isNegative { return BigDouble.nan }
        
        return n.bell
    })

    public static let choose = Function(names: ["C", "choose"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let n = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        var k = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return binomial(n, k)
    })
    public static let variations = Function(name: "P", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let n = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        var k = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        
        return n.factorial / (n - k).factorial
    })

    public static let l_implication = Function(name: "l_impl", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let p = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let q = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        if p == 1, q == 0 {
            return BigDouble.false
        } else {
            return BigDouble.true
        }
    })
    public static let l_equivalence = Function(name: "l_eqv", evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let p = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let q = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return (p == q) ? BigDouble.true : BigDouble.false
    })
    public static let prime = Function(names: ["p", "prime"], evaluator: { state throws -> BigDouble in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let n = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return n.isPrime ? BigDouble.true : BigDouble.false
    })
}
