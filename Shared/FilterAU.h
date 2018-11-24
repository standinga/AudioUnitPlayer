//
//  FilterAU.h
//  AudioUnitPlayer
//
//  Created by michal on 24/11/2018.
//  Copyright © 2018 michal. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

NS_ASSUME_NONNULL_BEGIN

extern const AudioUnitParameterID cutoff;
extern const AudioUnitParameterID order;

@interface FilterAU : AUAudioUnit

@end

NS_ASSUME_NONNULL_END
