//
//  GCRoadInfo.swift
//  GeneticCar
//
//  Created by Andrew Liakh on 4/10/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import CoreGraphics

class GCRoadInfo {
    var topCoefficient: CGFloat
    var bottomCoefficient: CGFloat
    
    init(topDist: CGFloat, botDist: CGFloat, width: CGFloat) {
        self.topCoefficient = topDist / width
        self.bottomCoefficient = botDist / width
    }
    
    var description: String {
        return "Top coefficient: \(topCoefficient)\nBottom coefficient: \(bottomCoefficient)"
    }
    
    static let straight: CGFloat = 0.5
}
