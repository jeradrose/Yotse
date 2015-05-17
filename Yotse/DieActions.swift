//
// Created by Jerad Rose on 4/28/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation

protocol DieActions {
    func Lock(Int)
    func Rest(Int)
    func Drop(Int)
    func Roll(Int)
}
