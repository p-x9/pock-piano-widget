//
//  PianoKey.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/14.
//  
//

import Cocoa

class PianoKey: NSObject {

    enum KeyType {
        case white, black
    }

    enum State {
        case up, down
    }

    let type: KeyType
    var state: State = .up {
        didSet {
            if state == .up {
                self.layer.backgroundColor = color.cgColor
            } else {
                self.layer.backgroundColor = NSColor.red.cgColor// color.highlight(withLevel: 0.5)?.cgColor//highlighted.cgColor
            }
        }
    }

    var octave: Int = 0

    var color: NSColor {
        self.type == .white ? .white : .black
    }

    var layer = CALayer()

    init(type: KeyType) {
        self.type = type

        super.init()

        self.layer.backgroundColor = color.cgColor
        self.layer.borderWidth = 1

        self.layer.cornerRadius = 2
        self.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
    }

}
