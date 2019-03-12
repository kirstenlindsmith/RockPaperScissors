//
//  MainMenuScene.swift
//  Space Invaders
//
//  Created by Francisco Franco on 3/11/19.
//  Copyright © 2019 Francisco Franco. All rights reserved.
//

import Foundation
import SpriteKit

class MainMenuScene: SKScene
{
     let startGame = SKLabelNode(fontNamed: "the bold font")
    
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background")
//        background.size = self.size
        background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        background.zPosition = 0;
        self.addChild(background);
        
        let creator = SKLabelNode(fontNamed: "the bold font")
        creator.text = "Francisco's"
        creator.fontSize = 50
        creator.fontColor = SKColor.white
        creator.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
        creator.zPosition = 1
        self.addChild(creator)
        
        let gameName1 = SKLabelNode(fontNamed: "the bold font")
        gameName1.text = "Solo"
        gameName1.fontSize = 200
        gameName1.fontColor = SKColor.white
        gameName1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "the bold font")
        gameName2.text = "Mission"
        gameName2.fontSize = 200
        gameName2.fontColor = SKColor.white
        gameName2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.620)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        startGame.text = "Start Game"
        startGame.fontSize = 150
        startGame.fontColor = SKColor.white
        startGame.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.4)
        startGame.zPosition = 1
        startGame.name = "startButton"
        self.addChild(startGame)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?)
    {
        
        for touch: AnyObject in touches
        {
            let pointOfTouch = touch.location(in: self)
            
            if startGame.contains(pointOfTouch)
            {
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                
                let myTransition = SKTransition.fade(withDuration: 0.5)
                self.view!.presentScene(sceneToMoveTo, transition: myTransition)
            }
            
        }
    }
}


// finish part 6 video
