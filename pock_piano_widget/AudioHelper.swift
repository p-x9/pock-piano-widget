//
//  AudioHelper.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/15.
//  
//

import Foundation
import AVFoundation

class AudioHelper {

    let audioUnitSampler = AVAudioUnitSampler()
    let audioEngine = AVAudioEngine()

    init() {
        self.audioEngine.attach(audioUnitSampler)

        self.audioEngine.connect(audioUnitSampler, to: audioEngine.mainMixerNode, format: nil)
    }

    func start() {
        if audioEngine.isRunning {
            return
        }

        do {
            try audioEngine.start()
        } catch {
            print(error)
        }

    }

    func stop() {
        audioEngine.stop()
    }

    func startNote(base: Int, octave: Int, index: Int, keyType: PianoKey.KeyType) {
        let keyNumber = getKeyNumber(index: index, keyType: keyType)

        self.audioUnitSampler.startNote(UInt8(base + octave * 12 + keyNumber), withVelocity: 64, onChannel: 0)
    }

    func stopNote(base: Int, octave: Int, index: Int, keyType: PianoKey.KeyType) {
        let keyNumber = getKeyNumber(index: index % 12, keyType: keyType)

        self.audioUnitSampler.stopNote(UInt8(base + octave * 12 + keyNumber), onChannel: 0)
    }

    private func getKeyNumber(index: Int, keyType: PianoKey.KeyType) -> Int {
        var keyNumber = 0
        switch keyType {
        case .white:
            keyNumber = [0, 2, 4, 5, 7, 9, 11][index]
        case .black:
            keyNumber = [1, 3, 6, 8, 10][index]
        }
        return keyNumber
    }

    deinit {
        if audioEngine.isRunning {
            audioEngine.disconnectNodeOutput(audioUnitSampler)
            audioEngine.detach(audioUnitSampler)
            audioEngine.stop()
        }
    }
}
