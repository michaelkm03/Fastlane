//
//  VCVideoPlayerToolbarView.h
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VCVideoPlayerViewController, VVideoDownloadProgressIndicatorView;

@interface VCVideoPlayerToolbarView : UIView

@property (nonatomic, weak) IBOutlet UIButton                            *playButton;
@property (nonatomic, weak) IBOutlet UISlider                            *slider;
@property (nonatomic, weak) IBOutlet VVideoDownloadProgressIndicatorView *progressIndicator;
@property (nonatomic, weak) IBOutlet UILabel                             *elapsedTimeLabel;
@property (nonatomic, weak) IBOutlet UILabel                             *remainingTimeLabel;

+ (instancetype)toolbarFromNibWithOwner:(VCVideoPlayerViewController *)filesOwner;

@end
