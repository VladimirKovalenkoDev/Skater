//
//  GameScene.swift
//  Skater
//
//  Created by Владимир Коваленко on 13.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var bricks = [SKSpriteNode]()
    var brickSize = CGSize.zero
    var scrollSpeed: CGFloat = 5.0
    var lastUpdateTime: TimeInterval?
    let skater = Skater(imageNamed: "skater")
    
    override func didMove(to view: SKView) {
        anchorPoint = CGPoint.zero
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        resetSkater()
        addChild(skater)
        
    }
    func resetSkater(){
        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
    }
    func spawnBricks(at position: CGPoint) -> SKSpriteNode {
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
        
        brickSize = brick.size
        
        bricks.append(brick)
        
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
            
    }
}
