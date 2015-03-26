//
//  GameScene.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Jerad Rose. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    override func didMoveToView(view: SKView) {
        println("GameScene.didMoveToView")
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
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)

            let i = Int(arc4random_uniform(11)+1)

            var dice = ""

            switch i {
                case 7:
                    dice = "Y"
                case 8:
                    dice = "O"
                case 9:
                    dice = "T"
                case 10:
                    dice = "S"
                case 11:
                    dice = "E"
                default:
                    dice = String(i)
            }
            
            let sprite = SKSpriteNode(imageNamed:"Dice" + dice)
            
            sprite.position = location

            let action = SKAction.rotateByAngle(CGFloat(M_PI), duration:1)
            
            sprite.runAction(SKAction.repeatActionForever(action))
            
            self.addChild(sprite)
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}
