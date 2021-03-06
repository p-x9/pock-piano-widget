//
//  PianoView.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/14.
//  
//

import Cocoa
import SnapKit

protocol PianoViewDelegate: AnyObject {
    func pianoView(didKeyDown key: PianoKey, at index: Int, type: PianoKey.KeyType)
    func pianoView(didKeyUp key: PianoKey, at index: Int, type: PianoKey.KeyType)
}

class PianoView: NSView {

    var numberOfWhiteKeys: Int
    var whiteKeyWidth: CGFloat {
        self.frame.width / CGFloat(self.numberOfWhiteKeys)
    }
    var blackKeyWidth: CGFloat {
        self.whiteKeyWidth * 0.6
    }
    var blackKeyHeight: CGFloat {
        self.frame.height * 0.6
    }
    var whiteKeys: [PianoKey] = []
    var blackKeys: [PianoKey] = []

    var shouldShowBlackKeys = true {
        didSet {
            self.blackKeys.forEach {
                $0.layer.isHidden = !shouldShowBlackKeys
            }
        }
    }

    weak var delegate: PianoViewDelegate?

    init(numberOfWhiteKeys: Int, frame: CGRect) {
        self.numberOfWhiteKeys = numberOfWhiteKeys
        super.init(frame: frame)

        self.wantsLayer = true
        self.setupKeys()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

    }

    override func layout() {
        super.layout()

        self.updateWhiteKeys()
        self.updateBlackKeys()
    }

    // MARK: - Event Handlings
    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        self.updateKeysState(with: event)
    }

    override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)

        self.updateKeysState(with: event)
    }

    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        // FIXME: handle touches only ended
        // 'touches(matching: .touching, in:)' may contain touches  that phase is .ended
        self.updateKeysState(with: event)
    }

    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)

        // FIXME: handle touches only ended
        // 'touches(matching: .touching, in:)' may contain touches that phase is .cancelled
        self.updateKeysState(with: event)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)

        self.updateKeysState(with: event.locationInWindow, isDown: false)
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        self.updateKeysState(with: event.locationInWindow)
    }

    override func mouseMoved(with event: NSEvent) {
        super.mouseMoved(with: event)

        self.updateKeysState(with: event.locationInWindow)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)

        self.updateKeysState(with: event.locationInWindow)
    }

    override func mouseExited(with event: NSEvent) {
        super.mouseExited(with: event)

        self.updateKeysState(with: event.locationInWindow, isDown: false)
    }

    override func mouseEntered(with event: NSEvent) {
        super.mouseEntered(with: event)

        self.updateKeysState(with: event.locationInWindow)
    }

    // MARK: - Set Up Methods
    private func setupKeys() {
        self.setupWhiteKeys()
        self.setupBlackKeys()
    }

    private func setupWhiteKeys() {
        (0..<self.numberOfWhiteKeys).forEach { index in
            let key = PianoKey(type: .white)
            key.octave = index / 7
            self.whiteKeys.append(key)
            self.layer?.addSublayer(key.layer)
        }

        self.updateWhiteKeys()
    }

    private func setupBlackKeys() {
        (0..<self.numberOfWhiteKeys).forEach { index in
            guard self.hasBlackKeyAtRight(for: index) else {
                return
            }
            let key = PianoKey(type: .black)
            key.layer.isHidden = !shouldShowBlackKeys
            key.octave = index / 7
            self.blackKeys.append(key)
            self.layer?.addSublayer(key.layer)
        }

        self.updateBlackKeys()
    }

    // MARK: - Update Layouts Method
    private func updateWhiteKeys() {
        let width = self.whiteKeyWidth
        self.whiteKeys.enumerated().forEach { index, key in
            key.octave = index / 7
            key.layer.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: self.frame.height)
        }
    }

    private func updateBlackKeys() {
        let whiteKeyWidth = self.whiteKeyWidth
        let blackKeyWidth = self.blackKeyWidth
        let blackKeyHeight = self.blackKeyHeight

        var currentBlackKeyIndex = 0
        (0..<self.numberOfWhiteKeys).forEach { index in
            guard self.hasBlackKeyAtRight(for: index) else {
                return
            }
            let key = self.blackKeys[currentBlackKeyIndex]
            key.octave = index / 7
            // bring to front
            key.layer.removeFromSuperlayer()
            self.layer?.addSublayer(key.layer)
            key.layer.frame = CGRect(x: whiteKeyWidth * CGFloat(index + 1) - blackKeyWidth / 2,
                                     y: self.frame.height - blackKeyHeight,
                                     width: blackKeyWidth, height: blackKeyHeight)
            currentBlackKeyIndex += 1
        }
    }

    func updateNumberOfKeys(numberOfWhiteKeys: Int) {
        let numberOfBlackKeys = getNumberOfBlackKeys(numberOfWhiteKeys: numberOfWhiteKeys)
        if self.whiteKeys.count > numberOfWhiteKeys {
            for i in numberOfWhiteKeys ..< self.whiteKeys.count {
                self.whiteKeys[i].layer.removeFromSuperlayer()
            }
            self.whiteKeys = Array(self.whiteKeys[0..<numberOfWhiteKeys])
        } else if self.whiteKeys.count < numberOfWhiteKeys {
            for _ in 0..<(numberOfWhiteKeys - self.whiteKeys.count) {
                let whiteKey = PianoKey(type: .white)
                self.layer?.addSublayer(whiteKey.layer)
                self.whiteKeys.append(whiteKey)
            }
        }

        if self.blackKeys.count > numberOfBlackKeys {
            for i in numberOfBlackKeys ..< self.blackKeys.count {
                self.blackKeys[i].layer.removeFromSuperlayer()
            }
            self.blackKeys = Array(self.blackKeys[0..<numberOfBlackKeys])
        } else if self.blackKeys.count < numberOfBlackKeys {
            for _ in 0..<(numberOfBlackKeys - self.blackKeys.count) {
                let blackKey = PianoKey(type: .black)
                blackKey.layer.isHidden = !shouldShowBlackKeys
                self.layer?.addSublayer(blackKey.layer)
                self.blackKeys.append(blackKey)
            }
        }

        self.numberOfWhiteKeys = numberOfWhiteKeys
        self.updateWhiteKeys()
        self.updateBlackKeys()
    }

  
    // MARK: - Get Key Index from point
    private func getKeyIndex(at point: CGPoint) -> (PianoKey.KeyType, Int)? {
        let whiteIndex = Int(point.x / self.whiteKeyWidth)
        guard self.whiteKeys.indices.contains(whiteIndex) else {
            return nil
        }

        let blackIndices = (0..<5).map { $0 + whiteIndex / 7 * 5 }
        for index in blackIndices where shouldShowBlackKeys {
            guard self.blackKeys.indices.contains(index) else {
                continue
            }
            let blackKey = self.blackKeys[index]
            if blackKey.layer.frame.contains(point) {
                return (PianoKey.KeyType.black, index)
            }
        }

        return (PianoKey.KeyType.white, whiteIndex)
    }

    private func getBlackKeyIndex(at point: CGPoint) -> Int? {
        if let (type, index) = getKeyIndex(at: point),
           type == .black {
            return index
        }
        return nil
    }

    private func getWhiteKeyIndex(at point: CGPoint) -> Int? {
        if let (type, index) = getKeyIndex(at: point),
           type == .white {
            return index
        }
        return nil
    }

    private func getKeyIndices(at points: [CGPoint]) -> (white: Set<Int>, black: Set<Int>) {
        var blackKeyIndices = Set<Int>()
        var whiteKeyIndices = Set<Int>()

        points.forEach { point in
            guard let (type, index) = getKeyIndex(at: point) else {
                return
            }
            switch type {
            case .black:
                blackKeyIndices.insert(index)
            case .white:
                whiteKeyIndices.insert(index)
            }
        }
        return (whiteKeyIndices, blackKeyIndices)
    }


    private func getNumberOfBlackKeys(numberOfWhiteKeys: Int) -> Int {
        var numberOfBlackKeys = numberOfWhiteKeys / 7 * 5
        numberOfBlackKeys += (0 ..< numberOfWhiteKeys % 7).filter { hasBlackKeyAtRight(for: $0) }.count

        return numberOfBlackKeys
    }

    private func getKey(at point: CGPoint) -> PianoKey? {
        guard let (type, index) = getKeyIndex(at: point) else {
            return nil
        }
        switch type {
        case .white:
            return self.whiteKeys[index]
        case .black:
            return self.blackKeys[index]
        }
    }

    // MARK: - Update Key State
    private func updateKeysState(with touchEvent: NSEvent) {
        let touches = touchEvent.touches(matching: .touching, in: self)
        let points = touches.map {
            $0.location(in: self)
        }
        self.updateKeysState(with: points)
    }

    private func updateKeysState(with point: CGPoint, isDown: Bool = true) {
        self.updateKeysState(with: [point], isDown: isDown)
    }

    private func updateKeysState(with points: [CGPoint], isDown: Bool = true) {
        let (whiteKeyDownIndices, blackKeyDownIndices) = getKeyIndices(at: points)
        self.whiteKeys.enumerated().forEach { index, key in
            let newState: PianoKey.State = whiteKeyDownIndices.contains(index) && isDown ? .down : .up
            if key.state == newState {
                return
            }
            key.state = newState
            switch newState {
            case .up:
                self.delegate?.pianoView(didKeyUp: key, at: index % 7, type: .white)
            case .down:
                self.delegate?.pianoView(didKeyDown: key, at: index % 7, type: .white)
            }
        }
        self.blackKeys.enumerated().forEach { index, key in
            let newState: PianoKey.State = blackKeyDownIndices.contains(index) && isDown ? .down : .up
            if key.state == newState {
                return
            }
            key.state = newState
            switch newState {
            case .up:
                self.delegate?.pianoView(didKeyUp: key, at: index % 5, type: .black)
            case .down:
                self.delegate?.pianoView(didKeyDown: key, at: index % 5, type: .black)
            }
        }
    }

    func hasBlackKeyAtRight(for index: Int) -> Bool {
        let index = index % 7
        return ![2, 6].contains(index)
    }
}
