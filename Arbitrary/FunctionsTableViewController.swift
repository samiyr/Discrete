//
//  FunctionsTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 29/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit
import SafariServices

class FunctionsTableViewController: UITableViewController {

    let groups = ["Symbols",
                  "Arithmetic",
                  "Discrete functions",
                  "Integer sequences",
                  "Properties",
                  "Logical operators",
                  "Bitwise operators",
                  "Statistical functions",
                  "Elementary functions",
                  "Trigonometric functions",
                  "Inverse trigonometric functions",
                  "Hyperbolic functions",
                  "Inverse hyperbolic functions",
                  "Geometric functions",
                  "Mathematical constants"]
    let symbols = [naturalSymbol, integerSymbol, rationalSymbol, realSymbol, listSymbol]
    let arithmetic = [add, subtraction, multiply, division, exponentiation, modularExponentiation]
    let discrete = [factorial, doubleFactorial, tetriation, binomial, variations, stirlingCycles, stirlingPartitions, lah]
    let binary = [abs, percent, modulus, ceil, floor, min, max, digits, primality]
    let elementary = [sqrt, cubeRoot, root, exp, ln, lg, lb, log]
    let trig = [sin, cos, tan, sec, csc, cotan]
    let inverseTrig = [asin, acos, atan, asec, acsc, acotan]
    let hyperbolic = [sinh, cosh, tanh, sech, csch, cotanh]
    let area = [asinh, acosh, atanh, asech, acsch, acotanh]
    let esotericTrig = [versin, vercosin, coversin, covercosin, haversin, havercosin, hacoversin, hacovercosin, exsec, excsc, crd]
    let stat = [sum, product, avg, sd]
    let sequences = [fibonacci, lucas, catalan, bell]
    let logic = [eq, neq, greater, greaterEq, less, lessEq, and, or, xor, implication, equivalence, truth, falsehood]
    let bitwise = [bitNot, bitAnd, bitOr, lshift, rshift]
    let const = [pi, tau, e, phi, sqrt2, omega]
    
    var functions = [[FunctionDetail]]()
    
    override func viewDidLoad() {
        functions = [symbols, arithmetic, discrete, sequences, binary, logic, bitwise, stat, elementary, trig, inverseTrig, hyperbolic, area, esotericTrig, const]
        super.viewDidLoad()
    }
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.navigationItem.title = "Reference"
        super.viewWillAppear(animated)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return groups.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return functions[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let function = functions[indexPath.section][indexPath.row]
        cell.textLabel?.text = function.name
        cell.detailTextLabel?.text = function.description
        cell.accessoryType = function.url == nil ? .none : .disclosureIndicator
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let function = functions[indexPath.section][indexPath.row]
        if let urlString = function.url, let url = URL(string: urlString) {
            let safari = SFSafariViewController(url: url)
            safari.preferredControlTintColor = UIApplication.shared.keyWindow?.tintColor
            present(safari, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

struct FunctionDetail {
    let name: String
    let description: String
    let url: String?
}

let naturalSymbol = FunctionDetail(name: "n", description: "Natural number (ℕ)", url: "https://en.m.wikipedia.org/wiki/Natural_number")
let integerSymbol = FunctionDetail(name: "l", description: "Integer (ℤ)", url: "https://en.m.wikipedia.org/wiki/Integer")
let rationalSymbol = FunctionDetail(name: "q", description: "Rational number (ℚ)", url: "https://en.m.wikipedia.org/wiki/Rational_number")
let realSymbol = FunctionDetail(name: "x", description: "Real number (ℝ)", url: "https://en.m.wikipedia.org/wiki/Real_number")
let listSymbol = FunctionDetail(name: "x,y,z,...", description: "List of numbers", url: nil)

let add = FunctionDetail(name: "+", description: "Addition", url: "https://en.m.wikipedia.org/wiki/Addition")
let subtraction = FunctionDetail(name: "-", description: "Subtraction", url: "https://en.m.wikipedia.org/wiki/Subtraction")
let multiply = FunctionDetail(name: "*", description: "Multiplication", url: "https://en.m.wikipedia.org/wiki/Multiplication")
let division = FunctionDetail(name: "/", description: "Division", url: "https://en.m.wikipedia.org/wiki/Division_(mathematics)")
let exponentiation = FunctionDetail(name: "**", description: "Exponentiation", url: "https://en.m.wikipedia.org/wiki/Exponentiation")
let modularExponentiation = FunctionDetail(name: "pow(x,n,k)", description: "Modular exponentiation (mod k)", url: "https://en.m.wikipedia.org/wiki/Modular_exponentiation")
let factorial = FunctionDetail(name: "!", description: "Factorial", url: "https://en.m.wikipedia.org/wiki/Factorial")
let doubleFactorial = FunctionDetail(name: "!!", description: "Double factorial", url: "https://en.m.wikipedia.org/wiki/Double_factorial")
let tetriation = FunctionDetail(name: "tetr(n,k), tetriation(n,k)", description: "Tetriation, hyper-4, ⁿk, n↑↑k", url: "https://en.m.wikipedia.org/wiki/Tetration")
let binomial = FunctionDetail(name: "C(n,k), choose(n,k)", description: "Binomial coefficient", url: "https://en.m.wikipedia.org/wiki/Binomial_coefficient")
let variations = FunctionDetail(name: "P(n,k)", description: "Variations, partial permutations, k-permutations of n", url: "https://en.m.wikipedia.org/wiki/Permutation#k-permutations_of_n")
let stirlingCycles = FunctionDetail(name: "s(n,k), StirlingS1(n,k)", description: "Stirling number of the 1st kind", url: "https://en.m.wikipedia.org/wiki/Stirling_numbers_of_the_first_kind")
let stirlingPartitions = FunctionDetail(name: "S(n,k), StirlingS2(n,k)", description: "Stirling number of the 2nd kind", url: "https://en.m.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind")
let lah = FunctionDetail(name: "lah(n,k)", description: "Lah number", url: "https://en.m.wikipedia.org/wiki/Lah_number")
let primality = FunctionDetail(name: "p(n), prime(n)", description: "Primality", url: "https://en.m.wikipedia.org/wiki/Prime_number")

let sqrt = FunctionDetail(name: "sqrt(x)", description: "Square root", url: "https://en.m.wikipedia.org/wiki/Prime_number")
let cubeRoot = FunctionDetail(name: "cuberoot(x)", description: "Cube root", url: "https://en.m.wikipedia.org/wiki/Cube_root")
let root = FunctionDetail(name: "root(n,x)", description: "Root", url: "https://en.m.wikipedia.org/wiki/Nth_root")

let abs = FunctionDetail(name: "abs(x)", description: "Absolute value", url: "https://en.m.wikipedia.org/wiki/Absolute_value")
let percent = FunctionDetail(name: "%", description: "Percent", url: "https://en.m.wikipedia.org/wiki/Percentage")
let modulus = FunctionDetail(name: "x % y, mod(x,y)", description: "Modulo", url: "https://en.m.wikipedia.org/wiki/Modulo_operation")
let ceil = FunctionDetail(name: "ceil(x)", description: "Ceiling", url: "https://en.m.wikipedia.org/wiki/Floor_and_ceiling_functions")
let floor = FunctionDetail(name: "floor(x)", description: "Floor", url: "https://en.m.wikipedia.org/wiki/Floor_and_ceiling_functions")
let min = FunctionDetail(name: "min(x,y)", description: "Minimum", url: nil)
let max = FunctionDetail(name: "max(x,y)", description: "Maximum", url: nil)
let digits = FunctionDetail(name: "digits(x)", description: "Number of digits", url: nil)

let sin = FunctionDetail(name: "sin(x)", description: "Sine", url: "https://en.m.wikipedia.org/wiki/Sine")
let cos = FunctionDetail(name: "cos(x)", description: "Cosine", url: "https://en.m.wikipedia.org/wiki/Cosine")
let tan = FunctionDetail(name: "tan(x)", description: "Tangent", url: "https://en.m.wikipedia.org/wiki/Trigonometric_functions#tan")
let asin = FunctionDetail(name: "arcsin(x)", description: "Arcsine", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")
let acos = FunctionDetail(name: "arccos(x)", description: "Arccosine", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")
let atan = FunctionDetail(name: "arctan(x)", description: "Arctangent", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")
let sec = FunctionDetail(name: "sec(x)", description: "Secant", url: "https://en.m.wikipedia.org/wiki/Trigonometric_functions#sec")
let csc = FunctionDetail(name: "csc(x)", description: "Cosecant", url: "https://en.m.wikipedia.org/wiki/Trigonometric_functions#csc")
let cotan = FunctionDetail(name: "cotan(x)", description: "Cotangent", url: "https://en.m.wikipedia.org/wiki/Trigonometric_functions#cotan")
let asec = FunctionDetail(name: "arcsec(x)", description: "Arcsecant", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")
let acsc = FunctionDetail(name: "arccsc(x)", description: "Arccosecant", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")
let acotan = FunctionDetail(name: "acotan(x)", description: "Arccotangent", url: "https://en.m.wikipedia.org/wiki/Inverse_trigonometric_functions")

let sinh = FunctionDetail(name: "sinh(x)", description: "Hyperbolic sine", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let cosh = FunctionDetail(name: "cosh(x)", description: "Hyperbolic cosine", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let tanh = FunctionDetail(name: "tanh(x)", description: "Hyperbolic tangent", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let asinh = FunctionDetail(name: "arsinh(x)", description: "Area hyperbolic sine", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")
let acosh = FunctionDetail(name: "arcosh(x)", description: "Area hyperbolic cosine", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")
let atanh = FunctionDetail(name: "artanh(x)", description: "Area hyperbolic tangent", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")
let sech = FunctionDetail(name: "sech(x)", description: "Hyperbolic secant", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let csch = FunctionDetail(name: "csch(x)", description: "Hyperbolic cosecant", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let cotanh = FunctionDetail(name: "cotanh(x)", description: "Hyperbolic cotangent", url: "https://en.m.wikipedia.org/wiki/Hyperbolic_function")
let asech = FunctionDetail(name: "arsech(x)", description: "Area hyperbolic secant", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")
let acsch = FunctionDetail(name: "arcsch(x)", description: "Area hyperbolic cosecant", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")
let acotanh = FunctionDetail(name: "arcotanh(x)", description: "Area hyperbolic cotangent", url: "https://en.m.wikipedia.org/wiki/Inverse_hyperbolic_functions")

let versin = FunctionDetail(name: "versin(x)", description: "Versine", url: "https://en.m.wikipedia.org/wiki/Versine")
let vercosin = FunctionDetail(name: "vercos(x)", description: "Vercosine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let coversin = FunctionDetail(name: "coversin(x)", description: "Coversine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let covercosin = FunctionDetail(name: "covercos(x)", description: "Covercosine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let haversin = FunctionDetail(name: "haversin(x)", description: "Haversine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let havercosin = FunctionDetail(name: "havercos(x)", description: "Havercosine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let hacoversin = FunctionDetail(name: "hacoversin(x)", description: "Hacoversine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let hacovercosin = FunctionDetail(name: "hacovercos(x)", description: "Hacovercosine", url: "https://en.m.wikipedia.org/wiki/Versine#Overview")
let exsec = FunctionDetail(name: "exsec(x)", description: "Exsecant", url: "https://en.m.wikipedia.org/wiki/Exsecant#Exsecant")
let excsc = FunctionDetail(name: "excsc(x)", description: "Excosecant", url: "https://en.m.wikipedia.org/wiki/Exsecant#Excosecant")
let crd = FunctionDetail(name: "crd(x)", description: "Chord", url: "https://en.m.wikipedia.org/wiki/Chord_(geometry)#In_trigonometry")


let exp = FunctionDetail(name: "exp(x)", description: "Exponential", url: "https://en.m.wikipedia.org/wiki/Exponential_function")
let ln = FunctionDetail(name: "ln(x)", description: "Natural logarithm", url: "https://en.m.wikipedia.org/wiki/Exponential_function")
let lg = FunctionDetail(name: "log(x), lg(x)", description: "Common logarithm (base 10)", url: "https://en.m.wikipedia.org/wiki/Common_logarithm")
let lb = FunctionDetail(name: "lb(x)", description: "Binary logarithm", url: "https://en.m.wikipedia.org/wiki/Binary_logarithm")
let log = FunctionDetail(name: "log(n,x)", description: "Logarithm", url: "https://en.m.wikipedia.org/wiki/Logarithm")

let sum = FunctionDetail(name: "sum(x,y,z,...)", description: "Sum", url: "https://en.m.wikipedia.org/wiki/Summation")
let product = FunctionDetail(name: "product(x,y,z,...)", description: "Product", url: "https://en.m.wikipedia.org/wiki/Product_(mathematics)#Product_of_sequences")
let avg = FunctionDetail(name: "avg(x,y,z,...)", description: "Mean, average", url: "https://en.m.wikipedia.org/wiki/Arithmetic_mean")
let sd = FunctionDetail(name: "stddev(x,y,z,...)", description: "Standard deviation", url: "https://en.m.wikipedia.org/wiki/Standard_deviation")

let pi = FunctionDetail(name: "pi", description: "Pi (𝜋)", url: "https://en.m.wikipedia.org/wiki/Pi")
let tau = FunctionDetail(name: "tau", description: "Tau (𝝉)", url: "https://en.m.wikipedia.org/wiki/Turn_(geometry)#Tau_proposals")
let e = FunctionDetail(name: "e", description: "Euler's number", url: "https://en.m.wikipedia.org/wiki/E_(mathematical_constant)")
let phi = FunctionDetail(name: "phi", description: "Golden ratio (𝜑)", url: "https://en.m.wikipedia.org/wiki/E_(mathematical_constant)")
let sqrt2 = FunctionDetail(name: "sqrt2", description: "Pythagoras' constant (√2)", url: "https://en.m.wikipedia.org/wiki/Square_root_of_2")
let omega = FunctionDetail(name: "W1", description: "Omega constant (Ω)", url: "https://en.m.wikipedia.org/wiki/Omega_constant")

let fibonacci = FunctionDetail(name: "F(n), fibonacci(n)", description: "Fibonacci number", url: "https://en.m.wikipedia.org/wiki/Fibonacci_number")
let lucas = FunctionDetail(name: "L(n), lucas(n)", description: "Lucas number", url: "https://en.m.wikipedia.org/wiki/Lucas_number")
let catalan = FunctionDetail(name: "catalan(n)", description: "Catalan number", url: "https://en.m.wikipedia.org/wiki/Catalan_number")
let bell = FunctionDetail(name: "B(n), bell(n)", description: "Bell number", url: "https://en.m.wikipedia.org/wiki/Bell_number")

let not = FunctionDetail(name: "!, ¬", description: "Logical NOT (¬)", url: "https://en.m.wikipedia.org/wiki/Negation")
let and = FunctionDetail(name: "&&", description: "Logical AND (∧)", url: "https://en.m.wikipedia.org/wiki/Logical_conjunction")
let or = FunctionDetail(name: "||", description: "Logical OR (∨)", url: "https://en.m.wikipedia.org/wiki/Logical_disjunction")
let implication = FunctionDetail(name: "->", description: "Logical implication (⇒)", url: "https://en.m.wikipedia.org/wiki/Material_conditional")
let equivalence = FunctionDetail(name: "<->", description: "Logical equivalence (⇔)", url: "https://en.m.wikipedia.org/wiki/If_and_only_if")
let bitNot = FunctionDetail(name: "~", description: "Bitwise NOT", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#NOT")
let bitAnd = FunctionDetail(name: "&", description: "Bitwise AND", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#AND")
let bitOr = FunctionDetail(name: "|", description: "Bitwise OR", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#OR")
let xor = FunctionDetail(name: "^", description: "Bitwise XOR", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#XOR")
let lshift = FunctionDetail(name: ">>", description: "Bitwise right shift", url: "https://en.m.wikipedia.org/wiki/Arithmetic_shift")
let rshift = FunctionDetail(name: "<<", description: "Bitwise left shift", url: "https://en.m.wikipedia.org/wiki/Arithmetic_shift")
let eq = FunctionDetail(name: "=", description: "Equals", url: nil)
let neq = FunctionDetail(name: "≠", description: "Not equal", url: nil)
let greater = FunctionDetail(name: ">", description: "Greater than", url: nil)
let greaterEq = FunctionDetail(name: "≥", description: "Greater than or equal", url: nil)
let less = FunctionDetail(name: "<", description: "Less than", url: nil)
let lessEq = FunctionDetail(name: "≤", description: "Less than or equal", url: nil)
let truth = FunctionDetail(name: "true", description: "True (1)", url: nil)
let falsehood = FunctionDetail(name: "false", description: "False (0)", url: nil)
