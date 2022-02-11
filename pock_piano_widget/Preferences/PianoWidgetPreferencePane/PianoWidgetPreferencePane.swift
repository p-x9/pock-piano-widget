//
//  PianoWidgetPreferencePane.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2022/01/28.
//  
//

import Cocoa
import PockKit

class PianoWidgetPreferencePane: NSViewController, PKWidgetPreference {
    static var nibName: NSNib.Name = "\(PianoWidgetPreferencePane.self)"

    @IBOutlet private weak var numberOfWhiteKeyTextField: NSTextField! {
        didSet {
            numberOfWhiteKeyTextField.stringValue = "\(Preferences[.numberOfWhiteKeys])"
        }
    }
    @IBOutlet private weak var baseNoteTextField: NSTextField! {
        didSet {
            baseNoteTextField.integerValue = Preferences[.baseNote]
        }
    }
    @IBOutlet private weak var shouldShowBlackKeysCheckBox: NSButton! {
        didSet {
            shouldShowBlackKeysCheckBox.state = Preferences[.shouldShowBlackKeys] ? .on : .off
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }

    @IBAction private func handleNumberOfWhiteKeyTextField(_ sender: NSTextField) {
        guard let value = Int(sender.stringValue),
            value <= 40 else {
            sender.stringValue = "\(Preferences[.numberOfWhiteKeys])"
            return
        }
        Preferences[.numberOfWhiteKeys] = value

        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }
    @IBAction func handleBaseNoteTextField(_ sender: NSTextField) {
        guard let value = Int(sender.stringValue),
              (2...10).contains(value) else {
            sender.stringValue = "\(Preferences[.numberOfWhiteKeys])"
            return
        }
        Preferences[.baseNote] = value
    }
    @IBAction private func handleShouldShowBlackKeysCheckBox(_ sender: NSButton) {
        let value = sender.state == .on
        if Preferences[.shouldShowBlackKeys] != value {
            Preferences[.shouldShowBlackKeys] = value
            NSWorkspace.shared.notificationCenter.post(name: .hideBlackKeys, object: value)
        }
    }

    func reset() {
        Preferences.reset()
        NSWorkspace.shared.notificationCenter.post(name: .shouldReloadUISettings, object: nil)
    }

}
