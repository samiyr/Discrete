//
//  FunctionsTableViewController.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 29/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

class FunctionsTableViewController: UITableViewController {

    let groups = ["Arithmetic",
                  "Discrete functions",
                  "Integer sequences",
                  "Properties",
                  "Logical operators",
                  "Bitwise operators",
                  "Statistical functions"]

    let arithmetic = [add, subtraction, multiply, division, exponentiation, modularExponentiation]
    let discrete = [factorial, doubleFactorial, tetriation, binomial, variations, stirlingCycles, stirlingPartitions, lah, derivative]
    let binary = [abs, percent, modulus, gcd, min, max, digits, primality]
    let stat = [sum, product]
    let sequences = [fibonacci, lucas, catalan, bell]
    let logic = [eq, neq, greater, greaterEq, less, lessEq, and, or, xor, implication, equivalence, truth, falsehood]
    let bitwise = [bitNot, bitAnd, bitOr, lshift, rshift]
    
    var functions = [[FunctionDetail]]()
    
    override func viewDidLoad() {
        functions = [arithmetic, discrete, sequences, binary, logic, bitwise, stat]
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
        cell.textLabel?.text = function.short
        cell.detailTextLabel?.text = function.name
        return cell
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return groups[section]
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let function = functions[indexPath.section][indexPath.row]
        let detail = storyboard?.instantiateViewController(withIdentifier: "FunctionDetail") as! FunctionDetailTableViewController
        detail.function = function
        navigationController?.pushViewController(detail, animated: true)
    }
}

struct FunctionDetail {
    let name: String
    let short: String
    let description: String
    let url: String?
}

let add = FunctionDetail(name: "+", short: "Addition", description: "Addition", url: "https://en.m.wikipedia.org/wiki/Addition")
let subtraction = FunctionDetail(name: "-", short: "Subtraction", description: "Subtraction", url: "https://en.m.wikipedia.org/wiki/Subtraction")
let multiply = FunctionDetail(name: "*", short: "Multiplication", description: "Multiplication", url: "https://en.m.wikipedia.org/wiki/Multiplication")
let division = FunctionDetail(name: "/", short: "Division", description: "Division", url: "https://en.m.wikipedia.org/wiki/Division_(mathematics)")
let exponentiation = FunctionDetail(name: "**", short: "Exponentiation", description: "Exponentiation", url: "https://en.m.wikipedia.org/wiki/Exponentiation")
let modularExponentiation = FunctionDetail(name: "pow(x,n,k)", short: "Modular exponentiation", description: "Modular exponentiation (mod k)", url: "https://en.m.wikipedia.org/wiki/Modular_exponentiation")
let factorial = FunctionDetail(name: "!", short: "Factorial", description: "Factorial", url: "https://en.m.wikipedia.org/wiki/Factorial")
let doubleFactorial = FunctionDetail(name: "!!", short: "Double factorial", description: "Double factorial", url: "https://en.m.wikipedia.org/wiki/Double_factorial")
let tetriation = FunctionDetail(name: "tetr(n,k), tetriation(n,k)", short: "Tetriation", description: "Tetriation, hyper-4, ⁿk, n↑↑k", url: "https://en.m.wikipedia.org/wiki/Tetration")
let binomial = FunctionDetail(name: "C(n,k), choose(n,k)", short: "Binomial coefficient", description: "Binomial coefficient", url: "https://en.m.wikipedia.org/wiki/Binomial_coefficient")
let variations = FunctionDetail(name: "P(n,k)", short: "Variations", description: "Variations, partial permutations, k-permutations of n", url: "https://en.m.wikipedia.org/wiki/Permutation#k-permutations_of_n")
let stirlingCycles = FunctionDetail(name: "s(n,k), StirlingS1(n,k)", short: "Stirling number (1st)", description: "Stirling number of the 1st kind", url: "https://en.m.wikipedia.org/wiki/Stirling_numbers_of_the_first_kind")
let stirlingPartitions = FunctionDetail(name: "S(n,k), StirlingS2(n,k)", short: "Stirling number (2nd)", description: "Stirling number of the 2nd kind", url: "https://en.m.wikipedia.org/wiki/Stirling_numbers_of_the_second_kind")
let lah = FunctionDetail(name: "lah(n,k)", short: "Lah number", description: "Lah number", url: "https://en.m.wikipedia.org/wiki/Lah_number")
let primality = FunctionDetail(name: "p(n), prime(n)", short: "Primality", description: "Primality", url: "https://en.m.wikipedia.org/wiki/Prime_number")
let derivative = FunctionDetail(name: "q', derivative(q)", short: "Derivative", description: "Arithmetic derivative", url: "https://en.m.wikipedia.org/wiki/Arithmetic_derivative")

let abs = FunctionDetail(name: "abs(x)", short: "Absolute value", description: "Absolute value", url: "https://en.m.wikipedia.org/wiki/Absolute_value")
let percent = FunctionDetail(name: "%", short: "Percent", description: "Percent", url: "https://en.m.wikipedia.org/wiki/Percentage")
let modulus = FunctionDetail(name: "x % y, mod(x,y)", short: "Modulo", description: "Modulo", url: "https://en.m.wikipedia.org/wiki/Modulo_operation")
let gcd = FunctionDetail(name: "gcd(n,k)", short: "GCD", description: "Greatest common divisor", url: "https://en.m.wikipedia.org/wiki/Greatest_common_divisor")
let min = FunctionDetail(name: "min(x,y)", short: "Minimum", description: "Minimum", url: nil)
let max = FunctionDetail(name: "max(x,y)", short: "Maximum", description: "Maximum", url: nil)
let digits = FunctionDetail(name: "digits(x)", short: "Digit count", description: "Number of digits", url: nil)

let sum = FunctionDetail(name: "sum(x,y,z,...)", short: "Sum", description: "Sum", url: "https://en.m.wikipedia.org/wiki/Summation")
let product = FunctionDetail(name: "product(x,y,z,...)", short: "Product", description: "Product", url: "https://en.m.wikipedia.org/wiki/Product_(mathematics)#Product_of_sequences")

let fibonacci = FunctionDetail(name: "F(n), fibonacci(n)", short: "Fibonacci number", description: "Fibonacci number", url: "https://en.m.wikipedia.org/wiki/Fibonacci_number")
let lucas = FunctionDetail(name: "L(n), lucas(n)", short: "Lucas number", description: "Lucas number", url: "https://en.m.wikipedia.org/wiki/Lucas_number")
let catalan = FunctionDetail(name: "catalan(n)", short: "Catalan number", description: "Catalan number", url: "https://en.m.wikipedia.org/wiki/Catalan_number")
let bell = FunctionDetail(name: "B(n), bell(n)", short: "Bell number", description: "Bell number", url: "https://en.m.wikipedia.org/wiki/Bell_number")

let not = FunctionDetail(name: "!, ¬", short: "NOT", description: "Logical NOT (¬)", url: "https://en.m.wikipedia.org/wiki/Negation")
let and = FunctionDetail(name: "&&", short: "AND", description: "Logical AND (∧)", url: "https://en.m.wikipedia.org/wiki/Logical_conjunction")
let or = FunctionDetail(name: "||", short: "OR", description: "Logical OR (∨)", url: "https://en.m.wikipedia.org/wiki/Logical_disjunction")
let implication = FunctionDetail(name: "->", short: "Implication", description: "Logical implication (⇒)", url: "https://en.m.wikipedia.org/wiki/Material_conditional")
let equivalence = FunctionDetail(name: "<->", short: "Equivalence", description: "Logical equivalence (⇔)", url: "https://en.m.wikipedia.org/wiki/If_and_only_if")
let bitNot = FunctionDetail(name: "~", short: "Bitwise NOT", description: "Bitwise NOT", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#NOT")
let bitAnd = FunctionDetail(name: "&", short: "Bitwise AND", description: "Bitwise AND", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#AND")
let bitOr = FunctionDetail(name: "|", short: "Bitwise OR", description: "Bitwise OR", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#OR")
let xor = FunctionDetail(name: "^", short: "Bitwise XOR", description: "Bitwise XOR", url: "https://en.m.wikipedia.org/wiki/Bitwise_operation#XOR")
let lshift = FunctionDetail(name: ">>", short: "Right shift", description: "Bitwise right shift", url: "https://en.m.wikipedia.org/wiki/Arithmetic_shift")
let rshift = FunctionDetail(name: "<<", short: "Left shift", description: "Bitwise left shift", url: "https://en.m.wikipedia.org/wiki/Arithmetic_shift")
let eq = FunctionDetail(name: "=", short: "Equals", description: "Equals", url: nil)
let neq = FunctionDetail(name: "≠", short: "Not equal", description: "Not equal", url: nil)
let greater = FunctionDetail(name: ">", short: "Greater than", description: "Greater than", url: nil)
let greaterEq = FunctionDetail(name: "≥", short: "Greater than or equal", description: "Greater than or equal", url: nil)
let less = FunctionDetail(name: "<", short: "Less than", description: "Less than", url: nil)
let lessEq = FunctionDetail(name: "≤", short: "Less than or equal", description: "Less than or equal", url: nil)
let truth = FunctionDetail(name: "true", short: "True", description: "True (1)", url: nil)
let falsehood = FunctionDetail(name: "false", short: "False", description: "False (0)", url: nil)
