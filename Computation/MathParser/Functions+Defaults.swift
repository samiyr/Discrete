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
        modulo, greatestCommonDivisor, negate, factorial, factorial2, choose, variations, prime, cycles, stirling, lahNumber, arithmeticDerivative, factor,
        pow, tetriate, sqrt, cuberoot, nthroot,/*
        random,*/ abs, percent,
        logarithm, loge, log2, exponential,
        and, or, not, xor, lshift, rshift,
        sum, product,
        count, minimum, maximum, average, median, stddev,
        ceiling, truncation, digits, decimal,
        sine, cosine, tangent, /*asin, acos, atan, atan2,*/
        csc, sec, cotan, /*acsc, asec, acotan,*/
        sineh, cosineh, tangenth, asinh, acosh, atanh,
        csch, sech, cotanh, acsch, asech, acotanh,
        versin, vercosin, coversin, covercosin, haversin, havercosin, hacoversin, hacovercosin, exsec, excsc, crd,
        dtor, rtod,
        `true`, `false`,
        phi, pi, pi_2, pi_4, tau, sqrt2, e, log2e, log10e, ln2, ln10,
        l_and, l_or, l_not, l_eq, l_neq, l_implication, l_equivalence, l_lt, l_gt, l_ltoe, l_gtoe, l_if,
        fibonacci, lucas, catalan, bell,
        thermalOverride
    ]
    
    // MARK: - Basic functions
    
    public static let add = Function(name: "add", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] + args[1]
    })
    
    public static let subtract = Function(name: "subtract", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] - args[1]
    })
    
    public static let multiply = Function(names: ["multiply", "implicitMultiply"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0] * args[1]
    })
    
    public static let divide = Function(name: "divide", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        guard args[1] != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return args[0] / args[1]
    })
    
    public static let modulo = Function(names: ["mod", "modulo"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return mod(args[0], args[1])
    })
    public static let greatestCommonDivisor = Function(name: "gcd", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange) }
        guard arg1.isPositive, arg2.isPositive else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange) }

        let computation = Computation.shell(state.evaluator.parameters)
        return computation.gcd(arg1.numerator, arg2.numerator)
    })

    public static let negate = Function(name: "negate", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return -args[0]
    })
 
    public static let factorial = Function(name: "factorial", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        return args[0].factorial
    })
    
    public static let factorial2 = Function(name: "factorial2", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
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
    
    public static let pow = Function(name: "pow", evaluator: { state throws -> Result in
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
            guard arg1.isInteger, arg2.isInteger, n.isInteger else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
            
            return BigDouble(arg1.numerator.power(arg2.numerator, modulus: n.numerator))
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    public static let tetriate = Function(names: ["tetr", "tetriation"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let a = args[0]
        let n = args[1]
        guard a.isPositive, n.isInteger, !n.isNegative else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return tetriation(a, n.numerator)
    })

    
    public static let sqrt = Function(name: "sqrt", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let value = args[0]
        guard !value.isNegative else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
        let computation = Computation(value, state.evaluator.parameters)
        return computation.sqrt()
    })
    
    public static let cuberoot = Function(name: "cuberoot", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.cubeRoot()
    })
    
    public static let nthroot = Function(name: "nthroot", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let x = args[1]

        guard !x.isZero else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        guard n.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        guard n.isPositive else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
        
        let computation = Computation(x, state.evaluator.parameters)
        return computation.root(n: n)
    })
    
    /*
    public static let random = Function(name: "random", evaluator: { state throws -> Result in
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
    public static let logarithm = Function(names: ["log", "lg"], evaluator: { state throws -> Result in
        if state.arguments.count == 1 {
            let args = try state.defaultArguments()
            let arg1 = args[0]
            guard !arg1.isNegative else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
            let computation = Computation.shell(state.evaluator.parameters)
            return computation.log(10, arg1)
        } else if state.arguments.count == 2 {
            let args = try state.defaultArguments()
            let arg1 = args[0]
            let arg2 = args[1]
            guard arg1.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange) }
            guard !arg2.isNegative else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
            let computation = Computation.shell(state.evaluator.parameters)
            return computation.log(arg1, arg2)
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
    })
    
    public static let loge = Function(name: "ln", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard !arg1.isNegative else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.ln()
    })
    
    public static let log2 = Function(names: ["log2", "lb"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard !arg1.isNegative else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.log(2, arg1)
    })

    
    public static let exponential = Function(name: "exp", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.exp()
    })
    
    public static let abs = Function(name: "abs", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return arg1.magnitude
    })
    
    public static let percent = Function(name: "percent", evaluator: { state throws -> Result in
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
        
        return numeric.value * percent
    })
    
    // MARK: - Bitwise functions
    
    public static let and = Function(name: "and", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(arg1.numerator & arg2.numerator)
    })
    
    public static let or = Function(name: "or", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(arg1.numerator | arg2.numerator)
    })
    
    public static let not = Function(name: "not", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(~arg1.numerator)
    })
    
    public static let xor = Function(name: "xor", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(arg1.numerator ^ arg2.numerator)
    })
    
    public static let rshift = Function(name: "rshift", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(arg1.numerator >> arg2.numerator)
    })
    
    public static let lshift = Function(name: "lshift", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        guard arg1.isInteger, arg2.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        return BigDouble(arg1.numerator << arg2.numerator)
    })
    
    // MARK: - Aggregate functions
    
    public static let average = Function(names: ["average", "avg", "mean"], evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let value = try sum.evaluator(state)
        guard let numeric = value as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return numeric.value / BigDouble(state.arguments.count)
    })
    
    public static let sum = Function(names: ["sum", "∑"], evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble(0)
        for arg in state.arguments {
            value += (try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult)?.value ?? 0
        }
        return value
    })
    
    public static let product = Function(names: ["product", "∏"], evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble(1)
        for arg in state.arguments {
            value *= (try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult)?.value ?? 1
        }
        return value
    })
    
    public static let count = Function(name: "count", evaluator: { state throws -> Result in
        return BigDouble(state.arguments.count)
    })
    
    public static let minimum = Function(name: "min", evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble.infinity
        for arg in state.arguments {
            guard let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range) }
            
            value = min(value, argValue.value)
        }
        return value
    })
    
    public static let maximum = Function(name: "max", evaluator: { state throws -> Result in
        guard state.arguments.count > 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var value = BigDouble.negativeInfinity
        for arg in state.arguments {
            guard let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range) }
            value = max(value, argValue.value)
        }
        return value
    })
    
    public static let median = Function(name: "median", evaluator: { state throws -> Result in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var evaluated = [BigDouble]()
        for arg in state.arguments {
            guard let argValue = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range) }
            evaluated.append(argValue.value)
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
    
    public static let stddev = Function(name: "stddev", evaluator: { state throws -> Result in
        guard state.arguments.count >= 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        guard let avg = try average.evaluator(state) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        var stddev = BigDouble.zero
        for arg in state.arguments {
            guard let value = try state.evaluator.evaluate(arg, substitutions: state.substitutions) as? NumericResult else { throw MathParserError(kind: .invalidArguments, range: arg.range)}
            let diff = avg.value - value.value
            stddev += (diff * diff)
        }
        
        return (stddev / BigDouble(state.arguments.count)).sqrt
    })
    
    public static let ceiling = Function(name: "ceil", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return ceil(arg1)
    })
    
    public static let truncation = Function(names: ["floor", "trunc"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return floor(arg1)
    })
    
    // MARK: - Trigonometric functions
    
    public static let sine = Function(name: "sin", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let angle = Function._dtor(arg1, evaluator: state.evaluator)
        let computation = Computation(angle, state.evaluator.parameters)
        return computation.sin()
    })
    
    public static let cosine = Function(name: "cos", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let angle = Function._dtor(arg1, evaluator: state.evaluator)
        let computation = Computation(angle, state.evaluator.parameters)
        return computation.cos()
    })
    
    public static let tangent = Function(name: "tan", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let angle = Function._dtor(arg1, evaluator: state.evaluator)
        let computation = Computation(angle, state.evaluator.parameters)
        return computation.tan()
    })
    
    /*public static let asin = Function(names: ["asin", "sin⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.asin(arg1), evaluator: state.evaluator)
    })
    
    public static let acos = Function(names: ["acos", "cos⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.acos(arg1), evaluator: state.evaluator)
    })
    
    public static let atan = Function(names: ["atan", "tan⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan(arg1), evaluator: state.evaluator)
    })
    
    public static let atan2 = Function(name: "atan2", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        let arg2 = try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        return Function._rtod(Darwin.atan2(arg1, arg2), evaluator: state.evaluator)
    })*/
    
    public static let csc = Function(name: "csc", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sec = Function(name: "sec", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotan = Function(name: "cotan", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = tan(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    /*public static let acsc = Function(names: ["acsc", "csc⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.asin(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let asec = Function(names: ["asec", "sec⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.acos(1.0 / arg1), evaluator: state.evaluator)
    })
    
    public static let acotan = Function(names: ["acotan", "cotan⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let arg1 = try state.evaluator.evaluate(state.arguments[0], substitutions: state.substitutions)
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return Function._rtod(Darwin.atan(1.0 / arg1), evaluator: state.evaluator)
    })
    */
    // MARK: - Hyperbolic trigonometric functions
    
    public static let sineh = Function(name: "sinh", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.sinh()
    })
    
    public static let cosineh = Function(name: "cosh", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.cosh()
    })
    
    public static let tangenth = Function(name: "tanh", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.tanh()
    })
    
    public static let asinh = Function(names: ["asinh", "arsinh", "sinh⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let c1 = Computation((arg1 ** 2) + 1, state.evaluator.parameters)
        let c2 = Computation(c1.sqrt(), state.evaluator.parameters)
        return c2.ln()
    })
    
    public static let acosh = Function(names: ["acosh", "arcosh", "cosh⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let c1 = Computation((arg1 ** 2) - 1, state.evaluator.parameters)
        let c2 = Computation(c1.sqrt(), state.evaluator.parameters)
        return c2.ln()
    })
    
    public static let atanh = Function(names: ["atanh", "artanh", "tanh⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let computation = Computation((1 + arg1) / (1 - arg1), state.evaluator.parameters)
        return 0.5 * computation.ln()
    })
    
    public static let csch = Function(name: "csch", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = sinh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let sech = Function(name: "sech", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = cosh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let cotanh = Function(name: "cotanh", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg = tanh(arg1)
        guard sinArg != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return 1.0 / sinArg
    })
    
    public static let acsch = Function(names: ["acsch", "arcsch", "csch⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        let c1 = Computation((arg1 ** 2).inverse + 1, state.evaluator.parameters)
        let c2 = Computation(arg1.inverse + c1.sqrt(), state.evaluator.parameters)
        return c2.ln()
    })
    
    public static let asech = Function(names: ["asech", "arsech", "sech⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        let c1 = Computation((arg1 ** 2).inverse - 1, state.evaluator.parameters)
        let c2 = Computation(arg1.inverse + c1.sqrt(), state.evaluator.parameters)
        return c2.ln()
    })
    
    public static let acotanh = Function(names: ["acotanh", "arcotanh", "cotanh⁻¹"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        let computation = Computation((1 - arg1) / (1 + arg1), state.evaluator.parameters)
        return 0.5 * computation.ln()
    })
    
    // MARK: - Geometric functions
    
    public static let versin = Function(names: ["versin", "vers", "ver"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return 1.0 - cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let vercosin = Function(names: ["vercosin", "vercos"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return 1.0 + cos(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let coversin = Function(names: ["coversin", "cvs"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return 1.0 - sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let covercosin = Function(names: ["covercosin", "covercos"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return 1.0 + sin(Function._dtor(arg1, evaluator: state.evaluator))
    })
    
    public static let haversin = Function(name: "haversin", evaluator: { state throws -> Result in
        guard let value = try versin.evaluator(state) as? NumericResult else { throw MathParserError(kind: .internalError, range: state.expressionRange) }
        return value.value / 2.0
    })
    
    public static let havercosin = Function(names: ["havercosin", "havercos"], evaluator: { state throws -> Result in
        guard let value = try vercosin.evaluator(state) as? NumericResult else { throw MathParserError(kind: .internalError, range: state.expressionRange) }
        return value.value / 2.0
    })
    
    public static let hacoversin = Function(name: "hacoversin", evaluator: { state throws -> Result in
        guard let value = try coversin.evaluator(state) as? NumericResult else { throw MathParserError(kind: .internalError, range: state.expressionRange) }
        return value.value / 2.0
    })
    
    public static let hacovercosin = Function(names: ["hacovercosin", "hacovercos"], evaluator: { state throws -> Result in
        guard let value = try covercosin.evaluator(state) as? NumericResult else { throw MathParserError(kind: .internalError, range: state.expressionRange) }
        return value.value / 2.0
    })
    
    public static let exsec = Function(name: "exsec", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let cosArg1 = cos(Function._dtor(arg1, evaluator: state.evaluator))
        guard cosArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/cosArg1) - 1.0
    })
    
    public static let excsc = Function(name: "excsc", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg1 = sin(Function._dtor(arg1, evaluator: state.evaluator))
        guard sinArg1 != 0 else { throw MathParserError(kind: .divideByZero, range: state.expressionRange) }
        return (1.0/sinArg1) - 1.0
    })
    
    public static let crd = Function(names: ["crd", "chord"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let sinArg1 = sin(Function._dtor(arg1, evaluator: state.evaluator) / 2.0)
        return 2 * sinArg1
    })
    
    public static let dtor = Function(name: "dtor", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return arg1 / 180.0 * BigDouble.pi
    })
    
    public static let rtod = Function(name: "rtod", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        return arg1 / BigDouble.pi * 180
    })
    
    // MARK: - Constant functions
    
    public static let `true` = Function(names: ["true", "yes"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.true
    })
    
    public static let `false` = Function(names: ["false", "no"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.false
    })
    
    public static let phi = Function(names: ["phi", "ϕ"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.phi
    })
    
    public static let pi = Function(names: ["pi", "π", "tau_2"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi
    })
    
    public static let pi_2 = Function(names: ["pi_2", "tau_4"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi / 2
    })
    
    public static let pi_4 = Function(names: ["pi_4", "tau_8"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.pi / 4
    })
    
    public static let tau = Function(names: ["tau", "τ"], evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.tau
    })
    
    public static let sqrt2 = Function(name: "sqrt2", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble(2).sqrt
    })
    
    public static let e = Function(name: "e", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.e
    })
    
    public static let log2e = Function(name: "log2e", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.log2e
    })
    
    public static let log10e = Function(name: "log10e", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.log10e
    })
    
    public static let ln2 = Function(name: "ln2", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.ln2
    })
    
    public static let ln10 = Function(name: "ln10", evaluator: { state throws -> Result in
        guard state.arguments.count == 0 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        return BigDouble.ln10
    })
    
    // MARK: - Logical Functions

    public static let l_and = Function(name: "l_and", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(arg1), logicalValues.contains(arg2) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return (arg1 == .true && arg2 == .true) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_or = Function(name: "l_or", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(arg1), logicalValues.contains(arg2) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return (arg1 == .true || arg2 == .true) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_not = Function(name: "l_not", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(arg1) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        return arg1 == .false ? BigDouble.true : BigDouble.false
    })
    
    public static let l_eq = Function(name: "l_eq", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 == arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_neq = Function(name: "l_neq", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 != arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_lt = Function(name: "l_lt", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 < arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_gt = Function(name: "l_gt", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 > arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_ltoe = Function(name: "l_ltoe", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 <= arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_gtoe = Function(name: "l_gtoe", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        let arg2 = args[1]
        return (arg1 >= arg2) ? BigDouble.true : BigDouble.false
    })
    
    public static let l_if = Function(names: ["l_if", "if"], evaluator: { state throws -> Result in
        guard state.arguments.count == 3 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(arg1) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}

        if arg1 == .true {
            return try state.evaluator.evaluate(state.arguments[1], substitutions: state.substitutions)
        } else {
            return try state.evaluator.evaluate(state.arguments[2], substitutions: state.substitutions)
        }
    })
    
    // MARK: Custom functions
    public static let fibonacci = Function(names: ["fibonacci", "F"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]
        guard arg1.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        let computation = Computation(arg1, state.evaluator.parameters)
        return computation.fibonacci()
    })
    public static let lucas = Function(names: ["lucas", "L"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let arg1 = args[0]

        guard arg1.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}

        if arg1 == 0 { return BigDouble(2) }
        if arg1 == 1 { return BigDouble(1) }
        
        let c1 = Computation(arg1 - 1, state.evaluator.parameters)
        let c2 = Computation(arg1 + 1, state.evaluator.parameters)
        return c1.fibonacci() + c2.fibonacci()
    })
    public static let catalan = Function(name: "catalan", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]

        if !n.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        
        var product = BigDouble(1)
        var k = n
        while k > 1 {
            product *= (n + k) / k
            k -= 1
        }
        
        return product
    })
    public static let bell = Function(names: ["B", "bell"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]

        if !n.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }

        let computation = Computation(n, state.evaluator.parameters)
        return computation.bell()
    })

    public static let choose = Function(names: ["C", "choose"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if !n.isInteger || !k.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.binomial(n, k)
    })
    public static let variations = Function(name: "P", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if !n.isInteger || !k.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let c1 = Computation(n, state.evaluator.parameters)
        let c2 = Computation(n - k, state.evaluator.parameters)
        return c1.factorial() / c2.factorial()
    })

    public static let l_implication = Function(name: "l_impl", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let p = args[0]
        let q = args[1]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(p), logicalValues.contains(q) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        
        if p == .true, q == .false {
            return BigDouble.false
        } else {
            return BigDouble.true
        }
    })
    public static let l_equivalence = Function(name: "l_eqv", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let p = args[0]
        let q = args[1]

        let logicalValues = [BigDouble.true, BigDouble.false]
        guard logicalValues.contains(p), logicalValues.contains(q) else { throw MathParserError(kind: .argumentNotLogicalValue, range: state.expressionRange )}
        
        return (p == q) ? BigDouble.true : BigDouble.false
    })
    public static let prime = Function(names: ["p", "prime"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        return n.isPrime ? BigDouble.true : BigDouble.false
    })
    public static let digits = Function(name: "digits", evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let s = n.decimalApproximation(to: 12).decimal.replacingOccurrences(of: ".", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: "/", with: "")
        return BigDouble(s.count)
    })
    public static let decimal = Function(name: "decimal", evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let x = args[0]
        let n = args[1]
        guard n.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange )}
        guard n.isPositive else { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange )}
        guard let decimals = Int(n.description) else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange )}
        let expansion = x.decimalApproximation(to: decimals)
        guard var r = BigDouble(expansion.decimal) else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange )}
        r.isApproximation = !expansion.isFinite
        r.decimalPlaces = decimals
        return r
    })
    public static let cycles = Function(names: ["s", "StirlingS1"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if !n.isInteger || !k.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.stirlingCycles(n, k)
    })
    public static let stirling = Function(names: ["S", "StirlingS2"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if !n.isInteger || !k.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.stirlingPartition(n, k)
    })

    public static let lahNumber = Function(names: ["lah"], evaluator: { state throws -> Result in
        guard state.arguments.count == 2 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let k = args[1]

        if !n.isInteger || !k.isInteger { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange ) }
        if n.isNegative || k.isNegative { throw MathParserError(kind: .argumentNotPositive, range: state.expressionRange ) }
        let computation = Computation.shell(state.evaluator.parameters)
        return computation.lah(n, k)
    })
    public static let arithmeticDerivative = Function(names: ["derivative"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        let computation = Computation(n, state.evaluator.parameters)
        return computation.derivative()
    })
    
    public static let factor = Function(names: ["factor"], evaluator: { state throws -> Result in
        guard state.arguments.count == 1 else { throw MathParserError(kind: .invalidArguments, range: state.expressionRange) }
        
        let args = try state.defaultArguments()
        let n = args[0]
        guard n.isInteger else { throw MathParserError(kind: .argumentNotInteger, range: state.expressionRange) }
        var factorization = Factorization(n.integer)
        factorization.factor()
        return factorization
    })



    // MARK: Overrides
    public static let thermalOverride = Function(name: "thermalOverride", evaluator: { state throws -> Result in
        if state.arguments.count == 0 {
            return Preferences.shared.thermalOverride ? BigDouble.true : BigDouble.false
        } else if state.arguments.count == 1 {
            let value = try state.defaultArguments()[0]
            
            let flag = value == BigDouble.true
            Preferences.shared.thermalOverride = flag
            return flag ? BigDouble.true : BigDouble.false
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
        
    })
    public static let irrationalFunctionOverride = Function(name: "irrationalFunctionOverride", evaluator: { state throws -> Result in
        if state.arguments.count == 0 {
            return Preferences.shared.thermalOverride ? BigDouble.true : BigDouble.false
        } else if state.arguments.count == 1 {
            let value = try state.defaultArguments()[0]

            let flag = value == BigDouble.true
            Preferences.shared.irrationalFunctionOverride = flag
            return flag ? BigDouble.true : BigDouble.false
        } else {
            throw MathParserError(kind: .invalidArguments, range: state.expressionRange)
        }
        
    })
}
