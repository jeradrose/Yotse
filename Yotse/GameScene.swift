//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit
import UIKit

class GameScene: SKScene, SKPhysicsContactDelegate, GameActions, DieActions {
    let normalGravity: CGVector = CGVectorMake(0.0, -10.0)
    let noGravity: CGVector = CGVectorMake(0.0, 0.0)
    let diceWidth: CGFloat
    let diceHalf: CGFloat
    let offset: CGFloat

    var trayDice: [SKSpriteNode] = [SKSpriteNode]()
    let diceTray: SKSpriteNode
    let trayDiceAtlas: SKTextureAtlas = SKTextureAtlas(named: "TrayDice")
    let dieCategory: UInt32 = 0x01;
    let wallCategory: UInt32 = 0x02;

    var gameMode: GameMode = GameMode.Classic

    var data: GameData?
    var dice: [Die] = Array<Die>(count: 5, repeatedValue: Die())
    var touchedDie: Die?

    override init(size: CGSize) {
        println("init(size)")

        diceWidth = SKSpriteNode(imageNamed:"Dice_1").size.width
        diceHalf = diceWidth / 2
        offset = (size.width - (diceWidth * 5)) / 6

        let diceTrayTexture: SKTexture = SKTexture(imageNamed: "DiceTray")
        diceTray = SKSpriteNode(texture: diceTrayTexture, size: CGSize(width: size.width, height: (size.width * diceTrayTexture.size().height) / diceTrayTexture.size().width))

        for i in 0...4 {
            let die: Die = Die(diceValues: [1,2,3,4,5,6], slot: i, offset: offset)
            die.zPosition = 1
            die.physicsBody!.categoryBitMask = dieCategory
            die.physicsBody!.collisionBitMask = dieCategory | wallCategory
            die.physicsBody!.contactTestBitMask = dieCategory | wallCategory
            dice[i] = die
        }

        super.init(size: size)

        data = GameData(gameActions: self as GameActions)

        let trayDiceWidth: CGFloat = diceWidth / 3
        let trayDiceTop: CGFloat = diceTray.size.height - trayDiceWidth
        let trayDiceXStart: CGFloat = (size.width / 2) - (trayDiceWidth * 1.5)
        let trayDiceOffset: CGFloat = (trayDiceWidth * 1.5)

//        println("trayDiceWidth: \(trayDiceWidth)")
//        println("trayDiceTop: \(trayDiceTop)")
//        println("trayDiceXStart: \(trayDiceXStart)")
//        println("trayDiceOffset: \(trayDiceOffset)")

        for i in 0...4 {
            dice[i].actions = self as DieActions
            addChild(dice[i])
        }

        for i in 0...2 {
            trayDice.append(SKSpriteNode(imageNamed: "TrayDice_\(i+1)"))
            trayDice[i].size = CGSize(width: trayDiceWidth, height: trayDiceWidth)
            trayDice[i].position = CGPoint(x: trayDiceXStart + (trayDiceOffset * CGFloat(i)), y: trayDiceTop)
//            println("trayDice[\(i)].size: \(trayDice[i].size)")
//            println("trayDice[\(i)].position: \(trayDice[i].position)")
            trayDice[i].zPosition = 1
            addChild(trayDice[i])
        }

        data?.gameState = GameState.WaitingToRoll
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
    }

    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
        touchedDie = nil

        for touch in touches as! Set<UITouch> {
            let location = touch.locationInNode(self)
            println("location: \(location)")
            touchedDie = nodeAtPoint(location) as? Die
            if touchedDie != nil && (touchedDie!.state == DieState.Rolling ||
                    (data?.gameState != GameState.RollingDice &&
                     data?.gameState != GameState.WaitingToRoll &&
                     data?.gameState != GameState.WaitingToScoreOrRoll)) {
                touchedDie = nil
            }
        }

        if touchedDie != nil {
            touchedDie?.state = DieState.Dragging
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

//            if data?.currentRoll == 1 {
//                var isOutOfBounds: Bool = false
//                let minY = self.diceTray.size.height + diceHalf
//
//                for i in 1...5 {
//                    if lockedDice[i]!.position.y <= minY {
//                        isOutOfBounds = true
//                    }
//                }
//
//                if !isOutOfBounds {
//                    for i in 1...5 {
//                        let die: Die = lockedDice[i]!
//                        die.startRoll()
//                        lockedDice[i] = nil
//                        println("lockedDice[\(touchedDie!.slot)]: \(lockedDice[touchedDie!.slot])")
//                        rollingDice.append(die)
//                    }
//                } else {
//                    for i in 1 ... 5 {
//                        lockedDice[i]!.moveToSlot(i)
//                    }
//                }
//            } else {
                if touchedDie!.position.y > self.diceTray.size.height + diceHalf {
                    data!.gameState = GameState.RollingDice
                    touchedDie!.state = DieState.Rolling
                } else {
                    for die: Die in dice {
                        if die.state == DieState.Rolling {
                            data!.gameState = GameState.RollingDice
                        }
                    }
                    if data!.gameState != GameState.RollingDice {
                        data!.gameState = GameState.WaitingToRoll
                    }
                    touchedDie!.state = DieState.Locking
                }
//            }

            touchedDie = nil
        }
    }

    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.Down:
                data?.gameState = GameState.DiceComingToRest
            default:
                break
            }
        }
    }

    func didBeginContact(contact: SKPhysicsContact) {
        if contact.bodyA.categoryBitMask == dieCategory {
            let die = contact.bodyA.node as! Die
            if (die.speed(die.physicsBody!.velocity) > 60) {
                die.rollOnce()
            }
            if data?.gameState == GameState.RollingDice {
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
        }
        if contact.bodyB.categoryBitMask == dieCategory {
            let die = contact.bodyB.node as! Die
            if (die.speed(die.physicsBody!.velocity) > 60) {
                die.rollOnce()
            }
            if data?.gameState == GameState.RollingDice {
                die.physicsBody!.velocity = die.enforceSpeed(die.physicsBody!.velocity) * 1.1
            }
        }
    }

    func checkIfDiceAreResting() {
        for die: Die in dice {
            if die.state == DieState.Dropping && die.resting() {
                die.state = DieState.Resting
            }
        }

        for die: Die in dice {
            if die.state != DieState.Locked && die.state != DieState.Resting {
                NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkIfDiceAreResting"), userInfo: nil, repeats: false)
                println("Dice not yet resting...")
                return
            }
        }

        data?.gameState = GameState.DiceMovingToTray

        for die: Die in dice {
            println("die[\(die.slot)].state = \(die.state.description)")
            if die.state == DieState.Resting {
                die.state = DieState.Locking
            }
        }

        if (data?.currentRoll == data?.maxRoll) {
            data?.gameState = GameState.WaitingToScore
        } else {
            data?.gameState = GameState.WaitingToScoreOrRoll
        }
    }

    func NextTurn() {
        println("begin NextTurn()")
        for i in 1...3 {
            let transparent = data?.currentRoll > i ? "_Transparent" : ""
            trayDice[i - 1].runAction(SKAction.setTexture(trayDiceAtlas.textureNamed("TrayDice_\(i)\(transparent)")))
        }
        println("end NextTurn()")
    }

    func ActivateGravity() {
        println("begin ActivateGravity()")
        physicsWorld.gravity = normalGravity
        physicsBody!.friction = 0.15
        println("end ActivateGravity()")
    }

    func DeactivateGravity() {
        println("begin DeactivateGravity()")
        physicsWorld.gravity = noGravity
        physicsBody!.friction = 0.0
        println("end DeactivateGravity()")
    }

    func OpenBorder() {
        println("begin OpenBorder()")
//        let edgeOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y + diceTray.size.height)
//        let edgeSize = CGSize(width: frame.size.width, height: frame.size.height)
//
//        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: edgeOrigin, size: edgeSize))
//        physicsBody!.categoryBitMask = wallCategory
//        physicsBody!.collisionBitMask = wallCategory | dieCategory
        println("end OpenBorder()")
    }

    func CloseBorder() {
        println("begin CloseBorder()")
        let edgeOrigin = CGPoint(x: frame.origin.x, y: frame.origin.y + diceTray.size.height)
        let edgeSize = CGSize(width: frame.size.width, height: frame.size.height - diceTray.size.height)

        physicsBody = SKPhysicsBody(edgeLoopFromRect: CGRect(origin: edgeOrigin, size: edgeSize))
        physicsBody!.categoryBitMask = wallCategory
        physicsBody!.collisionBitMask = wallCategory | dieCategory
        println("end CloseBorder()")
    }

    func RestDice() {
        println("begin RestDice()")
        for i in 0...4 {
            println("dice[\(i)].slot = \(dice[i].slot)")
        }
        for die: Die in dice {
            println("die[\(die.slot)].state = \(die.state.description)")
            if die.state == DieState.Rolling {
                die.state = DieState.Dropping
            }
        }

        NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("checkIfDiceAreResting"), userInfo: nil, repeats: false)
        println("end RestDice()")
    }

    func LockDice() {
        println("begin LockDice()")
        for die: Die in dice {
            println("die[\(die.slot)].state = \(die.state.description)")
            if die.state == DieState.Resting {
                die.state = DieState.Locking
            }
        }
        println("end LockDice()")
    }

    func JoinDice() {
        println("begin JoinDice()")
//        for i in 0 ... 3 {
//            let joint = SKPhysicsJointSpring.jointWithBodyA(dice[i].physicsBody, bodyB: dice[i + 1].physicsBody, anchorA: dice[i].position, anchorB: dice[i + 1].position)
//            self.physicsWorld.addJoint(joint)
//        }
        println("end JoinDice()")
    }

    func SplitDice() {
        println("begin SplitDice()")
        self.physicsWorld.removeAllJoints()
        println("end SplitDice()")
    }

    func MakeDiceStatic() {
        println("begin MakeDiceStatic()")

        println("end MakeDiceStatic()")
    }

    func Lock(i: Int) {
        println("begin Lock(\(i))")
        dice[i].moveToSlot(i)
        dice[i].state = DieState.Locked
        println("end Lock(\(i))")
    }

    func Rest(i: Int) {
        println("begin Rest(\(i))")
        println("end Rest(\(i))")
    }

    func Drop(i: Int) {
        println("begin Drop(\(i))")
        dice[i].stopRoll()

        println("end Drop(\(i))")
    }

    func Roll(i: Int) {
        println("begin Roll(\(i))")
        dice[i].setDynamic(true)
        dice[i].startRoll()
        println("end Roll(\(i))")
    }
}
