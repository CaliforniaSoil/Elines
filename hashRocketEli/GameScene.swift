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




class GameScene: SKScene {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    let manager = CMMotionManager()
    private var lastUpdateTime : TimeInterval = 0
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    var player = SKSpriteNode()
    var wallPair = SKNode()
    var moveAndRemove = SKAction()
    
    
    
    override func sceneDidLoad() {
        player.position = CGPoint(x: 0, y: 100)
        player.setScale(0.15)
        self.addChild(player)
        super.sceneDidLoad()


        
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody?.affectedByGravity = true
        player.physicsBody?.isDynamic = true
        player.physicsBody?.categoryBitMask = 1
        player.physicsBody?.collisionBitMask = 2
        player.physicsBody?.fieldBitMask = 1
        player.physicsBody?.contactTestBitMask = 2
        player = SKSpriteNode(imageNamed: "Eli")
        
        
        let spawn = SKAction.run({
            self.createWall()
            
        })
        
        let delay = SKAction.wait(forDuration: 1.5)
        let spawnDelay = SKAction.sequence([spawn, delay])
        let spawnDelayForever = SKAction.repeatForever(spawnDelay)
        self.run(spawnDelayForever)
        
        let distance = CGFloat(self.frame.height + wallPair.frame.height)
        
        let moveWalls = SKAction.moveBy(x: 0, y: distance, duration: TimeInterval((0.01) * distance))
        let removeWalls = SKAction.removeFromParent()
        moveAndRemove = SKAction.sequence([moveWalls, removeWalls])

        
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data, error)in
            self.physicsWorld.gravity = CGVector(dx: CGFloat((data?.acceleration.x)!), dy: CGFloat((data?.acceleration.y)!))
            let playerTexture1 = SKTexture(imageNamed: "Eli")
            playerTexture1.filteringMode = .nearest

        }
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
        
        
        let randNum = (Int(arc4random_uniform(45) + 5))
//        let randNum2 = (Int(arc4random_uniform(45) + 5))
        rightWall.position = CGPoint(x: -110, y: -200)
//        rightWall.size = CGSize.init(width: -2300, height: 100)
        leftWall.position = CGPoint(x: 110, y: -200)
//        leftWall.size = CGSize.init(width: 400, height: 100)
        wallPair.position = CGPoint(x: randNum, y: -150)

        
        leftWall.setScale(0.15)
        rightWall.setScale(0.15)
        
        wallPair.addChild((rightWall))
        wallPair.addChild((leftWall))
        

        wallPair.run(moveAndRemove)
        self.addChild(wallPair)
    }
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "BrokenCode.png")
        background.position = CGPoint(x: size.width/2, y: size.height/2)
        background.zPosition = -1
        addChild(background)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
}
}



