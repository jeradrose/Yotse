//
// Created by Jerad Rose on 4/3/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit

class Die : SKSpriteNode {
    let restitution: CGFloat = 0.4
    let friction: CGFloat = 0.15
    let linearDamping: CGFloat = 0.0

    let textureAtlas = SKTextureAtlas(named: "Dice")

    let diceValues = [1,2,3,4,5,6]
    let offset: CGFloat = 0.0

    let collisionBitMask: UInt32 = 0

    var dragTrajectory = CGVector(dx: 0.0, dy: 0.0)
    var slot = 0

    override init(texture: SKTexture!, color: SKColor!, size: CGSize) {
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    init(diceValues: [Int], slot: Int, offset: CGFloat) {
        super.init()

        self.diceValues = diceValues
        self.offset = offset

        texture = SKTexture(imageNamed: "Dice_1")
        size = texture!.size()

        physicsBody = SKPhysicsBody(texture: texture, size: size)
        collisionBitMask = physicsBody!.collisionBitMask

        println("collisionBitMask: \(collisionBitMask)")

        physicsBody!.restitution = restitution
        physicsBody!.friction = friction
        physicsBody!.linearDamping = linearDamping

        moveToSlot(slot)
    }

    func moveToSlot(slot: Int) {
        self.slot = slot

        println("slot: \(slot)")
        let center = size.width / 2
        let start = offset + size.width
        let y = center + offset
        let x = (start * CGFloat(slot)) - center

        physicsBody!.dynamic = false
        physicsBody!.collisionBitMask = 0
        runAction(SKAction.moveTo(CGPoint(x: x, y: y), duration: 0.25))
        zRotation = 0.0
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
        physicsBody!.collisionBitMask = collisionBitMask
        physicsBody!.dynamic = true
        physicsBody!.friction = 0.0
        physicsBody!.restitution = 1.0
        physicsBody!.linearDamping = 0.0
        physicsBody!.applyImpulse(dragTrajectory)
        slot = 0
        runAction(getRollForever(), withKey: "roll")
    }

    func stopRoll() {
        removeActionForKey("roll")
        physicsBody!.friction = friction
        physicsBody!.restitution = restitution
        physicsBody!.linearDamping = linearDamping
        
        println("die.friction: \(physicsBody!.friction), die.restitution: \(physicsBody!.restitution), die.linearDamping = \(physicsBody!.linearDamping)")
    }

    func speed(velocity: CGVector) -> Float
    {
        let dx = Float(velocity.dx);
        let dy = Float(velocity.dy);
        return sqrtf(dx*dx+dy*dy)
    }

    func angularSpeed(velocity: CGFloat) -> Float
    {
        return abs(Float(velocity))
    }

    // This is a more reliable test for a physicsBody at "rest"
    func resting() -> Bool
    {
        return (speed(physicsBody!.velocity) < 0.0001
                && angularSpeed(physicsBody!.angularVelocity) < 0.0001)
    }

    func rollDie() -> String {
        let i = diceValues[Int(arc4random_uniform(UInt32(diceValues.count)))]

        switch i {
            case 7:  return "Y"
            case 8:  return "O"
            case 9:  return "T"
            case 10: return "S"
            case 11: return "E"
            default: return String(i)
        }
    }
}
