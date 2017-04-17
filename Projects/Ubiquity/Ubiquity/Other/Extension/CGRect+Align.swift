//
//  CGRect+Align.swift
//  Ubiquity
//
//  Created by SAGESSE on 3/29/17.
//  Copyright © 2017 SAGESSE. All rights reserved.
//

import UIKit

internal extension CGRect {
    internal func ub_aligned(with contentSize: CGSize, mode: UIViewContentMode = .scaleAspectFill, orientation: UIImageOrientation = .up) -> CGRect {
        var size = contentSize
        if orientation.ub_isLandscape {
            swap(&size.width, &size.height)
        }
        // if contentMode is scale is used in all rect
        if mode == .scaleToFill {
            return self
        }
        var x = self.minX
        var y = self.minY
        var width = size.width
        var height = size.height
        // if contentMode is aspect scale to fit, calculate the zoom ratio
        if mode == .scaleAspectFit {
            let scale = min(self.width / max(size.width, 1), self.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // if contentMode is aspect scale to fill, calculate the zoom ratio
        if mode == .scaleAspectFill {
            let scale = max(self.width / max(size.width, 1), self.height / max(size.height, 1))
            
            width = size.width * scale
            height = size.height * scale
        }
        // horizontal alignment
        if [.left, .topLeft, .bottomLeft].contains(mode) {
            // align left
            x += (0)
            
        } else if [.right, .topRight, .bottomRight].contains(mode) {
            // align right
            x += (self.width - width)
            
        } else {
            // algin center
            x += (self.width - width) / 2
        }
        // vertical alignment
        if [.top, .topLeft, .topRight].contains(mode) {
            // align top
            y += (0)
            
        } else if [.bottom, .bottomLeft, .bottomRight].contains(mode) {
            // align bottom
            y += (self.height - width)
            
        } else {
            // algin center
            y += (self.height - height) / 2
        }
        return .init(x: x, y: y, width: width, height: height)
    }
}
