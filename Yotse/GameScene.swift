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
    var lockedDice: [Int: Die?] = [Int: Die?]()
    var rollingDice: [Die] = [Die]()

    var trayDice: [SKSpriteNode] = [SKSpriteNode]()

    var gameMode = GameMode.Classic
    var canRoll = true
    var touchedDie: Die?
    var rollNumber = 1

    let dieCategory: UInt32 = 0x01;
    let wallCategory: UInt32 = 0x02;

    let diceTray: SKSpriteNode

    let trayDiceAtlas: SKTextureAtlas = SKTextureAtlas(named: "TrayDice")


    override init(size: CGSize) {
        println("init(size)")

        diceWidth = SKSpriteNode(imageNamed:"Dice_1").size.width
        diceHalf = diceWidth / 2
        offset = (size.width - (diceWidth * 5)) / 6

        let diceTrayTexture: SKTexture = SKTexture(imageNamed: "DiceTray")
        diceTray = SKSpriteNode(texture: diceTrayTexture, size: CGSize(width: size.width, height: (size.width * diceTrayTexture.size().height) / diceTrayTexture.size().width))

        super.init(size: size)

        let trayDiceWidth: CGFloat = diceWidth / 3
        let trayDiceTop: CGFloat = diceTray.size.height - trayDiceWidth
        let trayDiceXStart: CGFloat = (size.width / 2) - (trayDiceWidth * 1.5)
        let trayDiceOffset: CGFloat = (trayDiceWidth * 1.5)

        println("trayDiceWidth: \(trayDiceWidth)")
        println("trayDiceTop: \(trayDiceTop)")
        println("trayDiceXStart: \(trayDiceXStart)")
        println("trayDiceOffset: \(trayDiceOffset)")

        for i in 0...2 {
            trayDice.append(SKSpriteNode(imageNamed: "TrayDice_\(i+1)"))
            trayDice[i].size = CGSize(width: trayDiceWidth, height: trayDiceWidth)
            trayDice[i].position = CGPoint(x: trayDiceXStart + (trayDiceOffset * CGFloat(i)), y: trayDiceTop)
            println("trayDice[\(i)].size: \(trayDice[i].size)")
            println("trayDice[\(i)].position: \(trayDice[i].position)")
            trayDice[i].zPosition = 1
            addChild(trayDice[i])
        }

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
        super.didMoveToView(view)

        let swipeDown: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: "respondToSwipeGesture:")
        swipeDown.direction = UISwipeGestureRecognizerDirection.Down
        self.view!.addGestureRecognizer(swipeDown)

        diceTray.position = CGPoint(x: frame.size.width / 2, y: diceTray.size.height / 2)
        diceTray.zPosition = 0
        addChild(diceTray)

        println("didMoveToView")
        backgroundColor = UIColor.whiteColor()

        physicsWorld.contactDelegate = self

        let edgeOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y + diceTray.size.height)
        let edgeSize = CGSize(width: frame.size.width, height: frame.size.height - diceTray.size.height)

        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: edgeOrigin, size: edgeSize))
        physicsBody!.categoryBitMask = wallCategory
        physicsBody!.collisionBitMask = wallCategory | dieCategory

        disableGravity()
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
                case UISwipeGestureRecognizerDirection.Down:
                    if canRoll {
                        enableGravity()
                    }
                default:
                    break
            }
        }
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
//                if rollingDice.count == 0 {
//                    nextRoll()
//                }
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

    func endRoll() {
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
        nextRoll()
        println("diceStopped")
    }

    func nextRoll() {
        rollNumber++
        if (rollNumber > 3) {
            rollNumber = 1
        }

        println("rollNumber: \(rollNumber)")

        for i in 1...3 {
            let transparent = rollNumber > i ? "_Transparent" : ""
            trayDice[i - 1].runAction(SKAction.setTexture(trayDiceAtlas.textureNamed("TrayDice_\(i)\(transparent)")))
        }
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
            endRoll()
        } else {
            NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkDice"), userInfo: nil, repeats: false)
        }
    }
}
