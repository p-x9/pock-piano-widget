//
//  NSColor.swift
//  pock_piano_widget
//
//  Created by p-x9 on 2021/10/14.
//  
//

import Cocoa

extension NSColor {
    var highlighted: NSColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0

        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        let newBrightness = brightness > 0.5 ? brightness - 0.2:brightness + 0.2

        return NSColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha)
    }
}
