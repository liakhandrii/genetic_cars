//
//  CarGenome.swift
//  GeneticCar
//
//  Created by Andrew Liakh on 4/10/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import CoreGraphics

class GCCarGenome {
    var neededTopCoefficientDelta: CGFloat
    var neededBottomCoefficientDelta: CGFloat
    
    init(top: CGFloat, bottom: CGFloat) {
        self.neededTopCoefficientDelta = top
        self.neededBottomCoefficientDelta = bottom
    }
}
