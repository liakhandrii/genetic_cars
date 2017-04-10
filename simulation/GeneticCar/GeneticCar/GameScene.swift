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
    private var car : SKSpriteNode!
    private var carView: SKSpriteNode!
    private var spinnyNode : SKShapeNode?
    
    private let cam = SKCameraNode()
    
    private var carPhysicsBody: SKPhysicsBody!
    private var carViewPhysicsBody: SKPhysicsBody!
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.car = self.childNode(withName: "car") as? SKSpriteNode
        self.carView = self.childNode(withName: "car_view") as? SKSpriteNode
        
        carPhysicsBody = SKPhysicsBody(rectangleOf: car!.frame.size)
        carPhysicsBody?.affectedByGravity = false
        self.car?.physicsBody = carPhysicsBody
        
        carViewPhysicsBody = SKPhysicsBody(rectangleOf: carView.frame.size)
        carViewPhysicsBody.affectedByGravity = false
        carViewPhysicsBody.mass = 0
        self.carView.physicsBody = carViewPhysicsBody
        
        let fixedJoint = SKPhysicsJointFixed.joint(withBodyA: carPhysicsBody, bodyB: carViewPhysicsBody, anchor: CGPoint(x: car.frame.maxX, y: car.frame.minY + car.frame.width / 2))
        fixedJoint.bodyA = carPhysicsBody
        fixedJoint.bodyB = carViewPhysicsBody
        
        self.physicsWorld.add(fixedJoint)
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.3)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 2.5
            
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(M_PI), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
        }
        
        self.camera = cam
    }
    
    
    func touchDown(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.green
            self.addChild(n)
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.blue
            self.addChild(n)
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        if let n = self.spinnyNode?.copy() as! SKShapeNode? {
            n.position = pos
            n.strokeColor = SKColor.red
            self.addChild(n)
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        self.touchDown(atPoint: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.touchMoved(toPoint: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        self.touchUp(atPoint: event.location(in: self))
    }
    
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
                    accelerate()
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
        //carPhysicsBody?.vel
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
    
    private func getCarView() {
//        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, 1);
//        [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
//        UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        return  viewImage;
        
        //self.view?.dataWithPDF(inside: <#T##NSRect#>)
        
    }
}
