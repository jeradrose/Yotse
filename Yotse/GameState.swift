//
// Created by Jerad Rose on 4/21/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation

enum GameState {
    case BeginningGame
    case WaitingToRoll
    case RollingDice
    case DiceComingToRest
    case DiceMovingToTray
    case WaitingToScoreOrRoll
    case WaitingToScore

    var description: String {
        switch (self) {
        case BeginningGame: return "BeginningGame"
        case WaitingToRoll: return "WaitingToRoll"
        case RollingDice: return "RollingDice"
        case DiceComingToRest: return "DiceComingToRest"
        case DiceMovingToTray: return "DiceMovingToTray"
        case WaitingToScoreOrRoll: return "WaitingToScoreOrRoll"
        case WaitingToScore: return "WaitingToScore"
        }
    }
}
