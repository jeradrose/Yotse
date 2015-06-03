//
// Created by Jerad Rose on 4/21/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation

class GameData {
    var currentRoll: Int = 0
    var maxRoll: Int = 3
    var gameMode: GameMode = GameMode.Classic
    var dieState: [DieState] = [DieState.Locked, DieState.Locked, DieState.Locked, DieState.Locked, DieState.Locked]

    var turn: Int
    var gameActions: GameActions

    init(gameActions: GameActions) {
        self.gameActions = gameActions
        self.turn = 1
    }

    func score() {
        turn++
        currentRoll = 0
        gameState = GameState.WaitingToRoll
    }

    var gameState: GameState = GameState.Initialized {
        willSet {
            switch newValue {
                case GameState.Initialized:
                    return;
                case GameState.BeginningGame:
                    if (gameState == GameState.Initialized) {
                        return
                    }
                case GameState.WaitingToRoll:
                    if (gameState == GameState.WaitingToScore || gameState == GameState.WaitingToScoreOrRoll || gameState == GameState.BeginningGame) {
                        return
                    }
                case GameState.RollingDice:
                    if (gameState == GameState.WaitingToRoll || gameState == GameState.WaitingToScoreOrRoll || gameState == GameState.RollingDice) {
                        return
                    }
                case GameState.DiceComingToRest:
                    if (gameState == GameState.RollingDice) {
                        return
                    }
                case GameState.DiceMovingToTray:
                    if (gameState == GameState.DiceComingToRest) {
                        return
                    }
                case GameState.WaitingToScoreOrRoll:
                    if (gameState == GameState.DiceMovingToTray) {
                        return
                    }
                case GameState.WaitingToScore:
                    if (gameState == GameState.DiceMovingToTray) {
                        return
                    }
            }
            fatalError("GameState cannot be set from \(gameState.description) to \(newValue.description).")
        }
        didSet {
            println("Changing GameData.state from \(oldValue.description) to \(gameState.description)")
            switch gameState {
                case GameState.Initialized:
                    return
                case GameState.BeginningGame:
                    gameActions.OpenBorder()
                    gameActions.ActivateGravity()
                case GameState.WaitingToRoll:
                    gameActions.NextRoll()
                    gameActions.OpenBorder()
                    gameActions.JoinDice()
                case GameState.RollingDice:
                    if (oldValue == GameState.WaitingToScoreOrRoll) {
                        gameActions.NextRoll()
                    }
                    gameActions.SplitDice()
                    gameActions.CloseBorder()
                    gameActions.DeactivateGravity()
                case GameState.DiceComingToRest:
                    gameActions.ActivateGravity()
                    gameActions.RestDice()
                case GameState.DiceMovingToTray:
                    gameActions.LockDice()
                    gameActions.MakeDiceStatic()
                    gameActions.OpenBorder()
                case GameState.WaitingToScoreOrRoll:
                    gameActions.JoinDice()
                case GameState.WaitingToScore:
                    gameActions.JoinDice()
            }
        }
    }
}