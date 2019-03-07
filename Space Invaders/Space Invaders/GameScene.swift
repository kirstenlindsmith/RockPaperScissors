//
//  GameScene.swift
//  Space Invaders
//
//  Created by Francisco Franco on 3/2/19.
//  Copyright © 2019 Francisco Franco. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate
{
    var gameScore = 0
    let scoreLabel = SKLabelNode(fontNamed: "the bold font")
    
    var level = 0
    let levelLabel = SKLabelNode(fontNamed: "the bold font") // implement
    
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "the bold font")
    
    let player = SKSpriteNode(imageNamed: "ship")
    
    let bulletSound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    
    struct physicsCategories
    {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 // 1
        static let Bullet : UInt32 = 0b10 // 2
        static let Enemy : UInt32 = 0b100 // 4
    }
    
    //random utility functions
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random (min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    
    let gameArea: CGRect
    override init(size: CGSize)
    {

        let maxAspectRatio: CGFloat = 16.0 / 9.0;
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2

        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView)
    {
        self.physicsWorld.contactDelegate = self
        
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0;
        self.addChild(background);
        
        player.setScale(0.6); //size of ship
        player.position = CGPoint(x: self.size.width/2 , y: self.size.height * 0.2)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        self.addChild(player)
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.23, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        //left off @
        
        
        // for now
        startNewLevel()
    }
    
    func loseALife()
    {
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0
        {
            runGameOver()
        }
    }
    
    
    func addSCore()
    {
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        // if score reaches 10, go to level 2, reaches 25 go to level 3, and so on
        if gameScore == 10 || gameScore == 25 || gameScore == 50
        {
            startNewLevel()
        }
        
    }
    
    func runGameOver()
    {
        self.removeAllActions()
        
        self.enumerateChildNodes(withName: "Bullet", using: <#(SKNode, UnsafeMutablePointer<ObjCBool>) -> Void#>)
        
        
    }
    
    // function that determines when objects collide with one another
    func didBegin(_ contact: SKPhysicsContact)
    {
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask
        {
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
        else
        {
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        // handles when player has hit the enemy
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Enemy
        {
            if body1.node != nil
            {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil
            {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
        }
        
        // handles when bullet has hit the enemy
        if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.Enemy
        {
            addSCore()
            
            if body2.node != nil
            {
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                else
                {
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
    }
    
    
    // mimics explosion graphic of space ships
    func spawnExplosion(spawnPosition: CGPoint)
    {
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(1)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeIn(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosiveSequence = SKAction.sequence([explosionSound ,scaleIn, fadeOut, delete])
        
        explosion.run(explosiveSequence)
        
        // left off @ 34.45
    }
    
    
    func fireBullet()
    {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = physicsCategories.Bullet
        bullet.physicsBody!.collisionBitMask = physicsCategories.None
        bullet.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height , duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        //left off at
        
    }
    
    
    func spawnEnemy()
    {
        let randomXstart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXend = random(min: gameArea.minX , max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXstart , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXend,  y: -self.size.height * 0.2)
        
        //create and add enemy to scene
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.None
        enemy.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint , duration: 1.5)
        
        //delete enemy
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        enemy.run(enemySequence)
        
        //takes care of rotations of enemy depending on their direction
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        
    }
    
    
    func startNewLevel()
    {
        level += 1
        
        if self.action(forKey: "spawningEnemies") != nil
        {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        switch level
        {
            case 1: levelDuration = 1.2
            case 2: levelDuration = 1
            case 3: levelDuration = 0.8
            case 4: levelDuration = 0.5
            
            default:
                levelDuration = 0.5
                print("Cannot find level info");
            
        }
        
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration) //spawn frequency
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        fireBullet()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousTouch.x
            
            player.position.x += amountDragged
            
            //when player moves to far to right, bump back into game area
            if player.position.x > gameArea.maxX - player.size.width/2
            {
                player.position.x = gameArea.maxX - player.size.width/2
            }

            //when player moves to far to left, bump back into game area
            if player.position.x < gameArea.minX + player.size.width/2
            {
                player.position.x = gameArea.minX + player.size.width/2
            }
            
        }
        
        
    }

    
}
