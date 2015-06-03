//
//  GameViewController.swift
//  Yotse
//
//  Created by Jerad Rose on 3/18/15.
//  Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    var scene: GameScene!

    override func viewWillLayoutSubviews() {
        println("GameViewController.viewDidLoad")
        super.viewDidLoad()

        let skView = self.view as! SKView
        skView.multipleTouchEnabled = false

        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsPhysics = true

        let width = CGFloat(480)
        let height = skView.bounds.size.height * (width / skView.bounds.size.width)

        println ("width = \(width) height = \(height)")

        scene = GameScene(size: CGSize(width: width, height: height))

        /* Set the scale mode to scale to fit the window */
        scene.scaleMode = .AspectFill

        skView.presentScene(scene)
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.Portrait.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
