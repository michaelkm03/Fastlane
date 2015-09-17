//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseVideoSequencePreviewView.h"

@protocol VVideoSequenceDelegate

- (void)animateAlongsideVideoToolbarWillAppear;

- (void)animateAlongsideVideoToolbarWillDisappear;

- (void)videoPlaybackDidFinish;

@end

@interface VVideoSequencePreviewView : VBaseVideoSequencePreviewView

@property (nonatomic, weak, nullable) id<VVideoSequenceDelegate> delegate;

@end
