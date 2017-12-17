//
//  GameScene.swift
//  hashRocketEli
//
//  Created by Jason Lee on 11/2/17.
//  Copyright © 2017 Jason Lee. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion

struct SCNPhysicsCollisionCategory {
    static let player : UInt32 = 0x1 << 1
    static let endNode : UInt32 = 0x1 << 2
    static let score : UInt32 = 0x1 << 3
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    let manager = CMMotionManager()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var player = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    var endNode = SKSpriteNode()
    var endNodeCollide: Bool = false
    var score = Int()
    let scoreLabel = SKLabelNode()
    let praiseLabel = SKLabelNode()
    var restartBTN = SKSpriteNode()
    
    
    func restartScene(){
        self.removeAllChildren()
        self.removeAllActions()
        endNodeCollide = false
        score = 0
        createScene()
    }
    func createScene(){
        self.physicsWorld.contactDelegate = self
        self.backgroundColor = UIColor.white
        praiseLabel.position = CGPoint(x: 0, y: 130)
        praiseLabel.zPosition = 6
        praiseLabel.fontSize = 40
        praiseLabel.text = ""
        self.addChild(praiseLabel)
        
        scoreLabel.position = CGPoint(x: 0, y: 100)
        scoreLabel.zPosition = 6
        scoreLabel.fontColor = UIColor.cyan
        scoreLabel.fontSize = 30
        scoreLabel.text = "\(score)"
        self.addChild(scoreLabel)
        
        endNode = SKSpriteNode()
        endNode.position = CGPoint(x: 0, y: 160)
        endNode.size = CGSize(width: 300, height: 5)
        endNode.physicsBody = SKPhysicsBody(rectangleOf: endNode.size, center: endNode.position)
        endNode.physicsBody?.affectedByGravity = false
        endNode.physicsBody?.isDynamic = false
        endNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.endNode
        endNode.physicsBody?.collisionBitMask = SCNPhysicsCollisionCategory.player
        endNode.physicsBody?.contactTestBitMask = SCNPhysicsCollisionCategory.player
        self.addChild(endNode)
        
        player = SKSpriteNode(imageNamed: "pi")
        player.position = CGPoint(x: 0, y: 100)
        player.zPosition = 0
        player.setScale(0.15)
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.allowsRotation = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.player
        player.physicsBody?.collisionBitMask = SCNPhysicsCollisionCategory.endNode
        player.physicsBody?.contactTestBitMask =  SCNPhysicsCollisionCategory.score | SCNPhysicsCollisionCategory.endNode
        self.addChild(player)
        
        let spawn = SKAction.run({
            self.createWall()
        })
        
        let delay = SKAction.wait(forDuration: 1)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.height + wallPair.frame.height)
        let moveWalls = SKAction.moveBy(x: 0, y: distance, duration: TimeInterval((0.008) * distance))
        let removeWalls = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([moveWalls, removeWalls])
        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data, error)in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!), dy: CGFloat((data?.acceleration.y)!))
            let playerTexture1 = SKTexture(imageNamed: "pi")
            playerTexture1.filteringMode = .nearest
            
        }
    }
    override func sceneDidLoad() {
        super.sceneDidLoad()
        createScene()
    }
    func createWall() {
        
        wallPair = SKNode()
        wallPair.physicsBody?.affectedByGravity = false
        wallPair.physicsBody?.isDynamic = false
        wallPair.physicsBody?.allowsRotation = false

        let leftWall = SKSpriteNode(imageNamed: "Wall")
        let rightWall = SKSpriteNode(imageNamed: "Wall")
        
        leftWall.physicsBody = SKPhysicsBody(rectangleOf: leftWall.size)
        leftWall.physicsBody?.affectedByGravity = false
        leftWall.physicsBody?.isDynamic = false
        leftWall.physicsBody?.allowsRotation = false
        
        rightWall.physicsBody = SKPhysicsBody(rectangleOf: rightWall.size)
        rightWall.physicsBody?.affectedByGravity = false
        rightWall.physicsBody?.isDynamic = false
        rightWall.physicsBody?.allowsRotation = false
        
        // Wall distance randomizer
        let randNum = (Int(arc4random_uniform(50) + 1))

        rightWall.position = CGPoint(x: -110, y: -200)
        leftWall.position = CGPoint(x: 110, y: -200)

        wallPair.position = CGPoint(x: randNum, y: -150)
        wallPair.zPosition = 1
        
        let scoreNode = SKSpriteNode()
        scoreNode.size = CGSize(width: 1000, height: 1)
        scoreNode.position = CGPoint(x: randNum, y: -200)
        scoreNode.physicsBody = SKPhysicsBody(rectangleOf: scoreNode.size)
        scoreNode.physicsBody?.affectedByGravity = false
        scoreNode.physicsBody?.isDynamic = false
        scoreNode.physicsBody?.categoryBitMask = SCNPhysicsCollisionCategory.score
        scoreNode.physicsBody?.collisionBitMask = 0
        scoreNode.physicsBody?.contactTestBitMask = SCNPhysicsCollisionCategory.player
        scoreNode.color = UIColor.gray
        
        //Set wall scale
        leftWall.setScale(0.18)
        rightWall.setScale(0.18)
        
        wallPair.addChild((rightWall))
        wallPair.addChild((leftWall))
        wallPair.addChild(scoreNode)
        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
//    override func didMove(to view: SKView) {
//        let background = SKSpriteNode(imageNamed: "background")
//        background.position = CGPoint(x: 0, y: 0)
//        background.zPosition = -2
//        addChild(background)
//    }
    func createBTN(){
        restartBTN = SKSpriteNode(color: UIColor.darkGray, size: CGSize(width: 320, height: 160))
        restartBTN.position = CGPoint(x: 0, y: 130)
        restartBTN.zPosition = 5
        self.addChild(restartBTN)
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        if bodyA.categoryBitMask == SCNPhysicsCollisionCategory.score && bodyB.categoryBitMask == SCNPhysicsCollisionCategory.player || bodyA.categoryBitMask == SCNPhysicsCollisionCategory.player && bodyB.categoryBitMask == SCNPhysicsCollisionCategory.score{
            
            score = score + 1
            
            if score >= 10 && score < 25 && endNodeCollide == false{
                praiseLabel.text = "Mathmatic!"
                praiseLabel.fontColor = UIColor.white
                self.backgroundColor = UIColor.red
            }
            else if score >= 25 && score < 50 && endNodeCollide == false{
                praiseLabel.text = "Geometric!"
                praiseLabel.fontColor = UIColor.gray
                self.backgroundColor = UIColor.orange
            }
            else if score >= 50 && score < 100 && endNodeCollide == false{
                praiseLabel.text = "Algebraic!"
                praiseLabel.fontColor = UIColor.white
                self.backgroundColor = UIColor.yellow
            }
            else if score >= 100 && score < 150 && endNodeCollide == false{
                praiseLabel.text = "Trigonometric!"
                praiseLabel.fontColor = UIColor.gray
                self.backgroundColor = UIColor.green
            }
            else if score >= 150 && score < 200 && endNodeCollide == false{
                praiseLabel.text = "Calculated!"
                praiseLabel.fontColor = UIColor.white
                self.backgroundColor = UIColor.blue
            }
            else if score >= 200 && score < 300 && endNodeCollide == false{
                praiseLabel.text = "Cryptographic!"
                praiseLabel.fontColor = UIColor.gray
                self.backgroundColor = UIColor.purple
            }
            else if score >= 300 && score < 400 && endNodeCollide == false{
                praiseLabel.text = "Theoretic!"
                praiseLabel.fontColor = UIColor.white
                self.backgroundColor = UIColor.magenta
            }
            else if score >= 400 && score < 500 && endNodeCollide == false{
                praiseLabel.text = "Nondeterministic!"
                praiseLabel.fontColor = UIColor.white
                self.backgroundColor = UIColor.brown
            }
            else if score >= 500 && score < 1000 && endNodeCollide == false{
                praiseLabel.text = "NP - Complete!"
                praiseLabel.fontColor = UIColor.gray
                self.backgroundColor = UIColor.black
            }
            else if score >= 1000 && endNodeCollide == false{
                praiseLabel.text = "You Won!"
                praiseLabel.fontColor = UIColor.cyan
                self.backgroundColor = UIColor.white
                
            }else {
                praiseLabel.text = ""
            }
            scoreLabel.text = "\(score)"
            print(score)
        }
        
        if bodyA.categoryBitMask == SCNPhysicsCollisionCategory.player && bodyB.categoryBitMask == SCNPhysicsCollisionCategory.endNode || bodyA.categoryBitMask == SCNPhysicsCollisionCategory.endNode && bodyB.categoryBitMask == SCNPhysicsCollisionCategory.player{
            endNodeCollide = true
            
            praiseLabel.text = "Restart"
            praiseLabel.fontSize = 75
            praiseLabel.fontColor = UIColor.white
            
            createBTN()
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches{
            let location = touch.location(in: self)
            if endNodeCollide == true {
                if restartBTN.contains(location){
                    restartScene()
                }
                
            }
        }
    }
}



