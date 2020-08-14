//
//  GameScene.swift
//  Skater
//
//  Created by Владимир Коваленко on 13.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import SpriteKit
import GameplayKit

struct PhisicsCategory {
    
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
}

class GameScene: SKScene,SKPhysicsContactDelegate {
    
    var bricks = [SKSpriteNode]()
    var brickSize = CGSize.zero
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    let gravitySpeed: CGFloat = 1.5
    var lastUpdateTime: TimeInterval?
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -0.6)
        physicsWorld.contactDelegate = self
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        
        addChild(background)
        
        skater.setUpPhisicsBody()
        addChild(skater)
        
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        startGame()
        
    }
    
    func resetSkater(){
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func spawnBricks(at position: CGPoint) -> SKSpriteNode {
        
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        brickSize = brick.size
        
        bricks.append(brick)
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        brick.physicsBody?.categoryBitMask = PhisicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        for brick in bricks {
            let newX = brick.position.x - currentScrollAmount
            if newX < -brickSize.width{
                brick.removeFromParent()
                if let brickIndex = bricks.firstIndex(of: brick){
                    bricks.remove(at: brickIndex)
                }
            } else {
                brick.position = CGPoint(x: newX, y: brick.position.y)
                if brick.position.x > farthestRightBrickX {
                    farthestRightBrickX = brick.position.x
                }
            }
        }
        while farthestRightBrickX < frame.width {
            var brickX = farthestRightBrickX + brickSize.width + 1.0
            let brickY = brickSize.height / 2.0
            let randomNumber = arc4random_uniform(99)
            
            if randomNumber < 5{
                let gap = 20.0 * scrollSpeed
                brickX += gap
            }
            let newBrick = spawnBricks(at: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
        
    }
    func updateSkater() {
         if let velocityY = skater.physicsBody?.velocity.dy {
                   
                   if velocityY < -100.0 || velocityY > 100.0 {
                       skater.isOnGround = false
                   }
               }
               
               // Check if the game should end
               let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
               
               let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
               let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
               
               if isOffScreen || isTippedOver {
                   gameOver()
               }
        
    }
    override func update(_ currentTime: TimeInterval) {
        var elapsedTime : TimeInterval = 0.0
        if let lastTimeStamp = lastUpdateTime{
            elapsedTime = currentTime - lastTimeStamp
        }
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
               
             
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
               
        updateBricks(withScrollAmount: currentScrollAmount)
            updateSkater()
    }
    @objc func handleTap(tapGesture: UITapGestureRecognizer){
        //if skater.isOnGround {
        //    skater.velosity = CGPoint(x: 0.0, y: skater.jumpSpeed)
        //    skater.isOnGround = false
       // }
        if skater.isOnGround {
            
            skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
        }
    }
    // MARK: - contact of the bodies
    func didBegin(_ contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == PhisicsCategory.skater && contact.bodyB.categoryBitMask==PhisicsCategory.brick{
            skater.isOnGround = true
        }
       
    }
    func startGame(){
        resetSkater()
        scrollSpeed = startingScrollSpeed
        lastUpdateTime = nil
        for brick in bricks {
            brick.removeFromParent()
        }
        bricks.removeAll(keepingCapacity: true)
    }
    func gameOver(){
        startGame()
    }
}
