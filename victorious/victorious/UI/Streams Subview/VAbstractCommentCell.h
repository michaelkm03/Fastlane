//
//  VAbstractCommentCell.h
//  victorious
//
//  Created by Will Long on 5/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTableViewCell.h"

@import MediaPlayer;

@class VUser;

extern CGFloat const kEstimatedCommentRowHeight;
extern CGFloat const kEstimatedCommentRowWithMediaHeight;
extern CGFloat const kMessageLabelWidth;

@interface VAbstractCommentCell : VTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *mediaPreview;
@property (weak, nonatomic) IBOutlet UIButton *playButton;

@property (strong, nonatomic) NSURL *mediaUrl;
@property (strong, nonatomic) NSURL *previewImageUrl;
@property (strong, nonatomic) VUser* user;

@property (nonatomic, strong) MPMoviePlayerController* mpController;

+ (CGSize)frameSizeForMessageText:(NSString*)text;

-(void)layoutWithMinHeight:(CGFloat)minHeight yOffset:(CGFloat)yOffset;

@end
