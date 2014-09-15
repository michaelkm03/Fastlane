//
//  VContentVideoCell.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VContentVideoCell.h"

#import "VCVideoPlayerViewController.h"

@interface VContentVideoCell ()

@property (nonatomic, strong) VCVideoPlayerViewController *videoPlayerViewController;

@end

@implementation VContentVideoCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    return CGSizeMake(CGRectGetWidth(bounds), CGRectGetWidth(bounds));
}

#pragma mark - NSObject

- (void)awakeFromNib
{
    self.videoPlayerViewController = [[VCVideoPlayerViewController alloc] initWithNibName:nil
                                                                                   bundle:nil];
    self.videoPlayerViewController.view.frame = self.contentView.bounds;
    [self.contentView addSubview:self.videoPlayerViewController.view];
}

#pragma mark - Property Accessors

- (void)setVideoURL:(NSURL *)videoURL
{
    _videoURL = videoURL;
    
    [self.videoPlayerViewController setItemURL:videoURL];
}

@end
