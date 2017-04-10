//
//  GCRoadInfo.swift
//  GeneticCar
//
//  Created by Andrew Liakh on 4/10/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import Foundation

class GCRoadInfo {
    var leftCoefficient: CGFloat
    var rightCoefficient: CGFloat
    
    init(left: CGFloat, right: CGFloat) {
        self.leftCoefficient = left
        self.rightCoefficient = right
    }
}
