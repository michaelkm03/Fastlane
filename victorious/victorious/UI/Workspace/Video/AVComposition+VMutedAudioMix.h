//
//  AVComposition+VMutedAudioMix.h
//  victorious
//
//  Created by Michael Sena on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface AVComposition (VMutedAudioMix)

- (AVAudioMix *)mutedAudioMix;

@end
