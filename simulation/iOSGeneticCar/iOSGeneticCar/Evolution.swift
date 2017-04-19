//
//  Evolution.swift
//  iOSGeneticCar
//
//  Created by Andrii Liakh on 4/20/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import UIKit

func createFirstGeneration(creaturesCount: Int) -> [GCCarGenome] {
    var generation = [GCCarGenome]()
    
    for _ in 0...creaturesCount {
        // the maximum coefficient delta (straight - current coefficient) is 0.5
        // generating random numbers between 0.01 and 0.5
        let top = CGFloat(arc4random_uniform(50) + 1) / 100.0
        let bottom = CGFloat(arc4random_uniform(50) + 1) / 100.0
        
        let creature = GCCarGenome(top: top, bottom: bottom)
        
        generation.append(creature)
    }
    
    return generation
}

func produceNextGeneration(currentGeneration: [GCCarGenome]) -> [GCCarGenome] {
    // sort an array so the most fitted ones are first
    var newGeneration = currentGeneration.sorted(by: { $0.fitness ?? 0 > $1.fitness ?? 0 })
    
    // remembering the count because it will change in a loop
    var genCount = newGeneration.count
    
    // remove the lower part of the generation
    for i in genCount / 2...genCount {
        newGeneration.remove(at: i)
    }
    
    // remembering the new count because it will change in a loop
    genCount = newGeneration.count
    
    // generating offspring 
    for var i in 0...genCount - 1 {
        let offsprings = newGeneration[i].mate(secondCreature: newGeneration[i + 1])
        
        // adding new creatures to our generation
        newGeneration.append(offsprings.firstOffspring)
        newGeneration.append(offsprings.secondOffspring)
        
        // skipping the already mated creature
        i += 1
    }
    
    return newGeneration
}

// the test function should take a creature, test it and return the fitness value
func calculateFitness(generation: [GCCarGenome], testFunction: (GCCarGenome) -> CGFloat) -> [GCCarGenome] {
    for creature in generation {
        creature.fitness = testFunction(creature)
    }
    
    return generation
}

// this function sends a request to analytics to check if we have to continue or we have reached our near optimal value
// Note: the function sends a synchronouse request, be careful and don't block the main thread
func checkIfHaveToStop(generation: [GCCarGenome], generationNumber: Int) -> Bool {
    let genJson = generationJsonSting(generation: generation)
    
    let requestUrl = URL(string: analyticsLink.replacingOccurrences(of: "{{gennum}}", with: "\(generationNumber)"))!
    
    // the makePostReques function is synchronous and it can take some time to execute
    if let response = makePostRequest(url: requestUrl, data: genJson) {
        if let responseJsonString = String(data: response.data!, encoding: String.Encoding.utf8) {
            let responseJson = parseJson(string: responseJsonString)
            return responseJson["continue"] as? Bool ?? true
        }
        
        // if the request fails – we continue, maybe better luck next time
        return true
    } else {
        return true
    }
}

// this function is the main loop for the whole evolution process (except the test function)
func evolve(testFunction: (GCCarGenome) -> CGFloat) {
    var generation: [GCCarGenome]?
    var generationNumber = 1
    
    while true {
        // checking if it's the first iteration
        if generation == nil {
            generation = createFirstGeneration(creaturesCount: 200)
        }
        
        // running tests for all creatures
        // Note: that is slow!
        generation = calculateFitness(generation: generation!, testFunction: testFunction)
        
        // asking analytics if we should continue or stop
        let haveToStop = checkIfHaveToStop(generation: generation!, generationNumber: generationNumber)
        
        if haveToStop {
            do {
                // saving generation so we can later use the best creature to check how it performs
                try saveGenerationToDisk(generation: generation!)
            } catch let error {
                NSLog("\(error.localizedDescription)")
            }
            break
        } else {
            // sorting, removing, mating and other stuff
            generation = produceNextGeneration(currentGeneration: generation!)
        }
        
        generationNumber += 1
        
    }
}



// dummy

let analyticsLink = "http://64.52.18.112/submit_gen_info?gennum={{gennum}}"

func generationJsonSting(generation: [GCCarGenome]) -> String {
    return "[]"
}

func makePostRequest(url: URL, data: String) -> NSURLConnection? {
    return nil
}

func parseJson(string: String) -> [String: AnyObject?] {
    return ["continue": true as AnyObject]
}

func saveGenerationToDisk(generation: [GCCarGenome]) throws {
    
}

extension NSURLConnection {
    var data: Data? {
        return nil
    }
}

