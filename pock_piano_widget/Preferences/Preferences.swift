//
//  Preferences.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/17.
//  
//

import Foundation
import Defaults

struct Preferences {
    typealias Keys = Defaults.Keys
    typealias Key = Defaults.Key

    static func reset() {
        Keys.numberOfWhiteKeys.reset()
    }

    static subscript<Value>(key: Key<Value>) -> Value {
        get {
            Defaults[key]
        }
        set {
            Defaults[key] = newValue
        }
    }
}

extension Preferences.Keys {
    static let numberOfWhiteKeys = Preferences.Key<Int>("numberOfWhiteKeys", default: 30)
}

extension Preferences.Key {
    func reset() {
        Defaults[self] = self.defaultValue
    }
}

extension NSNotification.Name {
    static let shouldReloadUISettings = NSNotification.Name("shouldReloadUISettings")
}
