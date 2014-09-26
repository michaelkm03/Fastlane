//
//  VStreamViewCell.h
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VTableViewCell.h"
#import "VStreamTableViewController.h"

@class VSequence, VStreamCellHeaderView;

static NSString *kStreamViewCellIdentifier = @"VStreamViewCell";
static NSString *kStreamVideoCellIdentifier = @"VStreamVideoCell";

@interface VStreamViewCell : VTableViewCell

@property (nonatomic, weak) IBOutlet UIImageView            *previewImageView;
@property (nonatomic, weak) IBOutlet UIImageView            *playButtonImage;
@property (nonatomic, weak) IBOutlet UIImageView            *animationImage;
@property (nonatomic, weak) IBOutlet UIImageView            *animationBackgroundImage;
@property (nonatomic, weak) IBOutlet UIImageView            *lowerGradientView;
@property (nonatomic, weak) IBOutlet UIView                 *overlayView;
@property (nonatomic, weak) IBOutlet UIView                 *shadeView;
@property (nonatomic, weak) IBOutlet VStreamCellHeaderView  *streamCellHeaderView;
@property (nonatomic, weak) IBOutlet UIButton *commentHitboxButton;

@property (nonatomic, weak) VSequence                       *sequence;

@property (nonatomic, weak) id<VStreamCommentDelegate> commentDelegate;

- (void) hideOverlays;
- (void) showOverlays;

@end
