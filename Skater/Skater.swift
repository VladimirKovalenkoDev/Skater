//
//  Skater.swift
//  Skater
//
//  Created by Владимир Коваленко on 13.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//


import SpriteKit


class Skater: SKSpriteNode {
    var velosity = CGPoint.zero
    var minimumY : CGFloat = 0.0
    var jumpSpeed : CGFloat = 20.0
    var isOnGround = true
     
    
    func setUpPhysicsBody(){
       
       
          let skaterTexture = SKSpriteNode(imageNamed: "skater")
                   
        physicsBody = SKPhysicsBody(texture: skaterTexture.texture!, size: skaterTexture.size)
                   physicsBody?.isDynamic = true
                   physicsBody?.density = 6.0
                   physicsBody?.allowsRotation = false
                   physicsBody?.angularDamping = 1.0
                  // physicsBody?.affectedByGravity = true
                   
                   physicsBody?.categoryBitMask = PhysicsCategory.skater
                   physicsBody?.collisionBitMask = PhysicsCategory.brick
        physicsBody?.collisionBitMask = PhysicsCategory.pad
        physicsBody?.contactTestBitMask = PhysicsCategory.brick | PhysicsCategory.gem | PhysicsCategory.pad
               
        
        
    }
}
