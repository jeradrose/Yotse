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

    let diceTrayHeight: CGFloat
    let offset: CGFloat
    var dice = [Die]()

    var gameMode = GameMode.Classic
    var canRoll = true
    var touchedDie: Die?

    let dieCategory: UInt32 = 0x01;
    let wallCategory: UInt32 = 0x02;

    override init(size: CGSize) {
        println("init(size)")

        diceWidth = SKSpriteNode(imageNamed:"Dice_1").size.width
        diceHalf = diceWidth / 2
        offset = (size.width - (diceWidth * 5)) / 6
        diceTrayHeight = diceWidth + (offset * 2)

        super.init(size: size)

        for i in 0..<5 {
            let die: Die = Die(diceValues: [1,2,3,4,5,6], slot: i + 1, offset: offset)
            die.zPosition = 1
            die.physicsBody!.categoryBitMask = dieCategory
            die.physicsBody!.collisionBitMask = dieCategory | wallCategory
            die.physicsBody!.contactTestBitMask = dieCategory | wallCategory
            dice.append(die)
            addChild(die)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoder not supported")
    }

    override func didMoveToView(view: SKView) {
        println("didMoveToView")
        backgroundColor = UIColor.whiteColor()

        let diceTray: SKShapeNode = SKShapeNode(rectOfSize: CGSize(width: frame.size.width - offset, height: diceTrayHeight - offset), cornerRadius: 15.0)
        diceTray.position = CGPoint(x: frame.size.width / 2, y: diceTrayHeight / 2)
        diceTray.strokeColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0)
        diceTray.fillColor = UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 0.2)
        diceTray.lineWidth = 3.0
        diceTray.zPosition = 0
        addChild(diceTray)

        physicsWorld.contactDelegate = self

        println("frame: \(frame)")

        let edgeOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y + diceTrayHeight)
        let edgeSize = CGSize(width: frame.size.width, height: frame.size.height - diceTrayHeight)

        println("edgeOrigin: \(edgeOrigin), edgeSize: \(edgeSize)")

        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: edgeOrigin, size: edgeSize))
        physicsBody!.categoryBitMask = wallCategory
        physicsBody!.collisionBitMask = wallCategory | dieCategory

        println("gravity: \(physicsWorld.gravity.dx), \(physicsWorld.gravity.dy)")
        disableGravity()

        println("offset: \(offset), diceWidth: \(diceWidth)")
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchedDie = nil

        for touch in touches as! Set<UITouch> {
            let location = touch.locationInNode(self)
            println("location: \(location)")
            touchedDie = nodeAtPoint(location) as? Die
            if touchedDie != nil && (touchedDie!.slot == 0 || !canRoll) {
                touchedDie = nil
            }
        }

        if touchedDie == nil || touchedDie!.slot == 0 {
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
//                println("dx: \(dx), dy:\(dy)")

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

    func didBeginContact(contact: SKPhysicsContact) {
        if canRoll {
            if contact.bodyA.categoryBitMask == dieCategory {
                let die = contact.bodyA.node as! Die
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
            if contact.bodyB.categoryBitMask == dieCategory {
                let die = contact.bodyB.node as! Die
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
        }
    }

    override func touchesEnded(touches: Set<NSObject>, withEvent event: UIEvent) {
        if touchedDie != nil {
            println("touchedDie!.position: \(touchedDie!.position)")
            if touchedDie!.position.y > diceTrayHeight + diceHalf {
                println("dragTrajectory: \(touchedDie!.dragTrajectory.dx), dy:\(touchedDie!.dragTrajectory.dy)")
                touchedDie!.startRoll()
            } else {
                touchedDie!.moveToSlot(touchedDie!.slot)
            }

            touchedDie = nil
        }
    }

    func disableGravity() {
        canRoll = true
        physicsWorld.gravity = noGravity
        physicsBody!.friction = 0.0
    }

    func enableGravity() {
        canRoll = false
        physicsWorld.gravity = normalGravity
        physicsBody!.friction = 0.15
        for die in dice {
            if die.slot == 0 {
                die.stopRoll()
            }
        }

        println("physicsBody!.friction \(physicsBody!.friction)")

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkDice"), userInfo: nil, repeats: false)
    }

    func checkDice() {
        var restCount = 0
        for die in dice {
            if die.resting() {
                restCount++
            }
        }

        println("restCount: \(restCount)")

        if restCount == 5 {
            for die in dice {
                if die.slot == 0 {
                    for i in 1...5 {
                        var taken = false
                        for die2 in dice {
                            if die2.slot == i {
                                taken = true
                            }
                        }
                        if !taken {
                            die.moveToSlot(i)
                            break
                        }
                    }
                }
            }
            disableGravity()
        } else {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkDice"), userInfo: nil, repeats: false)
        }
    }
}
