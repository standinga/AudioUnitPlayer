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
    
    public var audioUnit: AUAudioUnit? {
        didSet {
            DispatchQueue.main.async {
                if self.isViewLoaded {
                    self.connectWithAU()
                }
            }
        }
    }
    private var volumeParameter: AUParameter?
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if audioUnit == nil {
            return
        }
        
        connectWithAU()
    }
    
    public func connectWithAU() {
        guard let paramTree = audioUnit?.parameterTree else {
            fatalError("paramTree nil!")
        }
        volumeParameter = paramTree.value(forKey: "volume") as? AUParameter
    }
    
    public func createAudioUnit(with componentDescription: AudioComponentDescription) throws -> AUAudioUnit {
        audioUnit = try VolumeAudioUnit(componentDescription: componentDescription, options: [])
        
        return audioUnit!
    }
    
    @IBAction func volumeSliderAction(_ sender: UISlider) {
        volumeParameter?.value = sender.value
    }
}
