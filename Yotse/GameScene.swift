//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Jerad Rose. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let textureAtlas = SKTextureAtlas(named: "Dice")

    override func didMoveToView(view: SKView) {
        self.backgroundColor = UIColor.whiteColor()
        self.physicsBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
        self.physicsWorld.gravity = CGVectorMake(0.0, -1)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

            let sprite = SKSpriteNode(imageNamed:"Dice_1")

            sprite.position = location

            sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
            sprite.physicsBody!.dynamic = true

            let rollAction = SKAction.runBlock({
                sprite.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDice())")))
            })

            let roll = SKAction.group([rollAction])
            let wait = SKAction.waitForDuration(0.1)

            let sequence = SKAction.sequence([roll, wait])
            let repeat = SKAction.repeatActionForever(sequence)
            sprite.runAction(repeat)

            self.addChild(sprite)
        }
    }

    func rollDice() -> String {
        let i = Int(arc4random_uniform(11)+1)

        var dice = ""

        switch i {
            case 7:  dice = "Y"
            case 8:  dice = "O"
            case 9:  dice = "T"
            case 10: dice = "S"
            case 11: dice = "E"
            default: dice = String(i)
        }

        return dice
    }

    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
