//
//  ViewModel.swift
//  AudioUnitPlayer
//
//  Created by michal on 24/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import UIKit

class ViewModel: NSObject {
    
    static func initVolumeAU() -> AudioComponentDescription {
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x766f6c75 // 'volu' in hex using https://codebeautify.org/string-hex-converter
        componentDescription.componentManufacturer = 0x424f524d // 'BORM' in hex
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        AUAudioUnit.registerSubclass(VolumeAudioUnit.self, as: componentDescription, name: "VoluemPlugin", version: UInt32.max)
        return componentDescription
    }
    
    static func initFilterAU() -> AudioComponentDescription {
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x666c7472 // 'fltr' in hex using https://codebeautify.org/string-hex-converter
        componentDescription.componentManufacturer = 0x424f524d // 'BORM' in hex
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        AUAudioUnit.registerSubclass(FilterAU.self, as: componentDescription, name: "VoluemPlugin", version: UInt32.max)
        return componentDescription
    }
    
}
