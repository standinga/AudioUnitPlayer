//
//  AudioUnitViewController.swift
//  VolumeAudioUnit
//
//  Created by michal on 23/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import CoreAudioKit
import AVFoundation

public class AudioUnitViewController: AUViewController, AUAudioUnitFactory {
    var audioUnit: AUAudioUnit?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        // Get the parameter tree and add observers for any parameters that the UI needs to keep in sync with the AudioUnit
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try VolumeAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
}
