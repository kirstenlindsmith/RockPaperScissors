import SpriteKit
import GameplayKit

// global variables that keep track of the game
var winner = "¯|_(ツ)_/¯";
let predatorSpeed:CGFloat = 100
var population: Int = 60
var rockPopulation: Int = population/3
var paperPopulation: Int = population/3
var scissorsPopulation: Int = population/3


class GameScene: SKScene, SKPhysicsContactDelegate {
    // label to track game state
    let winnerLabel = SKLabelNode(fontNamed: "the bold font")
    
    // sound effect
    let explosionSound = SKAction.playSoundFileNamed("explosion.wav", waitForCompletion: false)
    
    // Label that starts game when pressed
    let tapToStartLabel = SKLabelNode(fontNamed: "the bold font")
    
    //instantiate a tree to hold a map of nodes
    let mobTree = GKRTree(maxNumberOfChildren: population)

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

    func distance(from point1: CGPoint, to point2: CGPoint) -> CGFloat {
        return hypot(point1.x - point2.x, point1.y - point2.y)
    }
    
    
    // creating game area
    let gameArea: CGRect
    override init(size: CGSize) {

        let maxAspectRatio: CGFloat = 19.5 / 9.0;
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
        borderBody.restitution = 0.5
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

    func chasePrey(predator: SKNode, prey: SKNode) {
        let yDifference = prey.position.y - predator.position.y
        let xDifference = prey.position.x - predator.position.x
        let angleBetween = atan2(yDifference, xDifference)
        //rotate towards the prey
        // if (predator.zRotation != angleBetween) {
        //     let rotate = SKAction.rotate(byAngle: angleBetween, duration: 1)
        //     predator.run(rotate)
        //     print("predator.zRotation:", predator.zRotation, "\n", "angleBetween:", angleBetween,"\n", "----", "\n", "\n")
        // }
        //move towards the prey
        let xVelocity = cos(angleBetween) * predatorSpeed
        let yVelocity = sin(angleBetween) * predatorSpeed
        let velocity = CGVector(dx: CGFloat(xVelocity), dy: CGFloat(yVelocity))
        predator.physicsBody?.velocity = velocity
        predator.physicsBody!.applyImpulse(velocity)
        predator.physicsBody!.applyForce(velocity)

        // print(predator.physicsBody?.categoryBitMask, " is chasing ", prey.physicsBody?.categoryBitMask, " at a velocity of ", predator.physicsBody?.velocity, "\n", "----", "\n", "\n")
    }

    func fleePredator(predator: SKNode, prey: SKNode) {
        let yDifference = prey.position.y - predator.position.y
        let xDifference = prey.position.x - predator.position.x
        let angleBetween = atan2(yDifference, xDifference)

        let xVelocity = cos(angleBetween) * predatorSpeed
        let yVelocity = sin(angleBetween) * predatorSpeed
        let velocity = CGVector(dx: CGFloat(-xVelocity), dy: CGFloat(-yVelocity))
        predator.physicsBody?.velocity = velocity
        predator.physicsBody!.applyImpulse(velocity)
        predator.physicsBody!.applyForce(velocity)
        print(predator.physicsBody?.categoryBitMask, " is fleeing ", prey.physicsBody?.categoryBitMask, " at a velocity of ", predator.physicsBody?.velocity, "\n", "----", "\n", "\n")
    }

    func cyclePredators() {
            //pull the mobs within the game area
            let mobsInGameArea = self.mobTree.elements(
                inBoundingRectMin: vector2(Float(self.gameArea.minX), Float(self.gameArea.minY)),
                rectMax: vector2(Float(self.gameArea.maxX), Float(self.gameArea.maxY))
            )
            let activeMobs: [SKNode] = mobsInGameArea.map { $0 as? SKNode }.compactMap({ $0 })
        //enumerate scene's child nodes
        enumerateChildNodes(withName: "*") { (mob, stop) in
            guard let mobType = mob.physicsBody?.categoryBitMask else {
                return
            }
            let mobX = Float(mob.frame.maxX) - Float(mob.frame.minX)
            let mobY = Float(mob.frame.maxY) - Float(mob.frame.minY)
            let mobPosition: CGPoint = CGPoint(x: CGFloat(mobX), y: CGFloat(mobY))
            
            let mobsSortedByDistance = activeMobs.sorted{ [unowned self] activeMob1, activeMob2 in 
                let activeMob1X = Float(activeMob1.frame.maxX) - Float(activeMob1.frame.minX)
                let activeMob1Y = Float(activeMob1.frame.maxY) - Float(activeMob1.frame.minY)
                let activeMob2X = Float(activeMob2.frame.maxX) - Float(activeMob2.frame.minX)
                let activeMob2Y = Float(activeMob2.frame.maxY) - Float(activeMob2.frame.minY)
                let activeMob1Position: CGPoint = CGPoint(x: CGFloat(activeMob1X), y: CGFloat(activeMob1Y))
                let activeMob2Position: CGPoint = CGPoint(x: CGFloat(activeMob2X), y: CGFloat(activeMob2Y))
                
                let delta1 = self.distance(from: mobPosition, to: activeMob1Position)
                let delta2 = self.distance(from: mobPosition, to: activeMob2Position)
                return delta1 < delta2
            }

            var nearestNeighbor: SKNode = SKSpriteNode()
            var neighborType: UInt32 = mobType
            for neighbor in mobsSortedByDistance {
                guard let validBitMask = neighbor.physicsBody?.categoryBitMask else { continue }
                if (validBitMask != mobType) {
                    nearestNeighbor = neighbor
                    neighborType = validBitMask
                    break
                }
            }
            
            // set up conditions under which mob would chase prey
            let firstKillCondition = mobType == BodyType.Rock && neighborType == BodyType.Scissors
            let secondKillCondition = mobType == BodyType.Paper && neighborType == BodyType.Rock
            let thirdKillCondition = mobType == BodyType.Scissors && neighborType == BodyType.Paper

            //set up conditions under which mob would flee predator
            let firstFleeCondition = mobType == BodyType.Rock && neighborType == BodyType.Paper
            let secondFleeCondition = mobType == BodyType.Paper && neighborType == BodyType.Scissors
            let thirdFleeCondition = mobType == BodyType.Scissors && neighborType == BodyType.Rock

            if firstKillCondition || secondKillCondition || thirdKillCondition {
                self.chasePrey(predator: mob, prey: nearestNeighbor)
            }
            else if firstFleeCondition || secondFleeCondition || thirdFleeCondition {
                self.fleePredator(predator: nearestNeighbor, prey: mob)
            } 
        }
    }
    
  
    // runs once per game frame
    override func update(_ currentTime: TimeInterval) {
           cyclePredators()
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
        winnerLabel.text = "In the lead: \(nowInTheLead)"

        // make lable grow and shrink when something dies
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        winnerLabel.run(scaleSequence)

        let rockWins = (rockPopulation == population)
        let paperWins = (paperPopulation == population)
        let scissorsWin = (scissorsPopulation == population)

        if (rockWins) { winner = "rock" }
        if (paperWins) { winner = "paper" }
        if (scissorsWin) { winner = "scissors" }

       if (rockWins || paperWins || scissorsWin) {
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
        // create 2 physics bodies
        let mob1 = contact.bodyA
        let mob2 = contact.bodyB
        // capture their nodes
        let mob1Node = mob1.node as? SKSpriteNode
        let mob2Node = mob2.node as? SKSpriteNode

        switch (mob1.categoryBitMask, mob2.categoryBitMask) {
            case (BodyType.Rock, BodyType.Rock):
                break;
            case (BodyType.Rock, BodyType.Paper):
                mob1Node?.texture = SKTexture(imageNamed: "paper");
                mob1.categoryBitMask = BodyType.Paper;
                mob1Node?.name = "paper";
                rockPopulation -= 1;
                paperPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Rock, BodyType.Scissors):
                mob2Node?.texture = SKTexture(imageNamed: "rock");
                mob2.categoryBitMask = BodyType.Rock;
                mob2Node?.name = "rock";
                scissorsPopulation -= 1;
                rockPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Paper, BodyType.Rock):
                mob2Node?.texture = SKTexture(imageNamed: "paper");
                mob2.categoryBitMask = BodyType.Paper;
                mob2Node?.name = "paper";
                rockPopulation -= 1;
                paperPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Paper, BodyType.Paper):
                break;
            case (BodyType.Paper, BodyType.Scissors):
                mob1Node?.texture = SKTexture(imageNamed: "scissors");
                mob1.categoryBitMask = BodyType.Scissors;
                paperPopulation -= 1;
                scissorsPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Scissors, BodyType.Rock):
                mob1Node?.texture = SKTexture(imageNamed: "rock");
                mob1.categoryBitMask = BodyType.Rock;
                mob1Node?.name = "rock";
                scissorsPopulation -= 1;
                rockPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Scissors, BodyType.Paper):
                mob2Node?.texture = SKTexture(imageNamed: "scissors");
                mob2.categoryBitMask = BodyType.Scissors;
                mob2Node?.name = "scissors";
                paperPopulation -= 1;
                scissorsPopulation += 1;
                checkWinner(); 
                break;
            case (BodyType.Scissors, BodyType.Scissors):
                break;
        case (_, _):
            break;
        }
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
            let randomXstart = random(min: self.gameArea.minX, max: self.gameArea.maxX)
            let randomYstart = random(min: self.gameArea.minY, max: self.gameArea.maxY)
            
            // start and end points of the spawn
            let startPoint = CGPoint(x: randomXstart , y: randomYstart)

            //create bounds around the screen the life can't leave
            let xRange = SKRange(lowerLimit: self.gameArea.minX, upperLimit: self.gameArea.maxX)
            let yRange = SKRange(lowerLimit: self.gameArea.minY, upperLimit: self.gameArea.maxY)
            
            //create player object and all its attributes
            let newLife = SKSpriteNode(imageNamed: name)
            newLife.name = name
            newLife.setScale(0.8)
            newLife.position = startPoint
            newLife.zPosition = 2
            newLife.constraints = [SKConstraint.positionX(xRange, y:yRange)]
            newLife.physicsBody = SKPhysicsBody(rectangleOf: newLife.size)
            newLife.physicsBody!.affectedByGravity = false
            newLife.physicsBody!.friction = 0
            newLife.physicsBody!.restitution = 0
            newLife.physicsBody!.linearDamping = 0
            newLife.physicsBody!.angularDamping = 0
            newLife.physicsBody!.categoryBitMask = physicsBody
            newLife.physicsBody!.collisionBitMask = physicsBody
            newLife.physicsBody!.contactTestBitMask = EnemyType1 | EnemyType2
            self.addChild(newLife)
            //capture the new location in the tree
            self.mobTree.addElement(
                newLife,
                boundingRectMin: vector2(Float(newLife.frame.minX), Float(newLife.frame.minY)),
                boundingRectMax: vector2(Float(newLife.frame.maxX), Float(newLife.frame.maxY)),
                splitStrategy: GKRTreeSplitStrategy.linear
            )
            
            //get the player moving
            // newLife.physicsBody!.applyImpulse(CGVector(dx: 5.0, dy: -5.0)) //NOTE: they just float aimlessly lol
            // newLife.physicsBody!.applyForce(CGVector(dx: 5.0, dy: -5.0))
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
