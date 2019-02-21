//
//  Preferences.swift
//  Arbitrary
//
//  Created by Sami Yrjänheikki on 29/12/2018.
//  Copyright © 2018 Sami Yrjänheikki. All rights reserved.
//

import UIKit

private let _instance = Preferences()

public class Preferences: NSObject {
    private let queue = DispatchQueue(label: "preferences queue")
    
    public class var shared: Preferences {
        return _instance
    }
    public class var local: UserDefaults {
        return UserDefaults.standard
    }
    public class var cloud: NSUbiquitousKeyValueStore {
        return NSUbiquitousKeyValueStore.default
    }
    
    public enum DisplayMode: Int, Codable {
        case automatic, fractional, decimal
    }
    public enum LargeNumberDisplayMode: Int {
        case automatic, scientific, decimal
    }
    public enum AngleMode: Int {
        case radians, degrees
    }
    public enum FractionDisplayMode: Int {
        case large, small
    }
    
    public var displayMode: DisplayMode {
        get {
            return DisplayMode(rawValue: Preferences.local.integer(forKey: "displayMode")) ?? .automatic
        }
        set {
            Preferences.local.set(newValue.rawValue, forKey: "displayMode")
        }
    }
    public var largeNumberDisplayMode: LargeNumberDisplayMode {
        get {
            return LargeNumberDisplayMode(rawValue: Preferences.local.integer(forKey: "largeNumberDisplayMode")) ?? .automatic
        }
        set {
            Preferences.local.set(newValue.rawValue, forKey: "largeNumberDisplayMode")
        }
    }
    public var angleMode: AngleMode {
        get {
            return AngleMode(rawValue: Preferences.local.integer(forKey: "angleMode")) ?? .radians
        }
        set {
            Preferences.local.set(newValue.rawValue, forKey: "angleMode")
        }
    }
    public var fractionDisplayMode: FractionDisplayMode {
        get {
            return FractionDisplayMode(rawValue: Preferences.local.integer(forKey: "fractionDisplayMode")) ?? .large
        }
        set {
            Preferences.local.set(newValue.rawValue, forKey: "fractionDisplayMode")
        }
    }
    public var computationTimeWarning: Bool {
        get {
            return Preferences.local.bool(forKey: "computationTimeWarning")
        }
        set {
            Preferences.local.set(newValue, forKey: "computationTimeWarning")
        }
    }
    public var thermalOverride: Bool {
        get {
            return Preferences.local.bool(forKey: "thermalOverride")
        }
        set {
            Preferences.local.set(newValue, forKey: "thermalOverride")
        }
    }
    public var irrationalFunctionOverride: Bool {
        get {
            return Preferences.local.bool(forKey: "irrationalFunctionOverride")
        }
        set {
            Preferences.local.set(newValue, forKey: "irrationalFunctionOverride")
        }
    }
}
