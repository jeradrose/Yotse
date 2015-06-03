//
// Created by Jerad Rose on 4/3/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit
import UIKit

class Die : SKSpriteNode {
    let restitution: CGFloat = 0.4
    let friction: CGFloat = 0.15
    let linearDamping: CGFloat = 0.0
    let minimumMagnitude: CGFloat = 500.0
    let maximumMagnitude: CGFloat = 1500.0
    let textureAtlas: SKTextureAtlas = SKTextureAtlas(named: "Dice")

    let diceValues: [Int]
    let offset: CGFloat

    var dragTrajectory: CGVector = CGVector(dx: 0.0, dy: 0.0)
    var slot: Int = 0
    var homePosition: CGPoint = CGPoint(x: 0, y: 0)

    var actions: DieActions?

    override init(texture: SKTexture!, color: SKColor!, size: CGSize) {
        diceValues = []
        offset = 0
        super.init(texture: texture, color: color, size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        diceValues = []
        offset = 0
        super.init(coder: aDecoder)
    }

    init(diceValues: [Int], slot: Int, offset: CGFloat) {
        self.diceValues = diceValues
        self.offset = offset

        let texture = SKTexture(imageNamed: "Dice_1")

        super.init(texture: texture, color: UIColor.whiteColor(), size: texture!.size())

        physicsBody = SKPhysicsBody(texture: texture, size: size)

        physicsBody!.restitution = restitution
        physicsBody!.friction = friction
        physicsBody!.linearDamping = linearDamping

        let center = size.width / 2
        let start = offset + size.width
        let y = center + offset
        let x = (start * CGFloat(slot + 1)) - center

        self.slot = slot
        self.homePosition = CGPoint(x: x, y: y)

        self.setDynamic(false)

        self.position = homePosition
    }

    var state: DieState = DieState.Locked {
        willSet {
            switch newValue {
                case DieState.Dragging:
                    if state == DieState.Locked {
                        return
                    }
                case DieState.Rolling:
                    if state == DieState.Dragging {
                        return
                    }
                case DieState.Dropping:
                    if state == DieState.Rolling {
                        return
                    }
                case DieState.Resting:
                    if state == DieState.Dropping {
                        return
                    }
                case DieState.Locking:
                    if state == DieState.Resting || state == DieState.Dragging {
                        return
                    }
                case DieState.Locked:
                    if state == DieState.Locking {
                        return
                    }
            }
            fatalError("DieState for slot \(slot) cannot be set from \(state.description) to \(newValue.description).")
        }
        didSet {
            println("Changing Die[\(slot)].state from \(oldValue.description) to \(state.description)")
            switch state {
                case DieState.Dragging:
                    actions?.DragOtherDice(slot)
                    return
                case DieState.Rolling:
                    actions?.Roll(slot)
                case DieState.Dropping:
                    actions?.Drop(slot)
                case DieState.Resting:
                    actions?.Rest(slot)
                case DieState.Locking:
                    actions?.Lock(slot)
                case DieState.Locked:
                    return
            }
        }
    }

    func moveToHome() {
        self.setDynamic(false)
        runAction(SKAction.moveTo(CGPoint(x: homePosition.x, y: homePosition.y), duration: 0.25))
        runAction(SKAction.rotateToAngle(0, duration: 0.25))
    }

    func rollOnce() {
        self.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDie())")))
    }

    func getRollForever() -> SKAction {
        let rollAction = SKAction.runBlock({
            self.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDie())")))
        })

        let waitAction = SKAction.waitForDuration(0.1)

        let sequenceAction = SKAction.sequence([rollAction, waitAction])

        return SKAction.repeatActionForever(sequenceAction)
    }

    func setDynamic(dynamic: Bool) {
        if dynamic {
            physicsBody!.dynamic = true
            physicsBody!.friction = 0.0
            physicsBody!.restitution = 1.0
            physicsBody!.linearDamping = 0.0
        } else {
            physicsBody!.dynamic = false
        }
    }

    func startRoll() {
        println("startRoll()")
        physicsBody!.applyImpulse(enforceSpeed(dragTrajectory))
        physicsBody!.applyTorque(10)
//        runAction(getRollForever(), withKey: "roll")
    }

    func enforceSpeed(currentVelocity: CGVector) -> CGVector {
        if currentVelocity.magnitude < minimumMagnitude {
//            println("speeding up to minimum")
            return currentVelocity.scaled(minimumMagnitude)
        }

        if currentVelocity.magnitude > maximumMagnitude {
//            println("slowing down to maximum")
            return currentVelocity.scaled(maximumMagnitude)
        }

        return currentVelocity
    }

    func stopRoll() {
//        removeActionForKey("roll")

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
