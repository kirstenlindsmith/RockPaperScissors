//
//  GameOverScene.swift
//  Space Invaders
//
//  Created by Francisco Franco on 3/7/19.
//  Copyright © 2019 Francisco Franco. All rights reserved.
//

import Foundation
import SpriteKit

class GameOverScene: SKScene
{
    // creates label to restart game
    let restartLabel = SKLabelNode(fontNamed: "the bold font")
    
    override func didMove(to view: SKView)
    {
        // creates background and sets its attributes
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0;
        self.addChild(background);
        
        // creates GAMEOVER label and sets its attributes
        let gameOverLabel = SKLabelNode(fontNamed: "the bold font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 170
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        // creates score label and sets its attributes
        let scoreLabel = SKLabelNode(fontNamed: "the bold font")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        let defaults = UserDefaults()
        
        // creates a variable that keeps track of all time high score
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        // when high score is beaten, update the high score
        if gameScore > highScoreNumber
        {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        // creates high score label and sets its attributes
        let highScoreLabel = SKLabelNode(fontNamed: "the bold font")
        highScoreLabel.text = "High Score: \(highScoreNumber)"
        highScoreLabel.fontSize = 125
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        self.addChild(highScoreLabel)
        
        // sets all of restart label's attributes
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.3)
        self.addChild(restartLabel)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        // changes game scene when the restart label is touches
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            
            // when the restart label is tapped, change game scenes
            if restartLabel.contains(pointOfTouch)
            {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
        }
    }
}
