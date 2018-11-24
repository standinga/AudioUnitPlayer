//
//  AudioPlayer.swift
//  AudioUnitPlayer
//
//  Created by michal on 22/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

import AVFoundation

protocol AudioPlayerDelegate: class {
    func onBuffer(_ samples: UnsafeBufferPointer<Float>)
}

public class AudioPlayer: NSObject {
    
    weak var delegate: AudioPlayerDelegate?
    
    public var auAudioUnit: AUAudioUnit?
    
    private let stateChangeQueue = DispatchQueue(label: "AudioPlayer.stateChangeQueue")
    
    private let engine = AVAudioEngine()
    
    private let playerNode = AVAudioPlayerNode()
    
    private var avAudioUnit: AVAudioUnit?
    
    private var file: AVAudioFile?
    
    private var isPlaying = false
    
    override init() {
        super.init()
        
        engine.attach(playerNode)
        loadAudioFile()
        prepareEngine()
    }
    
    private func loadAudioFile() {
        guard let fileURL = Bundle.main.url(forResource: "drumLoop", withExtension: "caf") else {
            fatalError("can't create fileURL")
        }
        guard let file = try? AVAudioFile(forReading: fileURL) else {
            fatalError("can't load file")
        }
        self.file = file
        engine.connect(playerNode, to: engine.mainMixerNode, format: file.processingFormat)
    }
    
    private func prepareEngine() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
        } catch {
            fatalError("Can't set Audio Session category: \(error)")
        }
    }
    
    public func selectAudioUnitWithComponentDescription(_ componentDescription: AudioComponentDescription, completionHandler: @escaping ()->()) {
        
        func done() {
            if isPlaying {
                playerNode.play()
            }
            completionHandler()
        }
        
        let hardwareFormat = engine.outputNode.outputFormat(forBus: 0)
        
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: hardwareFormat)
        
        if isPlaying {
            playerNode.pause()
        }
        
        destroyAudioUnit()
        
        // Insert the audio unit, if any.
        
        AVAudioUnit.instantiate(with: componentDescription, options: []) { avAudioUnit, error in
            
            guard let avAudioUnit = avAudioUnit else {
                NSLog("avAudioUnit nil")
                return
            }
            self.avAudioUnit = avAudioUnit
            self.engine.attach(avAudioUnit)
            // disconnect and reconnect
            self.engine.disconnectNodeInput(self.engine.mainMixerNode)
            
            /// player -> effect
            self.engine.connect(self.playerNode, to: avAudioUnit, format: self.file!.processingFormat)
            
            /// effect -> mixer
            self.engine.connect(avAudioUnit, to: self.engine.mainMixerNode, format: self.file!.processingFormat)
            
            // get samples from audio unit
            avAudioUnit.installTap(onBus: 0, bufferSize: 4096 * 4, format: self.file!.processingFormat) { buffer, timestamp in
                let sampleData = UnsafeBufferPointer(start: buffer.floatChannelData![0], count: Int(buffer.frameLength))
                self.delegate?.onBuffer(sampleData)
            }
            
            self.auAudioUnit = avAudioUnit.auAudioUnit
            avAudioUnit.auAudioUnit.contextName = "running in AUv3Host"
            
            done()
        }
    }
    
    private func destroyAudioUnit() {
        if avAudioUnit != nil {
            engine.disconnectNodeInput(avAudioUnit!)
        
            // break audiounit -> mixer connection
            engine.disconnectNodeInput(engine.mainMixerNode)
            
            // connect player -> mixer
            engine.connect(playerNode, to: engine.mainMixerNode, format: file!.processingFormat)
            
            // release all references
            engine.detach(avAudioUnit!)
            
            avAudioUnit = nil
            auAudioUnit = nil
        }
    }
    
    
    
    public func play() {
        stateChangeQueue.sync {
            guard !self.isPlaying else { return }
            self.startPlayingInternal()
        }
    }
    
    private func startPlayingInternal() {
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            fatalError("Could not activate session: \(error)")
        }
        scheduleLoop()
        let hardwareFormat = self.engine.outputNode.outputFormat(forBus: 0)
        engine.connect(engine.mainMixerNode, to: engine.outputNode, format: hardwareFormat)
        do {
            try engine.start()
        } catch {
            fatalError("Could not start engine: \(error)")
        }
        
        playerNode.play()
        isPlaying = true
    }
    
    private func scheduleLoop() {
        guard let file = file else {
            fatalError("file must not be nil \(#function)")
        }
        playerNode.scheduleFile(file, at: nil) {
            self.stateChangeQueue.async {
                if self.isPlaying {
                    self.scheduleLoop()
                }
            }
        }
    }
    
    
}
