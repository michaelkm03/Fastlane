//
//  VVideoCompositionController.h
//  victorious
//
//  Created by Michael Sena on 1/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import AVFoundation;

@interface VVideoCompositionController : NSObject

@property (nonatomic, strong) NSURL *videoURL;

@property (nonatomic, copy) void (^playerItemRedy)(AVPlayerItem *playerItem);

@end
