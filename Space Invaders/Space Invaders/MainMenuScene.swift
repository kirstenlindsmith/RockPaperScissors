import Foundation
import SpriteKit

class MainMenuScene: SKScene
{
     let startGame = SKLabelNode(fontNamed: "the bold font")
    
    override func didMove(to view: SKView)
    {
        // let background = SKSpriteNode(imageNamed: "background")
        // background.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        // background.zPosition = 0;
        // self.addChild(background); //TODO: background image for start screen
        self.backgroundColor = SKColor.white;
        
        let gameName1 = SKLabelNode(fontNamed: "the bold font")
        gameName1.text = "Rock"
        gameName1.fontSize = 160
        gameName1.fontColor = SKColor.black
        gameName1.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.78)
        gameName1.zPosition = 1
        self.addChild(gameName1)
        
        let gameName2 = SKLabelNode(fontNamed: "the bold font")
        gameName2.text = "Paper"
        gameName2.fontSize = 180
        gameName2.fontColor = SKColor.black
        gameName2.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.7)
        gameName2.zPosition = 1
        self.addChild(gameName2)
        
        let gameName3 = SKLabelNode(fontNamed: "the bold font")
        gameName3.text = "Scissors"
        gameName3.fontSize = 200
        gameName3.fontColor = SKColor.black
        gameName3.position = CGPoint(x: self.size.width * 0.5, y: self.size.height * 0.620)
        gameName3.zPosition = 1
        self.addChild(gameName3)
        
        startGame.text = "START GAME"
        startGame.fontSize = 150
        startGame.fontColor = SKColor.black
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
