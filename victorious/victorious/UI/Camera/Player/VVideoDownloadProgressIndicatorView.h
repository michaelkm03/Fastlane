//
//  VVideoDownloadProgressIndicatorView.h
//  victorious
//
//  Created by Josh Hinman on 5/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import AVFoundation;

#import <Foundation/Foundation.h>

/**
 Draws a series of not necessarily contiguous blocks
 to indicate which parts of a video have been
 downloaded.
 */
@interface VVideoDownloadProgressIndicatorView : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) NSArray *loadedTimeRanges; ///< An array of CMTimeRange values indicating the time ranges that have been loaded
@property (nonatomic)         CMTime   duration;           ///< The total duration of the video

@end
