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
    
    public var displayMode: DisplayMode {
        get {
            return DisplayMode(rawValue: Preferences.local.integer(forKey: "displayMode")) ?? .automatic
        }
        set {
            Preferences.local.set(newValue.rawValue, forKey: "displayMode")
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
}
