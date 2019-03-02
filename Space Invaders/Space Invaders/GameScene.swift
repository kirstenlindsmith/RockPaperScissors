//
//  GameScene.swift
//  Space Invaders
//
//  Created by Francisco Franco on 3/2/19.
//  Copyright © 2019 Francisco Franco. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene
{
    let player = SKSpriteNode(imageNamed: "ship")
    
    let bulletSound = SKAction.playSoundFileNamed("laser.wav", waitForCompletion: false)
    
    
//    let gameArea: CGRect
//    override init(size: CGSize)
//    {
//
//        let maxAspectRatio: CGFloat = 16.0 / 9.0;
//        let playableWidth = size.height / maxAspectRatio
//        let margin = (size.width - playableWidth) / 2
//
//        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
//
//        super.init(size: size)
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
    
    
    override func didMove(to view: SKView)
    {
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.zPosition = 0;
        self.addChild(background);
        
        player.setScale(0.5); //size of ship
        player.position = CGPoint(x: 0 , y: -500)
        player.zPosition = 2
        self.addChild(player)
    }
    
    func fireBullet()
    {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height , duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        
        //left off at
        
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
            
//            //when player moves to far to right, bump back into game area
//            if player.position.x > gameArea.maxX
//            {
//                player.position.x = gameArea.maxX
//            }
//
//            //when player moves to far to left, bump back into game area
//            if player.position.x < gameArea.minX
//            {
//                player.position.x = gameArea.minX
//            }
            
        }
        
        
    }

    
}
