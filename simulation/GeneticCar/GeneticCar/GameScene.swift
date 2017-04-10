//
//  GameScene.swift
//  GeneticCar
//
//  Created by Andrew Liakh on 3/27/17.
//  Copyright © 2017 Andrew Liakh. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    
    private var lastUpdateTime : TimeInterval = 0
    private var car : GCCarNode!
    private var carView: SKSpriteNode!
    private var frontViewDisplay: SKSpriteNode!
    
    private let cam = SKCameraNode()
    
    private var carPhysicsBody: SKPhysicsBody!
    private var carViewPhysicsBody: SKPhysicsBody!
    private var defaultCarPosition: CGPoint!
    private var defaultCarSize: CGSize!
    
    private var testCoefficient: CGFloat = 0.5
    private var frontViewEnabled = false
    private var frontViewDisplayPosition : CGPoint!
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.car = self.childNode(withName: "car") as? GCCarNode
        self.carView = self.childNode(withName: "car_view") as? SKSpriteNode
        self.frontViewDisplay = self.childNode(withName: "frontViewDisplay") as? SKSpriteNode
        
        self.defaultCarPosition = car.position
        self.defaultCarSize = car.size
        self.frontViewDisplayPosition = frontViewDisplay.position
        
        self.car.genome = GCCarGenome(coefficient: testCoefficient)
        
        carPhysicsBody = SKPhysicsBody(rectangleOf: car!.frame.size)
        carPhysicsBody?.affectedByGravity = false
        self.car?.physicsBody = carPhysicsBody
        
        carViewPhysicsBody = SKPhysicsBody(rectangleOf: carView.frame.size)
        carViewPhysicsBody.affectedByGravity = false
        carViewPhysicsBody.mass = 0
        self.carView.physicsBody = carViewPhysicsBody
        
        let fixedViewJoint = SKPhysicsJointFixed.joint(withBodyA: carPhysicsBody, bodyB: carViewPhysicsBody, anchor: CGPoint(x: car.frame.maxX, y: car.frame.minY + car.frame.width / 2))
        fixedViewJoint.bodyA = carPhysicsBody
        fixedViewJoint.bodyB = carViewPhysicsBody
        
        let fixedDisplayJoint = SKPhysicsJointFixed.joint(withBodyA: carPhysicsBody, bodyB: carViewPhysicsBody, anchor: CGPoint(x: car.frame.maxX, y: car.frame.minY + car.frame.width / 2))
        fixedDisplayJoint.bodyA = carPhysicsBody
        fixedDisplayJoint.bodyB = carViewPhysicsBody
        
        self.physicsWorld.add(fixedViewJoint)
        
        self.camera = cam
        timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: false, block: {
            timer in
            self.frontViewEnabled = true
        })
        
    }
    
    var timer: Timer?
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
        // Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        cam.position = car!.position
        frontViewDisplay.position = CGPoint(x: frontViewDisplayPosition.x + cam.position.x, y: frontViewDisplayPosition.y + cam.position.y)
        
        if frontViewEnabled {
            let frontView = getCarView()
            frontViewDisplay.texture = SKTexture(image: frontView)
        }
    }
    
    public override func keyDown(with event: NSEvent) {
        handleKeyEvent(event: event, keyDown: true)
    }
    
    public override func keyUp(with event: NSEvent) {
        handleKeyEvent(event: event, keyDown: false)
    }
    
    public func handleKeyEvent(event: NSEvent, keyDown: Bool){
        if event.modifierFlags.contains(NSEventModifierFlags.numericPad){
            if let theArrow = event.charactersIgnoringModifiers, let keyChar = theArrow.unicodeScalars.first?.value{
                switch Int(keyChar){
                case NSUpArrowFunctionKey:
                    moveForward()
                    break
                case NSDownArrowFunctionKey:
                    decelerate()
                    break
                case NSRightArrowFunctionKey:
                    turnRight()
                    break
                case NSLeftArrowFunctionKey:
                    turnLeft()
                    break
                default:
                    break
                }
            }
        } else {
            if let characters = event.characters{
                for character in characters.characters{
                    switch(character){
                    case "w":
                        break
                    default:
                        print(character)
                    }
                }
            }
        }
    }
    
    var wheelsAngle: CGFloat = 0
    
    func moveForward() {
        let angle = car!.zRotation
        let dv: CGFloat = 100
        let dx: CGFloat = dv * cos(angle)
        let dy: CGFloat = dv * sin(angle)
        carPhysicsBody?.applyForce(CGVector(dx: dx, dy: dy))
    }
    
    func decelerate() {
        let angle = car!.zRotation
        let dv: CGFloat = 100
        let dx: CGFloat = dv * cos(angle)
        let dy: CGFloat = dv * sin(angle)
        carPhysicsBody?.applyForce(CGVector(dx: -dx, dy: -dy))
    }
    
    func turnLeft() {
        let mult = CGFloat(car!.zRotation > 0 ? 1 : -1)
        let angle = car!.zRotation + degree * 90 * mult
        
        let curdx = carPhysicsBody.velocity.dx
        let curdy = carPhysicsBody.velocity.dy
        let curdv = sqrt(pow(curdy, 2) + pow(curdx, 2))
    
        let dv: CGFloat = curdv
        let dx: CGFloat = dv * cos(angle) * mult
        let dy: CGFloat = dv * sin(angle) * mult
        carPhysicsBody?.applyForce(CGVector(dx: dx, dy: dy))
    }
    
    func turnRight() {
        let mult = CGFloat(car!.zRotation > 0 ? 1 : -1)
        let angle = car!.zRotation - degree * 90 * mult
        
        let curdx = carPhysicsBody.velocity.dx
        let curdy = carPhysicsBody.velocity.dy
        let curdv = sqrt(pow(curdy, 2) + pow(curdx, 2))
        
        let dv: CGFloat = curdv
        let dx: CGFloat = dv * cos(angle) * mult
        let dy: CGFloat = dv * sin(angle) * mult
        carPhysicsBody?.applyForce(CGVector(dx: dx, dy: dy))
    }
    
    private func centerOn(node: SKNode) {
        var cameraPositionInScene = node.scene!.convert(node.position, from: node.parent!)
        cameraPositionInScene.x = 0
        node.parent?.position = CGPoint(x: node.parent!.position.x - cameraPositionInScene.x, y: node.parent!.position.y - cameraPositionInScene.y)
    }
    
    var degree: CGFloat {
        return CGFloat(M_PI / 180)
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        
        let angle = car!.zRotation
        let velocity = carPhysicsBody!.velocity
        
        let dx = velocity.dx
        let dy = velocity.dy
        let dv = sqrt(pow(dy, 2) + pow(dx, 2))
        
        if dv == 0 {
            return
        }
        
        var velocityAngle: CGFloat = 0
        
        if dx == 0 {
            velocityAngle = CGFloat(dy > 0 ? M_PI_2 : -M_PI_2)
        } else if dx < 0 && dy > 0 {
            velocityAngle = atan(dy / dx) + CGFloat(M_PI)
        } else if dy == 0 {
            velocityAngle = CGFloat(dx > 0 ? 0 : M_PI)
        } else if dx < 0 && dy < 0 {
            velocityAngle = atan(dy / dx) - CGFloat(M_PI)
        } else {
            velocityAngle = atan(dy / dx)
        }
        
        car.zRotation = velocityAngle
        carView.zRotation = velocityAngle
    }
    
    private func getCarView() -> NSImage {
        if let window = view?.window {
            let windowID = CGWindowID( window.windowNumber )
            let wOrigin = window.frame.origin
            let captureRect = CGRect(x: wOrigin.x + view!.frame.width / 2 + carView.position.x - cam.position.x + cos(car.zRotation) * defaultCarSize.width / 2,
                                     y: wOrigin.y + view!.frame.height / 2 + carView.position.y - carView!.frame.height - cam.position.y + sin(car.zRotation) * defaultCarSize.width / 2,
                                     width: carView.frame.width,
                                     height: carView.frame.height)
//            let captureRect = CGRect(x: wOrigin.x + view!.frame.width / 2 + carView.position.x - cam.position.x + carView!.frame.width / 2,
//                                     y: wOrigin.y + view!.frame.height / 2 - carView!.frame.height,
//                                     width: carView.frame.width,
//                                     height: carView.frame.height)
            return NSImage(cgImage: CGWindowListCreateImage( captureRect, CGWindowListOption.optionIncludingWindow, windowID, CGWindowImageOption.boundsIgnoreFraming )!, size: carView.size)
        }
        
        return NSImage()
    }
}

class GCCarNode: SKSpriteNode {
    var genome: GCCarGenome?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
