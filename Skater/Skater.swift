//
//  Skater.swift
//  Skater
//
//  Created by Владимир Коваленко on 13.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import UIKit
import SpriteKit


class Skater: SKSpriteNode {
    var velosity = CGPoint.zero
    var minimumY : CGFloat = 0.0
    var jumpSpeed : CGFloat = 20.0
    var isOnGround = true
      
    
    func setUpPhisicsBody(){
        if let skaterTexture = texture{
            physicsBody = SKPhysicsBody(texture: skaterTexture, size: size)
            physicsBody?.isDynamic = true
            physicsBody?.density = 6.0
            physicsBody?.allowsRotation = true
            physicsBody?.angularDamping = 1.0
            
            physicsBody?.categoryBitMask = PhisicsCategory.skater
            physicsBody?.collisionBitMask = PhisicsCategory.brick
            physicsBody?.contactTestBitMask = PhisicsCategory.brick | PhisicsCategory.gem//vertical = pipe many values in one
        }
    }
}
