//
//  PianoView.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/14.
//  
//

import Cocoa
import SnapKit

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

    var whiteKeyDownIndices = Set<Int>()
    var blackKeyDownIndices = Set<Int>()

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

    override func touchesBegan(with event: NSEvent) {
        super.touchesBegan(with: event)

        let touches = event.touches(for: self)
        let points = touches.map { $0.location(in: self) }
        let (whiteIndices, blackIndices) = getIndices(points: points)
        self.whiteKeyDownIndices.formUnion(whiteIndices)
        self.blackKeyDownIndices.formUnion(blackIndices)

        self.updateKeysState()
    }

    override func touchesMoved(with event: NSEvent) {
        super.touchesMoved(with: event)

        let touches = event.touches(for: self)
        let points = touches.map { $0.location(in: self) }
        let (whiteIndices, blackIndices) = getIndices(points: points)
        let previousPoints = touches.map { $0.previousLocation(in: self) }

        self.whiteKeyDownIndices.formUnion(whiteIndices)
        self.blackKeyDownIndices.formUnion(blackIndices)

        let (previousWhiteIndices, previousBlackIndices) = getIndices(points: previousPoints)
        self.whiteKeyDownIndices.subtract(previousWhiteIndices.subtracting(whiteIndices))
        self.blackKeyDownIndices.subtract(previousBlackIndices.subtracting(blackIndices))

        self.updateKeysState()
    }

    override func touchesEnded(with event: NSEvent) {
        super.touchesEnded(with: event)

        let touches = event.touches(for: self)
        let points = touches.map { $0.location(in: self) }

        let (whiteIndices, blackIndices) = getIndices(points: points)
        self.whiteKeyDownIndices.subtract(whiteIndices)
        self.blackKeyDownIndices.subtract(blackIndices)

        self.updateKeysState()
    }

    override func touchesCancelled(with event: NSEvent) {
        super.touchesCancelled(with: event)

        let touches = event.touches(for: self)
        let points = touches.map { $0.location(in: self) }
        let (whiteIndices, blackIndices) = getIndices(points: points)
        self.whiteKeyDownIndices.subtract(whiteIndices)
        self.blackKeyDownIndices.subtract(blackIndices)

        self.updateKeysState()
    }

    private func setupKeys() {
        self.setupWhiteKeys()
        self.setupBlackKeys()
    }

    private func setupWhiteKeys() {
        (0..<self.numberOfWhiteKeys).forEach {_ in
            let key = PianoKey(type: .white)
            self.whiteKeys.append(key)
            self.layer?.addSublayer(key.layer)
        }

        self.updateWhiteKeys()
    }

    private func setupBlackKeys() {
        (0..<self.numberOfWhiteKeys).forEach {index in
            if !self.hasBlackKeyAtRight(for: index) {
                return
            }
            let key = PianoKey(type: .black)
            self.blackKeys.append(key)
            self.layer?.addSublayer(key.layer)
        }

        self.updateBlackKeys()
    }

    private func updateWhiteKeys() {
        let width = self.whiteKeyWidth
        self.whiteKeys.enumerated().forEach {index, key in
            key.layer.frame = CGRect(x: width * CGFloat(index), y: 0, width: width, height: self.frame.height)
        }
    }

    private func updateBlackKeys() {
        let whiteKeyWidth = self.whiteKeyWidth
        let blackKeyWidth = self.blackKeyWidth
        let blackKeyHeight = self.blackKeyHeight

        var currentBlackKeyIndex = 0
        (0..<self.numberOfWhiteKeys).forEach {index in
            if !self.hasBlackKeyAtRight(for: index) {
                return
            }
            let key = self.blackKeys[currentBlackKeyIndex]
            key.layer.frame = CGRect(x: whiteKeyWidth * CGFloat(index + 1) - blackKeyWidth / 2,
                                     y: self.frame.height - blackKeyHeight,
                                     width: blackKeyWidth, height: blackKeyHeight)

            currentBlackKeyIndex += 1
        }
    }

    private func getKeyIndex(at point: CGPoint) -> (PianoKey.KeyType, Int)? {
        let whiteIndex = Int(point.x / self.whiteKeyWidth)
        if !self.whiteKeys.indices.contains(whiteIndex) {
            return nil
        }

        let blackIndices = (0..<5).map { $0 + whiteIndex / 7 * 5 }
        for index in blackIndices {
            if !self.blackKeys.indices.contains(index) {
                continue
            }
            let blackKey = self.blackKeys[index]
            if blackKey.layer.frame.contains(point) {
                return (PianoKey.KeyType.black, index)
            }
        }

        return (PianoKey.KeyType.white, whiteIndex)
    }

    private func getKey(at point: CGPoint) -> PianoKey? {
        if let typeAndIndex = getKeyIndex(at: point) {
            switch typeAndIndex.0 {
            case .white:
                return self.whiteKeys[typeAndIndex.1]
            case .black:
                return self.blackKeys[typeAndIndex.1]
            }
        }
        return nil
    }

    private func getBlackKeyIndex(at point: CGPoint) -> Int? {
        if let typeAndIndex = getKeyIndex(at: point),
           typeAndIndex.0 == .black {
            return typeAndIndex.1
        }
        return nil
    }

    private func getWhiteKeyIndex(at point: CGPoint) -> Int? {
        if let typeAndIndex = getKeyIndex(at: point),
           typeAndIndex.0 == .white {
            return typeAndIndex.1
        }
        return nil
    }

    private func getIndices(points: [CGPoint]) -> (white: Set<Int>, black: Set<Int>) {
        var blackKeyIndices = Set<Int>()
        var whiteKeyIndices = Set<Int>()

        points.forEach {point in
            if let typeAndIndex = getKeyIndex(at: point) {
                switch typeAndIndex.0 {
                case .black:
                    blackKeyIndices.insert(typeAndIndex.1)
                case .white:
                    whiteKeyIndices.insert(typeAndIndex.1)
                }
            }
        }
        return (whiteKeyIndices, blackKeyIndices)
    }

    private func updateKeysState() {
        self.whiteKeys.enumerated().forEach {index, key in
            key.state = self.whiteKeyDownIndices.contains(index) ? .down : .up
        }
        self.blackKeys.enumerated().forEach {index, key in
            key.state = self.blackKeyDownIndices.contains(index) ? .down : .up
        }
    }

    func hasBlackKeyAtRight(for index: Int) -> Bool {
        let index = index % 7
        return ![2, 6].contains(index)
    }
}
