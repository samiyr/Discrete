//
//  FunctionsTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 29/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

class FunctionsTableViewController: UITableViewController {

    let groups = ["Symbols", "Arithmetic", "Discrete functions", "Basic functions", "Elementary functions", "Trigonometric functions", "Inverse trigonometric functions", "Hyperbolic functions", "Inverse hyperbolic functions", "Esoteric trig functions", "Statistical functions", "Integer sequences", "Logical operators", "Mathematical constants"]
    let symbols = [naturalSymbol, integerSymbol, rationalSymbol, realSymbol, listSymbol]
    let arithmetic = [add, subtraction, multiply, division, exponentiation, modularExponentiation]
    let discrete = [factorial, doubleFactorial, tetriation, binomial, variations, primality]
    let binary = [abs, percent, modulus, ceil, floor, min, max]
    let elementary = [sqrt, cubeRoot, root, exp, ln, lg, lb, log]
    let trig = [sin, cos, tan, sec, csc, cotan]
    let inverseTrig = [asin, acos, atan, asec, acsc, acotan]
    let hyperbolic = [sinh, cosh, tanh, sech, csch, cotanh]
    let area = [asinh, acosh, atanh, asech, acsch, acotanh]
    let esotericTrig = [versin]
    let stat = [sum, product, avg, sd]
    let sequences = [fibonacci, lucas, catalan, bell]
    let logic = [eq, neq, greater, greaterEq, less, lessEq, and, or, xor, implication, equivalence, lshift, rshift, truth, falsehood]
    let const = [pi, tau, e, phi]
    
    var functions = [[FunctionDetail]]()
    
    override func viewDidLoad() {
        functions = [symbols, arithmetic, discrete, sequences, binary, elementary, trig, inverseTrig, hyperbolic, area, esotericTrig, stat, logic, const]
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
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

struct FunctionDetail {
    let name: String
    let description: String
}

let naturalSymbol = FunctionDetail(name: "n", description: "Natural number (ℕ)")
let integerSymbol = FunctionDetail(name: "l", description: "Integer (ℤ)")
let rationalSymbol = FunctionDetail(name: "q", description: "Rational number (ℚ)")
let realSymbol = FunctionDetail(name: "x", description: "Real number (ℝ)")
let listSymbol = FunctionDetail(name: "x,y,z,...", description: "List of numbers")

let add = FunctionDetail(name: "+", description: "Addition")
let subtraction = FunctionDetail(name: "-", description: "Subtraction")
let multiply = FunctionDetail(name: "*", description: "Multiplication")
let division = FunctionDetail(name: "/", description: "Division")
let exponentiation = FunctionDetail(name: "**", description: "Exponentiation")
let modularExponentiation = FunctionDetail(name: "pow(x,n,k)", description: "Modular exponentiation (mod k)")
let factorial = FunctionDetail(name: "!", description: "Factorial")
let doubleFactorial = FunctionDetail(name: "!!", description: "Double factorial")
let tetriation = FunctionDetail(name: "tetr(n,k), tetriation(n,k)", description: "Tetriation, hyper-4, ⁿk, n↑↑k")
let binomial = FunctionDetail(name: "C(n,k), choose(n,k)", description: "Binomial coefficient")
let variations = FunctionDetail(name: "P(n,k)", description: "Variations, partial permutations, k-permutations of n")
let primality = FunctionDetail(name: "p(n), prime(n)", description: "Primality")

let sqrt = FunctionDetail(name: "sqrt(x)", description: "Square root")
let cubeRoot = FunctionDetail(name: "cuberoot(x)", description: "Cube root")
let root = FunctionDetail(name: "root(n,x)", description: "Root")

let abs = FunctionDetail(name: "abs(x)", description: "Absolute value")
let percent = FunctionDetail(name: "%", description: "Percent")
let modulus = FunctionDetail(name: "x % y, mod(x,y)", description: "Modulo")
let ceil = FunctionDetail(name: "ceil(x)", description: "Ceiling")
let floor = FunctionDetail(name: "floor(x)", description: "Floor")
let min = FunctionDetail(name: "min(x,y)", description: "Minimum")
let max = FunctionDetail(name: "max(x,y)", description: "Maximum")

let sin = FunctionDetail(name: "sin(x)", description: "Sine")
let cos = FunctionDetail(name: "cos(x)", description: "Cosine")
let tan = FunctionDetail(name: "tan(x)", description: "Tangent")
let asin = FunctionDetail(name: "arcsin(x)", description: "Arcus sine")
let acos = FunctionDetail(name: "arccos(x)", description: "Arcus cosine")
let atan = FunctionDetail(name: "arctan(x)", description: "Arcus tangent")
let sec = FunctionDetail(name: "sec(x)", description: "Secant")
let csc = FunctionDetail(name: "csc(x)", description: "Cosecant")
let cotan = FunctionDetail(name: "cotan(x)", description: "Cotangent")
let asec = FunctionDetail(name: "arcsec(x)", description: "Arcus secant")
let acsc = FunctionDetail(name: "arccsc(x)", description: "Arcus cosecant")
let acotan = FunctionDetail(name: "acotan(x)", description: "Arcus cotangent")

let sinh = FunctionDetail(name: "sinh(x)", description: "Hyperbolic sine")
let cosh = FunctionDetail(name: "cosh(x)", description: "Hyperbolic cosine")
let tanh = FunctionDetail(name: "tanh(x)", description: "Hyperbolic tangent")
let asinh = FunctionDetail(name: "arsinh(x)", description: "Hyperbolic area sine")
let acosh = FunctionDetail(name: "arcosh(x)", description: "Hyperbolic area cosine")
let atanh = FunctionDetail(name: "artanh(x)", description: "Hyperbolic area tangent")
let sech = FunctionDetail(name: "sech(x)", description: "Hyperbolic secant")
let csch = FunctionDetail(name: "csch(x)", description: "Hyperbolic cosecant")
let cotanh = FunctionDetail(name: "cotanh(x)", description: "Hyperbolic cotangent")
let asech = FunctionDetail(name: "arsech(x)", description: "Hyperbolic area secant")
let acsch = FunctionDetail(name: "arcsch(x)", description: "Hyperbolic area cosecant")
let acotanh = FunctionDetail(name: "arcotanh(x)", description: "Hyperbolic area cotangent")

let versin = FunctionDetail(name: "versin(x)", description: "Versine")

let exp = FunctionDetail(name: "exp(x)", description: "Exponential")
let ln = FunctionDetail(name: "ln(x)", description: "Natural logarithm")
let lg = FunctionDetail(name: "log(x), lg(x)", description: "10-base logarithm")
let lb = FunctionDetail(name: "lb(x)", description: "Binary logarithm")
let log = FunctionDetail(name: "log(n,x)", description: "Logarithm")

let sum = FunctionDetail(name: "sum(x,y,z,...)", description: "Sum")
let product = FunctionDetail(name: "product(x,y,z,...)", description: "Product")
let avg = FunctionDetail(name: "avg(x,y,z,...)", description: "Average")
let sd = FunctionDetail(name: "stddev(x,y,z,...)", description: "Standard deviation")

let pi = FunctionDetail(name: "pi", description: "Pi (𝜋)")
let tau = FunctionDetail(name: "tau", description: "Tau (𝝉)")
let e = FunctionDetail(name: "e", description: "Euler's number")
let phi = FunctionDetail(name: "phi", description: "Golden ratio (𝜑)")

let fibonacci = FunctionDetail(name: "F(n), fibonacci(n)", description: "Fibonacci sequence")
let lucas = FunctionDetail(name: "L(n), lucas(n)", description: "Lucas sequence")
let catalan = FunctionDetail(name: "catalan(n)", description: "Catalan sequence")
let bell = FunctionDetail(name: "B(n), bell(n)", description: "Bell sequence\nTable values up to 30\nComputationally feasible up to around 33")

let and = FunctionDetail(name: "&&", description: "Logical AND (∧)")
let or = FunctionDetail(name: "||", description: "Logical OR (∨)")
let xor = FunctionDetail(name: "^", description: "Logical XOR")
let implication = FunctionDetail(name: "->", description: "Implication (⇒)")
let equivalence = FunctionDetail(name: "<->", description: "Equivalence (⇔)")
let lshift = FunctionDetail(name: ">>", description: "Right bit shift")
let rshift = FunctionDetail(name: "<<", description: "Left bit shift")
let eq = FunctionDetail(name: "=", description: "Equals")
let neq = FunctionDetail(name: "≠", description: "Not equal")
let greater = FunctionDetail(name: ">", description: "Greater than")
let greaterEq = FunctionDetail(name: "≥", description: "Greater than or equal")
let less = FunctionDetail(name: "<", description: "Less than")
let lessEq = FunctionDetail(name: "≤", description: "Less than or equal")
let truth = FunctionDetail(name: "true", description: "True (1)")
let falsehood = FunctionDetail(name: "false", description: "False (0)")
