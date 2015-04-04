//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    let textureAtlas = SKTextureAtlas()
    let diceWidth = Double(0)
    let restitution = CGFloat(0.7)
    let friction = CGFloat(0.15)
    let linearDamping = CGFloat(0.0)
    let gravity = CGFloat(-50.0)

    var dice = [SKSpriteNode]()
    var gameMode = GameMode.Classic

    required init?(coder aDecoder: NSCoder) {
        textureAtlas = SKTextureAtlas(named: "Dice")
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
            dice.append(addDice(CGPoint(x: (spacing * Double(i)) + offset, y: offset)))
        }
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        for i in 0..<5 {
            dice[i].removeActionForKey("roll")
        }
    }

    func addDice(position: CGPoint) -> SKSpriteNode {
        println("addDice(position.x: \(position.x), position.y: \(position.y))")
        let sprite = SKSpriteNode(imageNamed:"Dice_1")

        sprite.position = position

        sprite.physicsBody = SKPhysicsBody(texture: textureAtlas.textureNamed("Dice_1"), size: sprite.size)
        sprite.physicsBody!.dynamic = false

        sprite.physicsBody!.restitution = restitution
        sprite.physicsBody!.friction = friction
        sprite.physicsBody!.linearDamping = linearDamping

        let roll = SKAction.runBlock({
            sprite.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDice())")))
        })

        let wait = SKAction.waitForDuration(0.1)

        let sequence = SKAction.sequence([roll, wait])
        let repeat = SKAction.repeatActionForever(sequence)

        sprite.runAction(repeat, withKey: "roll")

        self.addChild(sprite)

        return sprite
    }

    func rollDice() -> String {
        let i = Int(arc4random_uniform(gameMode == GameMode.Classic ? 6 : 11)+1)

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
