//
//  PianoWidget.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/14.
//  
//

import Cocoa
import PockKit

class PianoWidget: NSObject, PKWidget {
    static var identifier: String = "\(PianoWidget.self)"

    var customizationLabel: String = "Piano"

    var view: NSView!

    var pianoView: PianoView!

    override required init() {
        super.init()

        self.pianoView = PianoView(numberOfWhiteKeys: 20, frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        self.view = self.pianoView
    }
}
