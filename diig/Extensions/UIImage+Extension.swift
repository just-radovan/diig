//
//  UIImage+Extension.swift
//  diig
//
//  Created by Radovan Paška on 13.02.2021.
//

import Foundation
import UIKit

public extension UIImage {
    
    var planar: UIImage {
        ImageTransformations.planar8(from: self)
    }
    
    var dithered: UIImage {
        ImageTransformations.dither(image: self)
    }
    
    func scale(toFitSquare targetSize: Int) -> UIImage {
        ImageTransformations.scalePlanar8(image: self, to: targetSize)
    }
    
    func frame(with color: UIColor) -> UIImage {
        ImageTransformations.frame(image: self, color: color)
    }
}
