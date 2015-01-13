//
//  VTrimmedPlayer.h
//  victorious
//
//  Created by Michael Sena on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>

@interface VTrimmedPlayer : AVPlayer

@property (nonatomic, assign) CMTimeRange trimRange;

@end
