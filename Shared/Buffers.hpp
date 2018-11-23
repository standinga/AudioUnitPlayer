//
//  Buffers.hpp
//  AudioUnitPlayer
//
//  Created by michal on 23/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>

struct Buffers {
    AUAudioFrameCount maxFrames = 0;
    AVAudioPCMBuffer* pcmBuffer = nullptr;
    AudioBufferList const* originalAudioBufferList = nullptr;
    AudioBufferList* mutableAudioBufferList = nullptr;
    
    void allocateRenderResources(AUAudioFrameCount inMaxFrames, AVAudioFormat *format) {
        maxFrames = inMaxFrames;
        
        pcmBuffer = [[AVAudioPCMBuffer alloc] initWithPCMFormat:format frameCapacity: maxFrames];
        
        originalAudioBufferList = pcmBuffer.audioBufferList;
        mutableAudioBufferList = pcmBuffer.mutableAudioBufferList;
    }
    
    void prepareInputBufferList() {
        UInt32 byteSize = maxFrames * sizeof(float);
        
        mutableAudioBufferList->mNumberBuffers = originalAudioBufferList->mNumberBuffers;
        
        for (UInt32 i = 0; i < originalAudioBufferList->mNumberBuffers; ++i) {
            mutableAudioBufferList->mBuffers[i].mNumberChannels = originalAudioBufferList->mBuffers[i].mNumberChannels;
            mutableAudioBufferList->mBuffers[i].mData = originalAudioBufferList->mBuffers[i].mData;
            mutableAudioBufferList->mBuffers[i].mDataByteSize = byteSize;
        }
    }
};
