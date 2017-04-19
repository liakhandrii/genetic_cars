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
    
    var fitness: CGFloat?
    
    init(top: CGFloat, bottom: CGFloat) {
        self.neededTopCoefficientDelta = top
        self.neededBottomCoefficientDelta = bottom
    }
    
}

extension GCCarGenome {
    
    // this function generates a tuple with two offsprings of the provided creatures
    func mate(secondCreature: GCCarGenome) -> (firstOffspring: GCCarGenome, secondOffspring: GCCarGenome) {
        
        // taking the genes from the parents and mutating a little bit
        let firstTop = self.neededTopCoefficientDelta + CGFloat(arc4random_uniform(5)) / 100.0
        let firstBottom = secondCreature.neededBottomCoefficientDelta + CGFloat(arc4random_uniform(5)) / 100.0
        
        let secondTop = secondCreature.neededTopCoefficientDelta + CGFloat(arc4random_uniform(5)) / 100.0
        let secondBottom = self.neededBottomCoefficientDelta + CGFloat(arc4random_uniform(5)) / 100.0
        
        let firstOffspring = GCCarGenome(top: firstTop, bottom: firstBottom)
        let secondOffspring = GCCarGenome(top: secondTop, bottom: secondBottom)
        
        return (firstOffspring: firstOffspring, secondOffspring: secondOffspring)
    }
    
}
