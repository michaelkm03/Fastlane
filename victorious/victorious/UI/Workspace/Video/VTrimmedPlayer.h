//
//  VTrimmedPlayer.h
//  victorious
//
//  Created by Michael Sena on 1/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import AVFoundation;

@class VTrimmedPlayer;

@protocol VTrimmedPlayerDelegate <NSObject>

- (void)trimmedPlayerPlayedToTime:(CMTime)currentPlayTime
                    trimmedPlayer:(VTrimmedPlayer *)trimmedPlayer;

@end

@interface VTrimmedPlayer : AVPlayer

@property (nonatomic, weak) id <VTrimmedPlayerDelegate> delegate;

@property (nonatomic, assign) CMTimeRange trimRange;

@end
