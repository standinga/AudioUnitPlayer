//
//  ViewController.swift
//  AudioUnitPlayer
//
//  Created by michal on 22/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import UIKit
import AudioToolbox
import VolumeAudioUnit

class ViewController: UIViewController {

    private var player: AudioPlayer!
    override func viewDidLoad() {
        super.viewDidLoad()
        player = AudioPlayer()
        
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x766f6c75 // 'volu' in hex using https://codebeautify.org/string-hex-converter
        componentDescription.componentManufacturer = 0x424f524d // 'BORM' in hex
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        AUAudioUnit.registerSubclass(VolumeAudioUnit.self, as: componentDescription, name: "VoluemPlugin", version: UInt32.max)
        
        player.selectAudioUnitWithComponentDescription(componentDescription) {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
}

