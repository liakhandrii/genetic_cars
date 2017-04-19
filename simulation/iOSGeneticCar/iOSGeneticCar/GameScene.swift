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
    private var frontViewDisplayContainer: SKSpriteNode!
    
    private let cam = SKCameraNode()
    
    private var carPhysicsBody: SKPhysicsBody!
    private var carViewPhysicsBody: SKPhysicsBody!
    private var defaultCarPosition: CGPoint!
    private var defaultCarSize: CGSize!
    
    private var upButton: SKSpriteNode!
    private var downButton: SKSpriteNode!
    private var leftButton: SKSpriteNode!
    private var rightButton: SKSpriteNode!
    
    private var topCoefficientLabel: SKLabelNode!
    private var topDeltaLabel: SKLabelNode!
    private var bottomCoefficientLabel: SKLabelNode!
    private var bottomDeltaLabel: SKLabelNode!
    
    private var testTopCoefficientDelta: CGFloat = 0.2
    private var testBottomCoefficientDelta: CGFloat = 0.1
    private var frontViewEnabled = false
    private var frontViewDisplayContainerPosition : CGPoint!
    
    private var upButtonPosition: CGPoint!
    private var downButtonPosition: CGPoint!
    private var leftButtonPosition: CGPoint!
    private var rightButtonPosition: CGPoint!
    
    override func sceneDidLoad() {
        
        self.lastUpdateTime = 0
        
        // Get label node from scene and store it for use later
        self.car = self.childNode(withName: "car") as? GCCarNode
        self.carView = self.childNode(withName: "car_view") as? SKSpriteNode
        self.frontViewDisplayContainer = self.childNode(withName: "frontViewDisplayContainer") as? SKSpriteNode
        self.frontViewDisplay = frontViewDisplayContainer.childNode(withName: "frontViewDisplay") as? SKSpriteNode
        
        self.upButton = self.childNode(withName: "up") as? SKSpriteNode
        self.downButton = self.childNode(withName: "down") as? SKSpriteNode
        self.leftButton = self.childNode(withName: "left") as? SKSpriteNode
        self.rightButton = self.childNode(withName: "right") as? SKSpriteNode
        
        self.topCoefficientLabel = frontViewDisplayContainer.childNode(withName: "topCoefficientLabel") as? SKLabelNode
        self.topDeltaLabel = frontViewDisplayContainer.childNode(withName: "topDeltaLabel") as? SKLabelNode
        self.bottomCoefficientLabel = frontViewDisplayContainer.childNode(withName: "bottomCoefficientLabel") as? SKLabelNode
        self.bottomDeltaLabel = frontViewDisplayContainer.childNode(withName: "bottomDeltaLabel") as? SKLabelNode
        
        self.defaultCarPosition = car.position
        self.defaultCarSize = car.size
        self.frontViewDisplayContainerPosition = frontViewDisplayContainer.position
        
        self.upButtonPosition = upButton.position
        self.downButtonPosition = downButton.position
        self.leftButtonPosition = leftButton.position
        self.rightButtonPosition = rightButton.position
        
        self.car.genome = GCCarGenome(top: testTopCoefficientDelta, bottom: testBottomCoefficientDelta)
        
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
        frontViewDisplayContainer.position = CGPoint(x: frontViewDisplayContainerPosition.x + cam.position.x, y: frontViewDisplayContainerPosition.y + cam.position.y)
        
        upButton.position = CGPoint(x: upButtonPosition.x + cam.position.x, y: upButtonPosition.y + cam.position.y)
        downButton.position = CGPoint(x: downButtonPosition.x + cam.position.x, y: downButtonPosition.y + cam.position.y)
        leftButton.position = CGPoint(x: leftButtonPosition.x + cam.position.x, y: leftButtonPosition.y + cam.position.y)
        rightButton.position = CGPoint(x: rightButtonPosition.x + cam.position.x, y: rightButtonPosition.y + cam.position.y)
        
        if frontViewEnabled {
            let frontView = getCarView()
            
            frontViewDisplay.texture = SKTexture(image: frontView!)
            
            if let roadInfo = getRoadInfo(carView: frontView!) {
                let topDelta = GCRoadInfo.straight - roadInfo.topCoefficient
                let bottomDelta = GCRoadInfo.straight - roadInfo.bottomCoefficient
                
                topCoefficientLabel.text = "tc: \(Double(round(100 * roadInfo.topCoefficient)/100))"
                topDeltaLabel.text = "td: \(Double(round(100 * topDelta)/100))"
                bottomCoefficientLabel.text = "bc: \(Double(round(100 * roadInfo.bottomCoefficient)/100))"
                bottomDeltaLabel.text = "bd: \(Double(round(100 * bottomDelta)/100))"
                
                if abs(topDelta) >= car.genome!.neededTopCoefficientDelta {
                    if topDelta >= 0 {
                        turnLeft()
                    } else {
                        turnRight()
                    }
                } else if abs(bottomDelta) >= car.genome!.neededBottomCoefficientDelta {
                    if bottomDelta >= 0 {
                        turnLeft()
                    } else {
                        turnRight()
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
    
    let turnMultiplier: CGFloat = 2
    
    func turnLeft() {
        let mult = CGFloat(car!.zRotation > 0 ? 1 : -1)
        let angle = car!.zRotation + degree * 90 * mult
        
        let curdx = carPhysicsBody.velocity.dx
        let curdy = carPhysicsBody.velocity.dy
        let curdv = sqrt(pow(curdy, 2) + pow(curdx, 2))
        
        let dv: CGFloat = curdv * turnMultiplier
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
        
        let dv: CGFloat = curdv * turnMultiplier
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
        return CGFloat(Double.pi / 180)
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
            velocityAngle = CGFloat(dy > 0 ? Double.pi / 2 : -Double.pi / 2)
        } else if dx < 0 && dy > 0 {
            velocityAngle = atan(dy / dx) + CGFloat(Double.pi)
        } else if dy == 0 {
            velocityAngle = CGFloat(dx > 0 ? 0 : Double.pi)
        } else if dx < 0 && dy < 0 {
            velocityAngle = atan(dy / dx) - CGFloat(Double.pi)
        } else {
            velocityAngle = atan(dy / dx)
        }
        
        car.zRotation = velocityAngle
        carView.zRotation = velocityAngle
    }
    
    func touchDown(atPoint pos : CGPoint) {
        if upButton.contains(pos) {
            moveForward()
        } else if downButton.contains(pos) {
            decelerate()
        } else if leftButton.contains(pos) {
            turnLeft()
        } else if rightButton.contains(pos) {
            turnRight()
        }
    }
    
    func touchMoved(toPoint pos : CGPoint) {
        if upButton.contains(pos) {
            moveForward()
        } else if downButton.contains(pos) {
            decelerate()
        } else if leftButton.contains(pos) {
            turnLeft()
        } else if rightButton.contains(pos) {
            turnRight()
        }
    }
    
    func touchUp(atPoint pos : CGPoint) {
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchDown(atPoint: t.location(in: self)) }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchMoved(toPoint: t.location(in: self)) }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches { self.touchUp(atPoint: t.location(in: self)) }
    }
    
    private func getCarView() -> UIImage? {
        let zeroX = view!.frame.size.width / 2 - 50
        
        let captureRect = CGRect(x: zeroX + cos(car.zRotation) * defaultCarSize.width,
                                 y: view!.frame.size.height / 2 - carView.size.height / 2 - sin(car.zRotation) * defaultCarSize.width,
                                 width: carView.size.width,
                                 height: carView.size.height)
        
        let snapshot = self.view!.takeSnapshot()
        
        return snapshot.crop(rect: captureRect).rotatedByDegrees(deg: car.zRotation / degree - 90)
    }
    
    private func getRoadInfo(carView: UIImage) -> GCRoadInfo? {
        if var topLeftDistance = carView.firstWhitePixel()?.x,
            var bottomLeftDistance = carView.whitePixelAtTheBottom()?.x {
            topLeftDistance += 1
            bottomLeftDistance += 1
            
            return GCRoadInfo(topDist: topLeftDistance, botDist: bottomLeftDistance, width: carView.size.width)
        }
        
        return nil
    }
    
}

class GCCarNode: SKSpriteNode {
    var genome: GCCarGenome?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
