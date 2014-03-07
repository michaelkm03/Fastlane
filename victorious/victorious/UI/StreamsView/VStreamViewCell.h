//
//  VStreamViewCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VTableViewCell.h"

@class VSequence;

static NSString *kStreamViewCellIdentifier = @"VStreamViewCell";
static NSString *kStreamYoutubeCellIdentifier = @"VStreamYoutubeCell";
static NSString *kStreamVideoCellIdentifier = @"VStreamVideoCell";
static NSString *kStreamYoutubeVideoCellIdentifier = @"VStreamYoutubeVideoCell";

extern NSString *kStreamsWillCommentNotification;

@interface VStreamViewCell : VTableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *previewImageView;
@property (weak, nonatomic) IBOutlet UIImageView *playButtonImage;
@property (weak, nonatomic) IBOutlet UIImageView *animationImage;
@property (weak, nonatomic) IBOutlet UIImageView *lowerGradientView;
@property (weak, nonatomic) IBOutlet UIView *overlayView;
@property (weak, nonatomic) IBOutlet UIView *shadeView;
@property (weak, nonatomic) VSequence* sequence;
@property (readonly, nonatomic) BOOL animating;

- (void)startAnimation;
- (void)stopAnimation;

@end
