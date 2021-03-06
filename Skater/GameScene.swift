//
//  GameScene.swift
//  Skater
//
//  Created by Владимир Коваленко on 13.08.2020.
//  Copyright © 2020 Vladimir Kovalenko. All rights reserved.
//

import SpriteKit


struct PhysicsCategory {
    static let skater: UInt32 = 0x1 << 0
    static let brick: UInt32 = 0x1 << 1
    static let gem: UInt32 = 0x1 << 2
    static let bad: UInt32 = 0x1 << 2
}

class GameScene: SKScene, SKPhysicsContactDelegate {
   
    enum BrickLevel: CGFloat {
        
        case low = 0.0
        case high = 100.0
    }
    
    
    // MARK:- Class Properties
    
    var bricks = [SKSpriteNode]()
    var gems = [SKSpriteNode]()
    var bads = [SKSpriteNode]()
    var brickSize = CGSize.zero
    var brickLevel = BrickLevel.low
    var scrollSpeed: CGFloat = 5.0
    let startingScrollSpeed: CGFloat = 5.0
    let gravitySpeed: CGFloat = 1.5
    var score: Int = 0
    var highScore: Int = 0
    var lastScoreUpdateTime: TimeInterval = 0.0
    var lastUpdateTime: TimeInterval?
    let skater = Skater(imageNamed: "skater")
    
    
    
    // MARK:- Setup and Lifecycle Methods
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = CGVector(dx: 0.0, dy: -6.0)
        physicsWorld.contactDelegate = self
        
        anchorPoint = CGPoint.zero
        
        let background = SKSpriteNode(imageNamed: "background")
        let xMid = frame.midX
        let yMid = frame.midY
        background.position = CGPoint(x: xMid, y: yMid)
        addChild(background)
        
        setupLabels()
        skater.setUpPhysicsBody()
        
        addChild(skater)
        
        // Add a tap gesture recognizer to know when the user tapped the screen
        let tapMethod = #selector(GameScene.handleTap(tapGesture:))
        let tapGesture = UITapGestureRecognizer(target: self, action: tapMethod)
        view.addGestureRecognizer(tapGesture)
        
        startGame()
    }
    
    
    func resetSkater() {

        let skaterX = frame.midX / 2.0
        let skaterY = skater.frame.height / 2.0 + 64.0
        skater.position = CGPoint(x: skaterX, y: skaterY)
        skater.zPosition = 10
        skater.minimumY = skaterY
        
        skater.zRotation = 0.0
        skater.physicsBody?.velocity = CGVector(dx: 0.0, dy: 0.0)
        skater.physicsBody?.angularVelocity = 0.0
    }
    
    func setupLabels() {
        
        
        let scoreTextLabel: SKLabelNode = SKLabelNode(text: "score")
        scoreTextLabel.position = CGPoint(x: 14.0, y: frame.size.height - 20.0)
        scoreTextLabel.horizontalAlignmentMode = .left
        scoreTextLabel.fontName = "Courier-Bold"
        scoreTextLabel.fontSize = 14.0
        scoreTextLabel.zPosition = 20
        addChild(scoreTextLabel)
        
        
        let scoreLabel: SKLabelNode = SKLabelNode(text: "0")
        scoreLabel.position = CGPoint(x: 14.0, y: frame.size.height - 40.0)
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.fontName = "Courier-Bold"
        scoreLabel.fontSize = 18.0
        scoreLabel.name = "scoreLabel"
        scoreLabel.zPosition = 20
        addChild(scoreLabel)
        
        
        let highScoreTextLabel: SKLabelNode = SKLabelNode(text: "high score")
        highScoreTextLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 20.0)
        highScoreTextLabel.horizontalAlignmentMode = .right
        highScoreTextLabel.fontName = "Courier-Bold"
        highScoreTextLabel.fontSize = 14.0
        highScoreTextLabel.zPosition = 20
        addChild(highScoreTextLabel)
        
        
        let highScoreLabel: SKLabelNode = SKLabelNode(text: "0")
        highScoreLabel.position = CGPoint(x: frame.size.width - 14.0, y: frame.size.height - 40.0)
        highScoreLabel.horizontalAlignmentMode = .right
        highScoreLabel.fontName = "Courier-Bold"
        highScoreLabel.fontSize = 18.0
        highScoreLabel.name = "highScoreLabel"
        highScoreLabel.zPosition = 20
        addChild(highScoreLabel)
    }
    
    func updateScoreLabelText() {
        
        if let scoreLabel = childNode(withName: "scoreLabel") as? SKLabelNode {
            scoreLabel.text = String(format: "%04d", score)
        }
    }
    
    func updateHighScoreLabelText() {
        
        if let highScoreLabel = childNode(withName: "highScoreLabel") as? SKLabelNode {
            highScoreLabel.text = String(format: "%04d", highScore)
        }
    }
    
    func startGame() {
        
        resetSkater()
        score = 0
        scrollSpeed = startingScrollSpeed
        brickLevel = .low
        lastUpdateTime = nil
        
        for brick in bricks {
            brick.removeFromParent()
        }
        
        bricks.removeAll(keepingCapacity: true)
        
        for gem in gems {
            removeGem(gem)
        }
        for bad in bads{
        removeMonster(bad)
        }
    }
    
    func gameOver() {
    
        if score > highScore {
            highScore = score
            
            updateHighScoreLabelText()
        }
                startGame()
    }
    
    
    // MARK:- Spawn and Remove Methods
    
    func spawnBrick(atPosition position: CGPoint) -> SKSpriteNode {
        let brick = SKSpriteNode(imageNamed: "sidewalk")
        brick.position = position
        brick.zPosition = 8
        addChild(brick)
 
        brickSize = brick.size
        
        bricks.append(brick)
        
        let center = brick.centerRect.origin
        brick.physicsBody = SKPhysicsBody(rectangleOf: brick.size, center: center)
        brick.physicsBody?.affectedByGravity = false
        
        brick.physicsBody?.categoryBitMask = PhysicsCategory.brick
        brick.physicsBody?.collisionBitMask = 0
        
        return brick
    }
    
    func spawnGem(atPosition position: CGPoint) {
        
        let gem = SKSpriteNode(imageNamed: "gem")
        gem.position = position
        gem.zPosition = 9
        addChild(gem)
        
        gem.physicsBody = SKPhysicsBody(rectangleOf: gem.size, center: gem.centerRect.origin)
        gem.physicsBody?.categoryBitMask = PhysicsCategory.gem
        gem.physicsBody?.affectedByGravity = false
        
        gems.append(gem)
    }
    
    func removeGem(_ gem: SKSpriteNode) {
        
        gem.removeFromParent()
        print("gem")
        if let gemIndex = gems.index(of: gem) {
            gems.remove(at: gemIndex)
        }
    }
    
    func spawnMonster(atPosition position : CGPoint){
        let bad = SKSpriteNode(imageNamed: "bad")
        bad.position = position
        bad.zPosition = 7
        addChild(bad)
        
        bad.physicsBody = SKPhysicsBody(circleOfRadius: max(bad.size.width/100, bad.size.height/100))
        bad.physicsBody?.affectedByGravity = false
        bad.physicsBody?.categoryBitMask = PhysicsCategory.bad
        
       
        
        bads.append(bad)
    }
    func  removeMonster (_ bad: SKSpriteNode){
        bad.removeFromParent()
        makeHit()
        if let badIndex = bads.index(of: bad) {
            bads.remove(at: badIndex)
        }
    }
    func makeHit(){
       
        print("hit")
        score = score - 100
        print("\(score)")
        updateScoreLabelText()
        run(SKAction.playSoundFileNamed("monster.wav", waitForCompletion: false))
        
    }
    // MARK:- Update Methods
    
    func updateBricks(withScrollAmount currentScrollAmount: CGFloat) {
        var farthestRightBrickX: CGFloat = 0.0
        
        for brick in bricks {
            
            let newX = brick.position.x - currentScrollAmount
            
            if newX < -brickSize.width {
                
                brick.removeFromParent()
                
                if let brickIndex = bricks.index(of: brick) {
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
            let brickY = (brickSize.height / 2.0) + brickLevel.rawValue
            
            let randomNumber = arc4random_uniform(99)
            let randomAmount = CGFloat(arc4random_uniform(150))
            let newPadX = brickX + randomAmount + 20.0
            let newPadY = brickY + skater.size.height
            if randomNumber < 2 && score > 10 {
            
                let gap = 20.0 * scrollSpeed
                brickX += gap
                
                let randomGemYAmount = CGFloat(arc4random_uniform(150))
                let newGemY = brickY + skater.size.height + randomGemYAmount
                let newGemX = brickX - gap / 2.0
               
                spawnGem(atPosition: CGPoint(x: newGemX, y: newGemY))
                
            }
            else if randomNumber < 4 && score > 20 {
                
                if brickLevel == .high {
                    brickLevel = .low
                    
                    spawnMonster(atPosition: CGPoint(x: newPadX, y: newPadY))
                }
                else if brickLevel == .low {
                    brickLevel = .high
                  
                }
            }
            
            let newBrick = spawnBrick(atPosition: CGPoint(x: brickX, y: brickY))
            farthestRightBrickX = newBrick.position.x
        }
    }
    
    func updateGems(withScrollAmount currentScrollAmount: CGFloat) {
        
        for gem in gems {
            let thisGemX = gem.position.x - currentScrollAmount
            gem.position = CGPoint(x: thisGemX, y: gem.position.y)
            if gem.position.x < 0.0 {
                
                removeGem(gem)
            }
        }
    }
    func updateBad(withScrollAmount currentScrollAmount: CGFloat){
        for bad in bads {
            let badX = bad.position.x - currentScrollAmount
            bad.position = CGPoint(x: badX, y: bad.position.y)
            if bad.position.x < 0.0 {
                
                removeMonster(bad)
            }
        }
    }
    func updateSkater() {
        
        if let velocityY = skater.physicsBody?.velocity.dy {
            
            if velocityY < -100.0 || velocityY > 100.0 {
                skater.isOnGround = true
            }
        }
        
        let isOffScreen = skater.position.y < 0.0 || skater.position.x < 0.0
        
        let maxRotation = CGFloat(GLKMathDegreesToRadians(85.0))
        let isTippedOver = skater.zRotation > maxRotation || skater.zRotation < -maxRotation
        
        if isOffScreen || isTippedOver {
            gameOver()
        }
    }
    
    func updateScore(withCurrentTime currentTime: TimeInterval) {
        
        let elapsedTime = currentTime - lastScoreUpdateTime
        
        if elapsedTime > 1.0 {
        
            score += Int(scrollSpeed)
        
            lastScoreUpdateTime = currentTime
            
            updateScoreLabelText()
        }
    }
    
    
    // MARK:- Main Game Loop Method
    
    override func update(_ currentTime: TimeInterval) {
        
        scrollSpeed += 0.01
        
        var elapsedTime: TimeInterval = 0.0
        
        if let lastTimeStamp = lastUpdateTime {
            elapsedTime = currentTime - lastTimeStamp
        }
        
        lastUpdateTime = currentTime
        
        let expectedElapsedTime: TimeInterval = 1.0 / 60.0
        
        let scrollAdjustment = CGFloat(elapsedTime / expectedElapsedTime)
        let currentScrollAmount = scrollSpeed * scrollAdjustment
        
        updateBricks(withScrollAmount: currentScrollAmount)
        updateSkater()
        updateGems(withScrollAmount: currentScrollAmount)
        updateScore(withCurrentTime: currentTime)
        updateBad(withScrollAmount: currentScrollAmount)
    }
    
    
    // MARK:- Touch Handling Methods
    
    @objc func handleTap(tapGesture: UITapGestureRecognizer) {
        print("tapped")
        if skater.isOnGround {
            print("Jumped")
            skater.physicsBody?.applyImpulse(CGVector(dx: 0.0, dy: 260.0))
            skater.isOnGround = true
        }
    }
    
    
    // MARK:- SKPhysicsContactDelegate Methods
    
    func didBegin(_ contact: SKPhysicsContact) {
            if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.brick {
            
            skater.isOnGround = true
        }
                
        else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.gem {
            
            if let gem = contact.bodyB.node as? SKSpriteNode {
                
                removeGem(gem)
                
                score += 50
                updateScoreLabelText()
                run(SKAction.playSoundFileNamed("gem.wav", waitForCompletion: false))
            }
               else if contact.bodyA.categoryBitMask == PhysicsCategory.skater && contact.bodyB.categoryBitMask == PhysicsCategory.bad {
               
                if let bad = contact.bodyB.node as? SKSpriteNode{
                    removeMonster(bad)
                }
            }
             
        }
    }
}
