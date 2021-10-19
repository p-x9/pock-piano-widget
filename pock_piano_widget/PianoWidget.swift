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

    let audioHelper = AudioHelper()

    override required init() {
        super.init()

        self.pianoView = PianoView(numberOfWhiteKeys: 40, frame: NSRect(x: 0, y: 0, width: 200, height: 30))
        self.pianoView.delegate = self
        self.view = self.pianoView
    }

    func viewDidAppear() {
        self.audioHelper.start()
    }

    func viewDidDisappear() {
        self.audioHelper.stop()
    }
}

extension PianoWidget: PianoViewDelegate {
    func pianoView(didKeyDown key: PianoKey, at index: Int, type: PianoKey.KeyType) {
        //base must to be 7n-1
        self.audioHelper.startNote(base: 49 - 1, octave: key.octave, index: index, keyType: type)
    }

    func pianoView(didKeyUp key: PianoKey, at index: Int, type: PianoKey.KeyType) {
        self.audioHelper.stopNote(base: 49 - 1, octave: key.octave, index: index, keyType: type)
    }

}
