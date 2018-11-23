//
//  VolumeAudioUnitAudioUnit.h
//  VolumeAudioUnit
//
//  Created by michal on 23/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

// Define parameter addresses.
extern const AudioUnitParameterID volumeParam;

@interface VolumeAudioUnit : AUAudioUnit

@end
