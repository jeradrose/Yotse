//
// Created by Jerad Rose on 4/3/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit

class Die : SKSpriteNode {
    let restitution = CGFloat(0.7)
    let friction = CGFloat(0.15)
    let linearDamping = CGFloat(0.0)

    let textureAtlas = SKTextureAtlas(named: "Dice")

    let diceValues = [1,2,3,4,5,6]

    override init(texture: SKTexture!, color: SKColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(position: CGPoint, diceValues: [Int]) {
        println("new Die: position: \(position), diceValues: \(diceValues)")
        self.diceValues = diceValues

        super.init()

        self.texture = SKTexture(imageNamed: "Dice_1")
        self.size = self.texture!.size()

        self.position = position

        println("texture: \(self.texture)")
        println("size: \(self.size)")

        self.physicsBody = SKPhysicsBody(texture: self.texture, size: self.size)

        println("physicsBody: \(self.physicsBody)")

        self.physicsBody!.dynamic = false
        self.physicsBody!.restitution = restitution
        self.physicsBody!.friction = friction
        self.physicsBody!.linearDamping = linearDamping
    }

    func getRollForever() -> SKAction {
        let rollAction = SKAction.runBlock({
            self.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDie())")))
        })

        let waitAction = SKAction.waitForDuration(0.1)

        let sequenceAction = SKAction.sequence([rollAction, waitAction])

        return SKAction.repeatActionForever(sequenceAction)
    }

    func startRoll() {
        self.runAction(getRollForever(), withKey: "roll")
    }

    func stopRoll() {
        self.removeActionForKey("roll")
    }

    func rollDie() -> String {
        let i = diceValues[Int(arc4random_uniform(UInt32(diceValues.count)))]

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
}
