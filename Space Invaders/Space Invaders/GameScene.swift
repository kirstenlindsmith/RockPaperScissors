//
//  GameScene.swift
//  Space Invaders
//
//  Created by Francisco Franco on 3/2/19.
//  Copyright © 2019 Francisco Franco. All rights reserved.
//

// TO DO:
// 1.) fix bug that increases lifes when heart passes player
// 2.)
// 3.)
// 4.)
// 5.)

import SpriteKit
import GameplayKit

// global variable that keep game score
var gameScore = 0

class GameScene: SKScene, SKPhysicsContactDelegate
{
    // label used to display score
    let scoreLabel = SKLabelNode(fontNamed: "the bold font")
    
    // variable that keeps current level and label used to display level
    var level = 0
    let levelLabel = SKLabelNode(fontNamed: "the bold font") // implement
    
    // variable that keeps number of current lives and label used to display level
    var livesNumber = 3
    let livesLabel = SKLabelNode(fontNamed: "the bold font")
    
    // creating a node that represents the players ship
    let player = SKSpriteNode(imageNamed: "ship")
    
    let bulletSound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // Label that starts game when pressed
    let tapToStartLabel = SKLabelNode(fontNamed: "the bold font")
    
    
    enum gameState
    {
        case preGame // prior to game start
        case inGame // when game state is during the game
        case afterGame // when game finishes
    }
    
    var currentGameState = gameState.preGame
    
    // setting physics of objects for later use
    struct physicsCategories
    {
        static let None : UInt32 = 0
        static let Player : UInt32 = 0b1 // 1
        static let Bullet : UInt32 = 0b10 // 2
        static let Enemy : UInt32 = 0b100 // 4
        static let NewLife : UInt32 = 0b101 // 5
        static let PowerUp : UInt32 = 0b110  // 6
    }
    
    // random utility functions that produce random locations
    func random() -> CGFloat
    {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random (min: CGFloat, max: CGFloat) -> CGFloat
    {
        return random() * (max - min) + min
    }
    
    
    // creating game area
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
        // set game score
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
    
        // creates 2 backgrounds used for the scrolling background
        for i in 0...1
        {
            let background = SKSpriteNode(imageNamed: "background")
            background.size = self.size
            background.anchorPoint = CGPoint(x: 0.5 , y: 0)
            background.position = CGPoint(x: self.size.width/2, y: self.size.height * CGFloat(i))
            background.zPosition = 0;
            background.name = "Background"
            self.addChild(background);
        }
        
        // setting all of the players attributes and physics
        player.setScale(0.6); //size of ship
        player.position = CGPoint(x: self.size.width/2 , y: 0 - player.size.height)
        player.zPosition = 2
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = physicsCategories.Player
        player.physicsBody!.collisionBitMask = physicsCategories.None
        player.physicsBody!.contactTestBitMask = physicsCategories.Enemy
        self.addChild(player)
        
        // setting all of ScoreLabel's attributes and physics
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.23, y: self.size.height * 0.9)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        // setting all of livesLabel's attributes and physics
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.76, y: self.size.height * 0.9)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        // setting all of tapToStartLabel's attributes and physics
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        tapToStartLabel.position = CGPoint(x: self.size.width/1.45, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        // makes everything fade onto the scene for looks
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        
    }
    
    // used to determine when to scroll background
    var lastUpdateTime: TimeInterval = 0
    var deltaFrameTime: TimeInterval = 0
    var movePerSecond: CGFloat = 600.0 // use this to make background scroll faster when levels change or something?...
    
    //  runs once per game frame, and we are using it to move our background to make it scroll
    override func update(_ currentTime: TimeInterval)
    {
        // change, find better implementation
        // creating a 1% chance of spawning a new a life every game frame
        let num = Int.random(in: 1 ... 400)
        
        if num == 1
        {
            spawnNewLife()
        }
        
        else if num == 2
        {
            //spawnPowerUp()
        }
        
        
        if lastUpdateTime == 0
        {
            lastUpdateTime = currentTime
        }
        else
        {
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        let amountToMoveBackground = movePerSecond * CGFloat(deltaFrameTime)
        
        self.enumerateChildNodes(withName: "Background")
        {
            background, stop in
            
            // only scroll background when we are in game
            if self.currentGameState == gameState.inGame
            {
                background.position.y -= amountToMoveBackground
            }
            
            // once the background goes off the bottom of screen, put it back at the top for scrolling
            if background.position.y < -self.size.height
            {
                background.position.y += self.size.height * 2
            }
        }
    
    }
    
    // function that handles what happens when the game starts
    func startGame()
    {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        // moves the ship onto the screen from the bottom, like it was flying in
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        
    }
    
    // function that handles what happens when you lose a life
    func loseALife()
    {
        // decrease number of lives by 1 and update the text in the label to reflect it
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        
        // make lives label grow and shrink when you lose a life
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        // end game when out of lives
        if livesNumber == 0
        {
            runGameOver()
        }
    }
    
    // function that increases score whenever a bullet comes into contact with an enemy
    func addSCore()
    {
        // increase score by one and update label to reflect it
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"
        
        // if score reaches 10, go to level 2, reaches 25 go to level 3, and so on ... implement more
        if gameScore == 10 || gameScore == 25 || gameScore == 50
        {
            startNewLevel()
        }
        
    }
    
    // function that handles what happens when the game ends
    func runGameOver()
    {
        // set game state to after game
        currentGameState = gameState.afterGame
        
        // removes everything from screen
        self.removeAllActions()
        
        // stops bullets from spawning
        self.enumerateChildNodes(withName: "Bullet")
        {
            bullet, stop in
            bullet.removeAllActions()
        }
        
        // stops enemies from spawning
        self.enumerateChildNodes(withName: "Enemy")
        {
            enemy, stop in
            enemy.removeAllActions()
        }
        
        // stops enemies from spawning
        self.enumerateChildNodes(withName: "newLife")
        {
            newLife, stop in
            newLife.removeAllActions()
        }
        
        // stops enemies from spawning
        self.enumerateChildNodes(withName: "powerUp")
        {
            powerUp, stop in
            powerUp.removeAllActions()
        }
        
        // changes scenes
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScence = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScence, changeSceneAction])
        self.run(changeSceneSequence)
        
    }
    
    // funtion that changes game scenes
    func changeScene()
    {
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    // function that determines when objects collide with one another
    func didBegin(_ contact: SKPhysicsContact)
    {
        // create 2 physcis bodies
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
        
        // handles when enemhy has hit the player
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.Enemy
        {
            // make explosion if player and enemy collide
            if body1.node != nil
            {
                spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            // make explosion if player and enemy collide
            if body2.node != nil
            {
                spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            // get rid of enemy and player
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            // start game over scene
            runGameOver()
        }
        
        // handles when bullet has hit the enemy
        if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.Enemy
        {
            // increase score when a bullet hits an enemy
            addSCore()
            
            if body2.node != nil
            {
                // if the enemy is off screen, dont collide
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                // when on screen, make an explosion when they collide
                else
                {
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            // get rid of the bullet, enemy, and explosion
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        // handles when bullet has hit a new life
        if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.NewLife
        {
            // increase score when a bullet hits an enemy
            gainALife()
            
            if body2.node != nil
            {
                // if the enemy is off screen, dont collide
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                    // when on screen, make an explosion when they collide
                else
                {
                    // change from explosion to something happy for a life
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            // get rid of the bullet, enemy, and explosion
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        // handles when a newlife object has hit a player
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.NewLife
        {
            // increase score when a bullet hits an enemy
            gainALife()
            
            if body2.node != nil
            {
                // if the enemy is off screen, dont collide
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                    // when on screen, make an explosion when they collide
                else
                {
                    body2.node?.removeFromParent()
                }
            }
            
            
            
        }
        
        // handles when bullet has hit a power up
        if body1.categoryBitMask == physicsCategories.Bullet && body2.categoryBitMask == physicsCategories.PowerUp
        {
            // change
            // increase score when a bullet hits an enemy
            gainALife()
            
            if body2.node != nil
            {
                // if the enemy is off screen, dont collide
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                    // when on screen, make an explosion when they collide
                else
                {
                    // change from explosion to something happy for a life
                    spawnExplosion(spawnPosition: body2.node!.position)
                }
            }
            
            // get rid of the bullet and powerup
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
        }
        
        // handles when player comes in contact with hit a power up
        if body1.categoryBitMask == physicsCategories.Player && body2.categoryBitMask == physicsCategories.PowerUp
        {
            // change
            // increase score when a bullet hits an enemy
            gainALife()
            
            if body2.node != nil
            {
                // if the enemy is off screen, dont collide
                if body2.node!.position.y > self.size.height
                {
                    return
                }
                    // when on screen, make an explosion when they collide
                else
                {
                     body2.node?.removeFromParent()
                }
            }
            
            // get rid of the power up
            body2.node?.removeFromParent()
        }
        
        
    }
    
    
    // mimics explosion graphic of space ships
    func spawnExplosion(spawnPosition: CGPoint)
    {
        // creates explosion
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(1)
        self.addChild(explosion)
        
        // make explosion fade in and out
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeIn(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        // make and run explosion sequence
        let explosiveSequence = SKAction.sequence([explosionSound ,scaleIn, fadeOut, delete])
        explosion.run(explosiveSequence)
    }
    
    
    // function that fires and moves bullet
    func fireBullet()
    {
        // create bullet and set all of its attributes
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
        
        // make and run bullet sequence
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
    }
    
    // function that spawns an enemy
    func spawnEnemy()
    {
        // create a random x and y to spawn enemy at
        let randomXstart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXend = random(min: gameArea.minX , max: gameArea.maxX)
        
        // start and end points of the spawn
        let startPoint = CGPoint(x: randomXstart , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXend,  y: -self.size.height * 0.2)
        
        //create enemy and all its attributes
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(0.4)
        enemy.position = startPoint
        enemy.zPosition = 2
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = physicsCategories.Enemy
        enemy.physicsBody!.collisionBitMask = physicsCategories.None
        enemy.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint , duration: 3.0)
        
        // make and run enemy sequence
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy, loseALifeAction])
        
        
        if currentGameState == gameState.inGame
        {
            enemy.run(enemySequence)
        }
        
        
        //takes care of rotations of enemy depending on their direction
//        let dx = endPoint.x - startPoint.x
//        let dy = endPoint.y - startPoint.y
//        let amountToRotate = atan2(dy, dx)
//        enemy.zRotation = amountToRotate
    
    }
    
    // function that spawns a new life
    func spawnNewLife()
    {
        // create a random x and y to spawn new life at
        let randomXstart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXend = random(min: gameArea.minX , max: gameArea.maxX)
        
        // start and end points of the spawn
        let startPoint = CGPoint(x: randomXstart , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXend,  y: -self.size.height * 0.2)
        
        //create newLife object and all its attributes
        let newLife = SKSpriteNode(imageNamed: "newlife")
        newLife.name = "newLife"
        newLife.setScale(0.12)
        newLife.position = startPoint
        newLife.zPosition = 2
        newLife.physicsBody = SKPhysicsBody(rectangleOf: newLife.size)
        newLife.physicsBody!.affectedByGravity = false
        newLife.physicsBody!.categoryBitMask = physicsCategories.NewLife
        newLife.physicsBody!.collisionBitMask = physicsCategories.None
        newLife.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        self.addChild(newLife)
        
        let moveNewLife = SKAction.move(to: endPoint , duration: 3.5)
        
        // make and run newLife sequence
        let deleteNewLife = SKAction.removeFromParent()
        let gainALifeAction = SKAction.run(gainALife)
        let newLifeSequence = SKAction.sequence([moveNewLife, deleteNewLife, gainALifeAction])
        
        if currentGameState == gameState.inGame
        {
            newLife.run(newLifeSequence)
        }
        
    }
    
    // increases number of lives by 1
    func gainALife()
    {
        livesNumber += 1
        
        livesLabel.text = "Lives: \(livesNumber)"
        
        // make lives label grow and shrink when you gain a life
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
    }
    
    func spawnPowerUp()
    {
        // create a random x and y to spawn new life at
        let randomXstart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXend = random(min: gameArea.minX , max: gameArea.maxX)
        
        // start and end points of the spawn
        let startPoint = CGPoint(x: randomXstart , y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXend,  y: -self.size.height * 0.2)
        
        //create newLife object and all its attributes
        let powerUp = SKSpriteNode(imageNamed: "Icon")
        powerUp.name = "powerUp"
        powerUp.setScale(0.12)
        powerUp.position = startPoint
        powerUp.zPosition = 2
        powerUp.physicsBody = SKPhysicsBody(rectangleOf: powerUp.size)
        powerUp.physicsBody!.affectedByGravity = false
        powerUp.physicsBody!.categoryBitMask = physicsCategories.PowerUp
        powerUp.physicsBody!.collisionBitMask = physicsCategories.None
        powerUp.physicsBody!.contactTestBitMask = physicsCategories.Player | physicsCategories.Bullet
        self.addChild(powerUp)
        
        let movePowerUp = SKAction.move(to: endPoint , duration: 3.5)
        
        // make and run enemy sequence
        let deletePowerUp = SKAction.removeFromParent()
        let PowerUpSequence = SKAction.sequence([movePowerUp, deletePowerUp])
        
        if currentGameState == gameState.inGame
        {
            powerUp.run(PowerUpSequence)
        }
    }
    
    // enables powerUp for 15 seconds
    func enablePowerUp()
    {
        
    }
    
    // function that starts a new level based on players score
    func startNewLevel()
    {
        // increase level by one
        level += 1
        
        if self.action(forKey: "spawningEnemies") != nil
        {
            self.removeAction(forKey: "spawningEnemies")
        }
        
        // create duration for the levels
        var levelDuration = TimeInterval()
        
        switch level
        {
            // level 1 will span enemies every 1.2 secs
            case 1: levelDuration = 1.2
            
            // level 2 will span enemies every 1 secs
            case 2: levelDuration = 1
            
            // level 3 will span enemies every 0.8 secs
            case 3: levelDuration = 0.8
            
            // level 4 will span enemies every 0.5 secs
            case 4: levelDuration = 0.5
            
            default:
                levelDuration = 0.5
                print("Cannot find level info");
        }
        
        // spawn enemies
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration) //spawn frequency
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        if currentGameState == gameState.preGame
        {
            startGame()
        }
        
        else if currentGameState == gameState.inGame
        {
            fireBullet()
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // moves the ship left and right by dragging on the screen
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            let previousTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousTouch.x
            
            if currentGameState == gameState.inGame
            {
                 player.position.x += amountDragged
            }

            
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
