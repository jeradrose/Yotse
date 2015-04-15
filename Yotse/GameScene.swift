//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let normalGravity = CGVectorMake(0.0, -10.0)
    let noGravity = CGVectorMake(0.0, 0.0)
    let diceWidth: CGFloat
    let diceHalf: CGFloat

    let offset: CGFloat
    var lockedDice = [Int: Die?]()
    var rollingDice = [Die]()

    var gameMode = GameMode.Classic
    var canRoll = true
    var touchedDie: Die?
    var rollNumber = 1

    let dieCategory: UInt32 = 0x01;
    let wallCategory: UInt32 = 0x02;

    let diceTray: SKSpriteNode

    override init(size: CGSize) {
        println("init(size)")

        diceWidth = SKSpriteNode(imageNamed:"Dice_1").size.width
        diceHalf = diceWidth / 2
        offset = (size.width - (diceWidth * 5)) / 6

        let diceTrayTexture: SKTexture = SKTexture(imageNamed: "DiceTray")
        diceTray = SKSpriteNode(texture: diceTrayTexture, size: CGSize(width: size.width, height: (size.width * diceTrayTexture.size().height) / diceTrayTexture.size().width))

        super.init(size: size)

        for i in 1...5 {
            let die: Die = Die(diceValues: [1,2,3,4,5,6], slot: i, offset: offset)
            die.zPosition = 1
            die.physicsBody!.categoryBitMask = dieCategory
            die.physicsBody!.collisionBitMask = dieCategory | wallCategory
            die.physicsBody!.contactTestBitMask = dieCategory | wallCategory
            lockedDice[i] = die
            addChild(die)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }

    override func didMoveToView(view: SKView) {
        println("didMoveToView")
        backgroundColor = UIColor.whiteColor()

        diceTray.position = CGPoint(x: frame.size.width / 2, y: diceTray.size.height / 2)
        diceTray.zPosition = 0
        addChild(diceTray)

        physicsWorld.contactDelegate = self

        let edgeOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y + diceTray.size.height)
        let edgeSize = CGSize(width: frame.size.width, height: frame.size.height - diceTray.size.height)

        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: edgeOrigin, size: edgeSize))
        physicsBody!.categoryBitMask = wallCategory
        physicsBody!.collisionBitMask = wallCategory | dieCategory

        disableGravity()
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        println("lockedDice.count: \(lockedDice.count)")
        println("rollingDice.count: \(rollingDice.count)")
        touchedDie = nil

        for touch in touches as! Set<UITouch> {
            let location = touch.locationInNode(self)
            println("location: \(location)")
            touchedDie = nodeAtPoint(location) as? Die
            if touchedDie != nil && (touchedDie!.slot == 0 || !canRoll) {
                touchedDie = nil
            }
        }

        println("touchedDie == nil: \(touchedDie == nil)")
        println("canRoll: \(canRoll)")
        if touchedDie != nil && !canRoll {
            disableGravity()
        }

        if touchedDie == nil && canRoll {
            enableGravity()
        }
    }

    override func touchesMoved(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchedDie != nil {
            for touch in touches as! Set<UITouch> {
                var location = touch.locationInNode(self)

                let dx = (location.x - touchedDie!.position.x) * 10.0
                let dy = (location.y - touchedDie!.position.y) * 10.0

                touchedDie!.dragTrajectory = CGVector(dx: dx, dy: dy)

                if location.x < diceHalf {
                    location.x = diceHalf
                }
                if location.x > size.width - diceHalf {
                    location.x = size.width - diceHalf
                }
                if location.y > size.height - diceHalf {
                    location.y = size.height - diceHalf
                }

                touchedDie!.position = location
            }
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchedDie != nil {
            let slot = touchedDie!.slot
//            println("touchedDie!.position: \(touchedDie!.position)")
            if touchedDie!.position.y > self.diceTray.size.height + diceHalf {
//                println("dragTrajectory: \(touchedDie!.dragTrajectory.dx), dy:\(touchedDie!.dragTrajectory.dy)")
                touchedDie!.startRoll()

                lockedDice[slot] = nil
                println("lockedDice[\(touchedDie!.slot)]: \(lockedDice[touchedDie!.slot])")
                rollingDice.append(touchedDie!)

                if rollNumber == 1 {

                }
            } else {
                touchedDie!.moveToSlot(touchedDie!.slot)
            }


            touchedDie = nil
        }
        println("lockedDice.count: \(lockedDice.count)")
        println("rollingDice.count: \(rollingDice.count)")
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == dieCategory {
            let die = contact.bodyA.node as! Die
            if (die.speed(die.physicsBody!.velocity) > 60) {
                die.rollOnce()
            }
            if canRoll {
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
        }
        if contact.bodyB.categoryBitMask == dieCategory {
            let die = contact.bodyB.node as! Die
            if (die.speed(die.physicsBody!.velocity) > 60) {
                die.rollOnce()
            }
            if canRoll {
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
        }
    }

    func disableGravity() {
        println("disableGravity")
        physicsWorld.gravity = noGravity
        physicsBody!.friction = 0.0
    }

    func enableGravity() {
        println("enableGravity")
        canRoll = false
        physicsWorld.gravity = normalGravity
        physicsBody!.friction = 0.15

        for die: Die in rollingDice {
            die.stopRoll()
        }

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkDice"), userInfo: nil, repeats: false)
    }

    func checkDice() {
        var restCount = 0
        for die: Die in rollingDice {
            if die.resting() {
                restCount++
            }
        }

        println("restCount: \(restCount)")

        if restCount == rollingDice.count {
            for die: Die in rollingDice {
                for i in 1 ... 5 {
                    println("lockedDice[\(i)]: \(lockedDice[i])")
                    if lockedDice[i] == nil {
                        lockedDice[i] = die
                        die.moveToSlot(i)
                        break
                    }
                }
            }
            rollingDice.removeAll()
            canRoll = true
            println("diceStopped")
        } else {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkDice"), userInfo: nil, repeats: false)
        }
    }
}
