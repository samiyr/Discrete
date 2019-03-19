//
//  ComputationTests.swift
//  ComputationTests
//
//  Created by Sami Yrjänheikki on 21/02/2019.
//  Copyright © 2019 Sami Yrjänheikki. All rights reserved.
//

import XCTest
@testable import Computation

class ComputationTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddition() {
        // Integer addition
        XCTAssertEqual(BigInt(2) + BigInt(5), BigInt(7))
        XCTAssertEqual(BigInt(0) + BigInt(1), BigInt(1))
        XCTAssertEqual(BigInt(-5) + BigInt(7), BigInt(2))
        XCTAssertEqual(BigInt(-5) + BigInt(3), BigInt(-2))
        XCTAssertEqual(BigInt(-5) + BigInt(5), BigInt(0))
        
        // Fraction addition
        XCTAssertEqual(BigInt(1, 2) + BigInt(1, 3), BigInt(5, 6))
        XCTAssertEqual(BigInt(-2, 3) + BigInt(1, 3), BigInt(-1, 3))
        XCTAssertEqual(BigInt(1, 3) + BigInt(1, 3) + BigInt(1, 3), BigInt(1))
    }
    func testSubtraction() {
        // Integer subtraction
        XCTAssertEqual(BigInt(2) - BigInt(5), BigInt(-3))
        XCTAssertEqual(BigInt(0) - BigInt(1), BigInt(-1))
        XCTAssertEqual(BigInt(-5) - BigInt(7), BigInt(-12))
        XCTAssertEqual(BigInt(-5) - BigInt(3), BigInt(-8))
        XCTAssertEqual(BigInt(-5) - BigInt(-7), BigInt(2))
        
        // Fraction subtraction
        XCTAssertEqual(BigInt(1, 2) - BigInt(1, 3), BigInt(1, 6))
        XCTAssertEqual(BigInt(-2, 3) - BigInt(1, 3), BigInt(-1))
        XCTAssertEqual(BigInt(1) - BigInt(1, 3) - BigInt(1, 3), BigInt(1,3))
        
        // Irrational subtraction
        XCTAssertEqual(BigInt.pi - BigInt.pi, BigInt(0))
    }

    func testFactorialPerformance() {
        self.measure {
            BigInt(1000).factorial
        }
    }

}
