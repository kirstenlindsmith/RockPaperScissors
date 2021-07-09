//
//  Helpers.swift
//  RockPaperScissors
//
//  Created by Kirsten Lindsmith on 7/2/21.
//  Copyright © 2021 Kirsten Lindsmith. All rights reserved.
//

import Foundation
import SpriteKit

func drawCircle(on: GameScene, at: CGPoint, color: SKColor, size: CGFloat) {
    let Circle = SKShapeNode(circleOfRadius: size) //size
    Circle.position = at //midpoint
    Circle.zPosition = CGFloat(101)
    Circle.name = "highlightCircle"
    Circle.strokeColor = color
    Circle.fillColor = color
    Circle.blendMode = SKBlendMode.multiply
    on.addChild(Circle)
}

func removeCircle(target: SKShapeNode) {
    target.removeFromParent()
}
