import Foundation
import SpriteKit

class GameOverScene: SKScene {
    // creates label to restart game
    let restartLabel = SKLabelNode(fontNamed: "the bold font")
    
    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white;
        
        // creates GAMEOVER label and sets its attributes
        let gameOverLabel = SKLabelNode(fontNamed: "the bold font")
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 170
        gameOverLabel.fontColor = SKColor.black
        gameOverLabel.position = CGPoint(x: self.size.width*0.5, y: self.size.height*0.7)
        gameOverLabel.zPosition = 1
        self.addChild(gameOverLabel)
        
        // creates score label and sets its attributes
        let scoreLabel = SKLabelNode(fontNamed: "the bold font")
        scoreLabel.text = "Winner: \(winner)"
        scoreLabel.fontSize = 125
        scoreLabel.fontColor = SKColor.black
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.55)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
//        let defaults = UserDefaults()
        
        // creates a variable that keeps track of all time high score
        // var rockWinCount = defaults.integer(forKey: "rockWinCount")
        // var paperWinCount = defaults.integer(forKey: "paperWinCount")
        // var scissorsWinCount = defaults.integer(forKey: "scissorsWinCount")
        // var allTimeHighScore = defaults.integer(forKey: "allTimeHighScore")
        // var allTimeWinner = defaults.string(forKey: "allTimeWinner")

        // if (winner == "rock") {
        //     rockWinCount += 1
        //     if rockWinCount >= allTimeHighScore {
        //         allTimeHighScore = rockWinCount
        //         allTimeWinner = "rock"
        //     }
        // } else if (winner == "paper") {
        //     paperWinCount += 1
        //     if paperWinCount >= allTimeHighScore {
        //         allTimeHighScore = paperWinCount
        //         allTimeWinner = "paper"
        //     }
        // } else if (winner == "paper") {
        //     scissorsWinCount += 1
        //     if scissorsWinCount >= allTimeHighScore {
        //         allTimeHighScore = scissorsWinCount
        //         allTimeWinner = "paper"
        //     }
        // }
        
        // creates high score label and sets its attributes
        // let highScoreLabel = SKLabelNode(fontNamed: "the bold font")
        // highScoreLabel.text = "High Score: \(allTimeWinner!) with \((allTimeHighScore)) Wins"
        // highScoreLabel.fontSize = 125
        // highScoreLabel.fontColor = SKColor.black
        // highScoreLabel.zPosition = 1
        // highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height*0.45)
        // self.addChild(highScoreLabel)
        
        // sets all of restart label's attributes
        restartLabel.text = "Restart"
        restartLabel.fontSize = 90
        restartLabel.fontColor = SKColor.black
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
