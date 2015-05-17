//
// Created by Jerad Rose on 4/24/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation

protocol GameActions {
    func ActivateGravity()
    func DeactivateGravity()
    func OpenBorder()
    func CloseBorder()
    func RestDice()
    func JoinDice()
    func SplitDice()
    func LockDice()
    func MakeDiceStatic()
    func NextTurn()
}
