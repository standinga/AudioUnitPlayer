//
//  VolumeAudioUnitAudioUnit.m
//  VolumeAudioUnit
//
//  Created by michal on 23/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

#import "VolumeAudioUnit.h"
#import "Buffers.hpp"
#import <AVFoundation/AVFoundation.h>

// Define parameter addresses.
const AudioUnitParameterID volumeParam = 0;

@interface VolumeAudioUnit ()

@property (nonatomic, readwrite) AUParameterTree *parameterTree;
@property AUAudioUnitBus *outputBus;
@property AUAudioUnitBusArray *inputBusArray;
@property AUAudioUnitBusArray *outputBusArray;
@end


@implementation VolumeAudioUnit {
    AUAudioUnitBus *_inputBus;
    Buffers _buffers;
    float volume;
}
@synthesize parameterTree = _parameterTree;

- (instancetype)initWithComponentDescription:(AudioComponentDescription)componentDescription options:(AudioComponentInstantiationOptions)options error:(NSError **)outError {
    self = [super initWithComponentDescription:componentDescription options:options error:outError];
    
    if (self == nil) {
        return nil;
    }
    volume = 1;
    // Initialize a default format for the busses.
    AVAudioFormat *defaultFormat = [[AVAudioFormat alloc] initStandardFormatWithSampleRate:44100.0 channels:2];
    
    // Create parameter objects.
    AUParameter *param1 = [AUParameterTree createParameterWithIdentifier:@"volume" name:@"Volume" address:volumeParam min:0 max:4.0 unit:kAudioUnitParameterUnit_Generic unitName:nil flags:0 valueStrings:nil dependentParameters:nil];
    
    // Initialize the parameter values.
    param1.value = 0.5;
    
    // Create the parameter tree.
    _parameterTree = [AUParameterTree createTreeWithChildren:@[ param1 ]];
    
    // Create the input and output busses (AUAudioUnitBus).
    _inputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    _outputBus = [[AUAudioUnitBus alloc] initWithFormat:defaultFormat error:nil];
    
    // Create the input and output bus arrays (AUAudioUnitBusArray).
    _inputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeInput busses:@[_inputBus]];
    _outputBusArray = [[AUAudioUnitBusArray alloc] initWithAudioUnit:self busType:AUAudioUnitBusTypeOutput busses:@[_outputBus]];
    
    // A function to provide string representations of parameter values.
    _parameterTree.implementorStringFromValueCallback = ^(AUParameter *param, const AUValue *__nullable valuePtr) {
        AUValue value = valuePtr == nil ? param.value : *valuePtr;
        
        switch (param.address) {
            case volumeParam:
                return [NSString stringWithFormat:@"%.f", value];
            default:
                return @"?";
        }
    };
    __block float *volumePtr = &volume;
    _parameterTree.implementorValueObserver = ^(AUParameter *param, AUValue value) {
        *volumePtr = value;
    };
    
    self.maximumFramesToRender = 512;
    
    return self;
}

#pragma mark - AUAudioUnit Overrides

// If an audio unit has input, an audio unit's audio input connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)inputBusses {
        return _inputBusArray;
}

// An audio unit's audio output connection points.
// Subclassers must override this property getter and should return the same object every time.
// See sample code.
- (AUAudioUnitBusArray *)outputBusses {
    return _outputBusArray;
}

// Allocate resources required to render.
// Subclassers should call the superclass implementation.
- (BOOL)allocateRenderResourcesAndReturnError:(NSError **)outError {
    if (![super allocateRenderResourcesAndReturnError:outError]) {
        return NO;
    }
    
    // Validate that the bus formats are compatible.
    if (self.outputBus.format.channelCount != _inputBus.format.channelCount) {
        if (outError) {
            *outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:kAudioUnitErr_FailedInitialization userInfo:nil];
            NSLog(@"kAudioUnitErr_FailedInitialization at %d", __LINE__);
        }
        self.renderResourcesAllocated = NO;
        return NO;
    }
    // Allocate your resources.
    _buffers.allocateRenderResources(self.maximumFramesToRender, _inputBus.format);
    
    return YES;
}

// Deallocate resources allocated in allocateRenderResourcesAndReturnError:
// Subclassers should call the superclass implementation.
- (void)deallocateRenderResources {
    // Deallocate your resources.
    [super deallocateRenderResources];
}
- (BOOL)canProcessInPlace {
    return YES;
}

#pragma mark - AUAudioUnit (AUAudioUnitImplementation)

// Block which subclassers must provide to implement rendering.
- (AUInternalRenderBlock)internalRenderBlock {
    // Capture in locals to avoid Obj-C member lookups. If "self" is captured in render, we're doing it wrong. See sample code.
    
    __block Buffers *buffers = &_buffers;
    __block float *volumePtr = &volume;
    return ^AUAudioUnitStatus(AudioUnitRenderActionFlags *actionFlags, const AudioTimeStamp *timestamp, AVAudioFrameCount frameCount, NSInteger outputBusNumber, AudioBufferList *outputData, const AURenderEvent *realtimeEventListHead, AURenderPullInputBlock pullInputBlock) {
        // Do event handling and signal processing here.
        AudioUnitRenderActionFlags pullFlags = 0;
        buffers->prepareInputBufferList();
        AUAudioUnitStatus err = pullInputBlock(&pullFlags, timestamp, frameCount, 0, buffers->mutableAudioBufferList);
        
        if (err != 0) {
            NSLog(@"pullInputBlock error %d", err);
            return err;
        }
        AudioBufferList *inAudioBufferList = buffers->mutableAudioBufferList;
        AudioBufferList *outputAudioBufferList = outputData;
        
        float *input = (float*)inAudioBufferList->mBuffers[0].mData;
        float *output = (float*)outputAudioBufferList->mBuffers[0].mData;
        UInt32 dataSize = inAudioBufferList->mBuffers[0].mDataByteSize;
        float vol = *volumePtr;
        for (int i = 0; i < dataSize; i++) {
            output[i] = vol * input[i];
        }
        
        return noErr;
    };
}

@end

