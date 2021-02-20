import SpriteKit
import GameplayKit

// global variables that keep track of the game
var winner = "¯|_(ツ)_/¯";
let predatorSpeed:CGFloat = 3.0
var population: Int = 60
var rockPopulation: Int = population/3
var paperPopulation: Int = population/3
var scissorsPopulation: Int = population/3


class GameScene: SKScene, SKPhysicsContactDelegate {
    // label to track game state
    let winnerLabel = SKLabelNode(fontNamed: "the bold font")
    
    // creating nodes that represents the rock, paper, and scissors
    // let rock = SKSpriteNode(imageNamed: "rock")
    // let paper = SKSpriteNode(imageNamed: "paper")
    // let scissors = SKSpriteNode(imageNamed: "scissors")
    
    // sound effect
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // Label that starts game when pressed
    let tapToStartLabel = SKLabelNode(fontNamed: "the bold font")
    
    
    enum gameState {
        case preGame // prior to game start
        case inGame // when game state is during the game
        case afterGame // when game finishes
    }
    
    var currentGameState = gameState.preGame
    
    // setting physics of objects for later use
    struct BodyType {
        static let Rock : UInt32 = 0b1 // 1
        static let Paper : UInt32 = 0b10 // 2
        static let Scissors : UInt32 = 0b100 // 4
    }
    
    // random utility functions that produce random locations
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random (min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    // creating game area
    let gameArea: CGRect
    override init(size: CGSize) {

        let maxAspectRatio: CGFloat = 16.0 / 9.0;
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2

        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)

        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        // set initial game state
        winner = "¯|_(ツ)_/¯"
        
        self.physicsWorld.contactDelegate = self;
        // prevent anything from leaving the pen
        let borderBody = SKPhysicsBody(edgeLoopFrom: self.frame)
        borderBody.friction = 0
        self.physicsBody = borderBody
        physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0);

        self.backgroundColor = SKColor.white;
        
        // setting all of winnerLabel"s attributes and physics
        winnerLabel.text = "In the lead: "
        winnerLabel.fontSize = 70
        winnerLabel.fontColor = SKColor.black
        winnerLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        winnerLabel.position = CGPoint(x: self.size.width * 0.23, y: self.size.height * 0.9)
        winnerLabel.zPosition = 100
        self.addChild(winnerLabel)
        
        // setting all of tapToStartLabel"s attributes and physics
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.black
        tapToStartLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        tapToStartLabel.position = CGPoint(x: self.size.width/1.45, y: self.size.height/2)
        tapToStartLabel.zPosition = 1
        tapToStartLabel.alpha = 0
        self.addChild(tapToStartLabel)
        
        // makes everything fade onto the scene
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
    }

    func cyclePredators() {
        enumerateChildNodes(withName: "*//*") { (predator, stop) in
            // rotate and move to new location
            let randomNewX = Int(predator.position.x) + Int.random(in: 0...30)
            let randomNewY = Int(predator.position.y) + Int.random(in: 0...30)
            let yDifference = randomNewY - Int(predator.position.y)
            let xDifference = randomNewX - Int(predator.position.x)
            let angleBetween = atan2(yDifference, xDifference)
            let xVelocity = cos(angleBetween) * predatorSpeed
            let yVelocity = sin(angleBetween) * predatorSpeed
            predator.zRotation = angleBetween
            predator.position.x = CGFloat(randomNewX)
            predator.position.y = CGFloat(randomNewY)
            predator.xVelocity = xVelocity
            predator.yVelocity = yVelocity
            
            // let minX = Float(predator.frame.minX)
            // let minY = Float(predator.frame.minY)
            // let maxX = Float(predator.frame.maxX)
            // let maxY = Float(predator.frame.maxY)

            // let neighborsTree = GKRTree(maxNumberOfChildren: 3)
            // neighborsTree.addElement(
            //     predator,
            //     boundingRectMin: vector2(minX, minY),
            //     boundingRectMax: vector2(maxX, maxY),
            //     splitStrategy: GKRTreeSplitStrategy.linear
            // )
            // let neighborsInProximity = neighborsTree.elements(
            //      inBoundingRectMin: vector2(minX, minY),
            //     rectMax: vector2(maxX, maxY)
            //     // inBoundingRectMin: vector2(Float(predator.position.x - 100), Float(predator.position.y - 50)),
            //     // rectMax: vector2(Float(predator.position.x + 50), Float(predator.position.y + 50))
            // )

            // for neighbor in neighborsInProximity {
            //     if (
            //         predator.name == "rock" && (neighbor as! SKNode).name == "scissors" ||
            //         predator.name == "paper" && (neighbor as! SKNode).name == "rock" ||
            //         predator.name == "scissors" && (neighbor as! SKNode).name == "paper"
            //     ) {
            //         //rotate towards the prey
                    // let yDifference = (neighbor as! SKNode).position.y - predator.position.y
                    // let xDifference = (neighbor as! SKNode).position.x - predator.position.x
                    // let angleBetween = atan2(yDifference, xDifference)
                    // predator.zRotation = angleBetween
            //         //move towards the prey
                    // let xVelocity = cos(angleBetween) * predatorSpeed
                    // let yVelocity = sin(angleBetween) * predatorSpeed
            //         predator.position.x += xVelocity
            //         predator.position.y += yVelocity
            //     }
            // }
        }
    }
    
  
    //  runs once per game frame
    override func update(_ currentTime: TimeInterval) {
        cyclePredators()
        // creating a small chance of moving all bodies per frame
//        let num = Int.random(in: 1 ... 10)
//
//        if num == 1 {
//            cyclePredators()
//        }
    }
    
    // runs when the game starts
    func startGame() {
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeIn(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)

        spawnNewLife(name: "rock", physicsBody: BodyType.Rock)
        spawnNewLife(name: "paper", physicsBody: BodyType.Paper)
        spawnNewLife(name: "scissors", physicsBody: BodyType.Scissors)
    }
    
    // runs when a predator comes into contact with its potential prey, or its demise
    func checkWinner() {
        var nowInTheLead: String = "¯|_(ツ)_/¯"
        if (scissorsPopulation > paperPopulation) {
            if (scissorsPopulation as Int > rockPopulation as Int) {
                nowInTheLead = "scissors"
            } else {
                nowInTheLead = "rock"
            }
        } else if (paperPopulation > rockPopulation) {
            nowInTheLead = "paper"
        } else {
            nowInTheLead = "rock"
            
        }
        // update labels to reflect death
        winner = nowInTheLead
        winnerLabel.text = "In the lead: \(nowInTheLead)"

        // make lable grow and shrink when something dies
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        winnerLabel.run(scaleSequence)

        if 
        (rockPopulation < 1 && paperPopulation < 1) ||
        (rockPopulation < 1 && scissorsPopulation < 1) ||
        (scissorsPopulation < 1 && paperPopulation < 1 ) {
            runEndGame()
        }
    }
    
    // function that handles what happens when one predator reigns supreme
    func runEndGame() {
        // set game state to after game
        currentGameState = gameState.afterGame
        
        // removes everything from screen
        self.removeAllActions()
        
        // stops scissors from spawning
        self.enumerateChildNodes(withName: "scissors"){
            scissors, stop in
            scissors.removeAllActions()
        }
        
        // stops rocks from spawning
        self.enumerateChildNodes(withName: "rock"){
            rock, stop in
            rock.removeAllActions()
        }
        
        // stops paper from spawning
        self.enumerateChildNodes(withName: "paper"){
            paper, stop in
            paper.removeAllActions()
        }
        
        // changes scenes
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScence = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScence, changeSceneAction])
        self.run(changeSceneSequence)
    }
    
    // funtion that changes game scenes
    func changeScene(){
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
    }
    
    // function that runs when objects collide with one another
    func didBegin(_ contact: SKPhysicsContact) {
        // create 2 physcis bodies
        var player1 = SKPhysicsBody()
        var player2 = SKPhysicsBody()
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            player1 = contact.bodyA
            player2 = contact.bodyB
        } else {
            player1 = contact.bodyB
            player2 = contact.bodyA
        }

        let player1Node = player1.node as? SKSpriteNode
        let player2Node = player2.node as? SKSpriteNode
        
        switch (player1.categoryBitMask, player2.categoryBitMask) {
            case (BodyType.Rock, BodyType.Rock):
                break;
            case (BodyType.Rock, BodyType.Paper):
                player1Node?.texture = SKTexture(imageNamed: "paper");
                player1.categoryBitMask = BodyType.Paper;
                rockPopulation -= 1;
                paperPopulation += 1;
                break;
            case (BodyType.Rock, BodyType.Scissors):
                player2Node?.texture = SKTexture(imageNamed: "rock");
                player2.categoryBitMask = BodyType.Rock;
                scissorsPopulation -= 1;
                rockPopulation += 1;
                break;
            case (BodyType.Paper, BodyType.Rock):
                player2Node?.texture = SKTexture(imageNamed: "paper");
                player2.categoryBitMask = BodyType.Paper;
                rockPopulation -= 1;
                paperPopulation += 1;
                break;
            case (BodyType.Paper, BodyType.Paper):
                break;
            case (BodyType.Paper, BodyType.Scissors):
                player1Node?.texture = SKTexture(imageNamed: "scissors");
                player1.categoryBitMask = BodyType.Scissors;
                paperPopulation -= 1;
                scissorsPopulation += 1;
                break;
            case (BodyType.Scissors, BodyType.Rock):
                player1Node?.texture = SKTexture(imageNamed: "rock");
                player1.categoryBitMask = BodyType.Rock;
                scissorsPopulation -= 1;
                rockPopulation += 1;
                break;
            case (BodyType.Scissors, BodyType.Paper):
                player2Node?.texture = SKTexture(imageNamed: "scissors");
                player2.categoryBitMask = BodyType.Scissors;
                paperPopulation -= 1;
                scissorsPopulation += 1;
                break;
            case (BodyType.Scissors, BodyType.Scissors):
                break;
        case (_, _):
            break;
        }
        // checkWinner(); 
    }
    
    // function that spawns a new generation
    func spawnNewLife(name: String, physicsBody: UInt32) {
        let populationField: Array<Float> = Array(repeating: 0, count: population/3);
        var EnemyType1: UInt32;
        var EnemyType2: UInt32;

        switch(physicsBody) {
            case BodyType.Rock:
                EnemyType1 = BodyType.Paper;
                EnemyType2 = BodyType.Scissors;
                break;
            case BodyType.Paper:
                EnemyType1 = BodyType.Rock;
                EnemyType2 = BodyType.Scissors;
                break;
            case BodyType.Scissors:
                EnemyType1 = BodyType.Rock;
                EnemyType2 = BodyType.Paper;
                break;
            default:
                EnemyType1 = BodyType.Paper;
                EnemyType2 = BodyType.Scissors;
        }

        for _ in populationField {
            // create a random x and y to spawn the new life at
            let randomXstart = random(min: gameArea.minX, max: gameArea.maxX)
            let randomYstart = random(min: gameArea.minY, max: gameArea.maxY)
//            let randomXend = random(min: gameArea.minX , max: gameArea.maxX)
            
            // start and end points of the spawn
            let startPoint = CGPoint(x: randomXstart , y: randomYstart)
//            let endPoint = CGPoint(x: randomXend,  y: -self.size.height * 0.2)
            
            //create player object and all its attributes
            let newLife = SKSpriteNode(imageNamed: name)
            newLife.name = name
            newLife.setScale(0.8)
            newLife.position = startPoint
            newLife.zPosition = 2
            newLife.physicsBody = SKPhysicsBody(rectangleOf: newLife.size)
            newLife.physicsBody!.affectedByGravity = false
            newLife.physicsBody!.friction = 0
            // newLife.physicsBody!.restitution = 1
            // newLife.physicsBody!.linearDamping = 0
            // newLife.physicsBody!.angularDamping = 0
            newLife.physicsBody!.categoryBitMask = physicsBody
            newLife.physicsBody!.collisionBitMask = physicsBody
            newLife.physicsBody!.contactTestBitMask = EnemyType1 | EnemyType2
            self.addChild(newLife)
            
            //get the player moving
            newLife.physicsBody!.applyImpulse(CGVector(dx: 5.0, dy: -5.0))
            newLife.physicsBody!.applyForce(CGVector(dx: 5.0, dy: -5.0))
        }
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if currentGameState == gameState.preGame {
            startGame()
        } 
    }
    
    // override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    //     // moves the ship left and right by dragging on the screen
    //     for touch: AnyObject in touches
    //     {
    //         let pointOfTouch = touch.location(in: self)
    //         let previousTouch = touch.previousLocation(in: self)
            
    //         let amountDragged = pointOfTouch.x - previousTouch.x
            
    //         if currentGameState == gameState.inGame
    //         {
    //              rock.position.x += amountDragged
    //         }

            
    //         //when rock moves to far to right, bump back into game area
    //         if rock.position.x > gameArea.maxX - rock.size.width/2
    //         {
    //             rock.position.x = gameArea.maxX - rock.size.width/2
    //         }

    //         //when rock moves to far to left, bump back into game area
    //         if rock.position.x < gameArea.minX + rock.size.width/2
    //         {
    //             rock.position.x = gameArea.minX + rock.size.width/2
    //         }
            
    //     }
    
    // }

}
