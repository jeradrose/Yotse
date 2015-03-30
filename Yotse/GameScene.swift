//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Jerad Rose. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    let textureAtlas = SKTextureAtlas(named: "Dice")
    override func didMoveToView(view: SKView) {
        println("GameScene.didMoveToView")

        self.backgroundColor = UIColor.whiteColor()

//        let diceY = SKSpriteNode(imageNamed: "DiceY")

        /* Setup your scene here */
//        let myLabel = SKLabelNode(fontNamed:"AppleSDGothicNeo-Regular")
//        myLabel.text = "What's up, Jordan!";
//        myLabel.fontSize = 45;
//        myLabel.position = CGPoint(x:CGRectGetMidX(self.frame), y:CGRectGetMidY(self.frame));

//        for i in 0..<5 {
//            let dice = SKSpriteNode(imageNamed: "Dice6")
//
//            dice.position = CGPoint(x:(CGFloat(30)+(Double(i*150))), y:(CGRectGetMaxY(self.frame)-80.0))
//        }

//        self.addChild(myLabel)
    }

    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        println("GameScene.touchesBegan")
        println(Int(-1))
        /* Called when a touch begins */

//        let dice1 = textureAtlas.textureNamed("Dice_1")
//        let dice2 = textureAtlas.textureNamed("Dice_2")
//        let dice3 = textureAtlas.textureNamed("Dice_3")
//        let dice4 = textureAtlas.textureNamed("Dice_4")
//        let dice5 = textureAtlas.textureNamed("Dice_5")
//        let dice6 = textureAtlas.textureNamed("Dice_6")
//        let diceY = textureAtlas.textureNamed("Dice_Y")
//        let diceO = textureAtlas.textureNamed("Dice_O")
//        let diceT = textureAtlas.textureNamed("Dice_T")
//        let diceS = textureAtlas.textureNamed("Dice_S")
//        let diceE = textureAtlas.textureNamed("Dice_E")
//
//        let textures = [dice1, dice2, dice3, dice4, dice5, dice6, diceY, diceO, diceT, diceS, diceE]

        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

            let sprite = SKSpriteNode(imageNamed:"Dice_1")
            
            sprite.position = location

//            SKAction *wait = [SKAction waitForDuration:1.0];
//            SKAction *sequence = [SKAction sequence:@[randomXMovement, wait]];
//            SKAction *repeat = [SKAction repeatActionForever:sequence];
//            [aSprite runAction: repeat];


            let rotateAction = SKAction.runBlock({
                let action = SKAction.rotateByAngle(self.rotateDice(), duration:0)

                sprite.runAction(action)
//                sprite.zRotation = CGFloat(M_PI/4.0)
//                let rotate = SKAction.rotateByAngle(M_PI, 0.1)
//                sprite.runAction(rotate)
            })

            let rollAction = SKAction.runBlock({
                sprite.runAction(SKAction.setTexture(self.textureAtlas.textureNamed("Dice_\(self.rollDice())")))
            })

//            let roll = SKAction.group([rotateAction, rollAction])
            let roll = SKAction.group([rollAction])
            let wait = SKAction.waitForDuration(0.1)

            let sequence = SKAction.sequence([roll, wait])
            let repeat = SKAction.repeatActionForever(sequence)
            sprite.runAction(repeat)

//            let action = SKAction.animateWithTextures(textures, timePerFrame: 0.1)

//            sprite.runAction(SKAction.repeatActionForever(action))

//            sprite.runAction(action)

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

    func rotateDice() -> CGFloat {
        var i = Int(arc4random_uniform(10)-4)
        var x = Int(-1)
        println(i)
//        if i > 0 {
//            i += 5
//        }
//        else {
//            i -= 6
//        }

//        let x = M_PI/Double(i)
//        println(x)
        return CGFloat(i)
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
