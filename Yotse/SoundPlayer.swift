//
// Created by Jerad Rose on 5/27/15.
// Copyright (c) 2015 Brain Freeze Logic. All rights reserved.
//

import Foundation
import AVFoundation

class SoundPlayer {
    var sampler: AVAudioUnitSampler = AVAudioUnitSampler()
    var engine: AVAudioEngine = AVAudioEngine()
    let melodicBank: UInt8 = UInt8(kAUSampler_DefaultMelodicBankMSB)

    let gmMarimba: UInt8 = 12
    let gmHarpsichord: UInt8 = 6

    init() {
        engine.attachNode(sampler)
        engine.connect(sampler, to: engine.outputNode, format: nil)
        var soundbank = NSBundle.mainBundle().URLForResource("gs_instruments", withExtension: "dls")

        var error: NSError?
        if !sampler.loadSoundBankInstrumentAtURL(soundbank, program: gmMarimba, bankMSB: melodicBank, bankLSB: 0, error: &error) {
            println("Could not load soundbank")
        }

        if let e = error {
            println("error \(e.localizedDescription)")
            return
        }

        self.sampler.sendProgramChange(gmHarpsichord, bankMSB: melodicBank, bankLSB: 0, onChannel: 0)
        // play middle C, mezzo forte on MIDI channel 0
        self.sampler.startNote(60, withVelocity: 64, onChannel: 0)

        println("SoundPlayer initialized")
    }

    func play() {
    }
}
