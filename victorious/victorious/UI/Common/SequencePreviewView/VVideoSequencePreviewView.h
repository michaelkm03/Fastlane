//
//  VVideoSequencePreviewView.h
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseVideoSequencePreviewView.h"

NS_ASSUME_NONNULL_BEGIN

@class VideoToolbarView;

@interface VVideoSequencePreviewView : VBaseVideoSequencePreviewView

@property (nonatomic, assign, readonly) BOOL toolbarDisabled;
@property (nonatomic, strong, readonly, nullable) VideoToolbarView *toolbar;

@end

NS_ASSUME_NONNULL_END
