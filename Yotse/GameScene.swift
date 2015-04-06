//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let gravity = CGFloat(-50.0)
    let diceWidth = Double(0)

    var dice = [Die]()
    var gameMode = GameMode.Classic
    var isRolling = false

    required init?(coder aDecoder: NSCoder) {
        diceWidth = Double(SKSpriteNode(imageNamed:"Dice_1").size.width)

        super.init(coder: aDecoder)
    }

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.whiteColor()
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)

        println("gravity: \(self.physicsWorld.gravity.dx), \(self.physicsWorld.gravity.dy)")
        self.physicsWorld.gravity = CGVectorMake(0.0, gravity)

        let spacing = Double(self.size.width / 5)
        let offset = (spacing / 2)

        println("offset: \(offset), diceWidth: \(diceWidth), spacing: \(spacing)")

        for i in 0..<5 {
            let die = Die(position: CGPoint(x: (spacing * Double(i)) + offset, y: offset), diceValues: [1,2,3,4,5,6])

            println("position = \(die.position)")
            println("\(die.texture)")

            dice.append(die)
            self.addChild(die)
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if isRolling {
            for i in 0..<5 {
                dice[i].stopRoll()
            }
        } else {
            for i in 0..<5 {
                dice[i].startRoll()
            }
        }
        isRolling = !isRolling
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
