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
    var pluginVC: AudioUnitViewController!
    
    @IBOutlet weak var glView: GLView!
    @IBOutlet weak var pluginContainer: UIView!
    @IBOutlet weak var visualizeView: VisualizeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        player = AudioPlayer()
        player.delegate = self
        addPluginView()
        var componentDescription = AudioComponentDescription()
        componentDescription.componentType = kAudioUnitType_Effect
        componentDescription.componentSubType = 0x766f6c75 // 'volu' in hex using https://codebeautify.org/string-hex-converter
        componentDescription.componentManufacturer = 0x424f524d // 'BORM' in hex
        componentDescription.componentFlags = 0
        componentDescription.componentFlagsMask = 0
        AUAudioUnit.registerSubclass(VolumeAudioUnit.self, as: componentDescription, name: "VoluemPlugin", version: UInt32.max)
        glView.setup()
        player.selectAudioUnitWithComponentDescription(componentDescription) {
            self.pluginVC.audioUnit = self.player.volumeAudioUnit
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        player.play()
    }
    
    private func addPluginView() {
        let builtInPluginsURL = Bundle.main.builtInPlugInsURL
        guard let pluginURL = builtInPluginsURL?.appendingPathComponent("VolumeAudioUnit.appex") else {
            fatalError("can't get plugin URL")
        }
        let appExtensionBundle = Bundle(url: pluginURL)
        
        let storyboard = UIStoryboard(name: "MainInterface", bundle: appExtensionBundle)
        guard let pvc = storyboard.instantiateInitialViewController() as? AudioUnitViewController else {
            fatalError("can't instantiate plugin vc")
        }
        pluginVC = pvc
        
        addChild(pluginVC)
        if let view = pluginVC.view {
            addChild(pluginVC)
            view.frame = pluginContainer.bounds
            pluginContainer.addSubview(view)
            pluginVC.didMove(toParent: self)
        }
    }
}

extension ViewController : AudioPlayerDelegate {
    func onBuffer(_ samples: UnsafeBufferPointer<Float>) {
//        visualizeView.updateBuffer(samples)
        glView.updateBuffer(samples)
    }
}

