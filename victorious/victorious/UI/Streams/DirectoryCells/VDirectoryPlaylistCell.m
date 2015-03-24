//
//  VDirectoryPlaylistCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDirectoryPlaylistCell.h"

@interface VDirectoryPlaylistCell ()

/**
 The label that will hold the stream name
 */
@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

/**
 The view that will hold the name label
 */
@property (nonatomic, weak) IBOutlet UIView *labelContainer;

@end

static const CGFloat kTextInset = 13.0f;

@implementation VDirectoryPlaylistCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self.nameLabel removeConstraints:self.nameLabel.constraints];
    NSDictionary *metrics = @{ @"inset" : @(kTextInset) };
    NSDictionary *views = @{ @"label" : self.nameLabel };
    [self.nameLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-inset-[label]-inset-|" options:0 metrics:metrics views:views]];
    [self.nameLabel addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-inset-[label]-inset-|" options:0 metrics:metrics views:views]];
}

@end
