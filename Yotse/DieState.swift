//
// Created by Jerad Rose on 4/28/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation

enum DieState {
    case Locked
    case Dragging
    case Rolling
    case Dropping
    case Resting
    case Locking

    var description: String {
        switch (self) {
            case Locked: return "Locked"
            case Dragging: return "Dragging"
            case Rolling: return "Rolling"
            case Dropping: return "Dropping"
            case Resting: return "Resting"
            case Locking: return "Locking"
        }
    }
}
