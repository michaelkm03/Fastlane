//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"

#import "VObjectManager+Sequence.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "UIImage+ImageCreation.h"

#import "NSString+VParseHelp.h"

#import "VThemeManager.h"

static NSString* kOrIconImage = @"orIconImage";

@import MediaPlayer;

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer* firstAnswer;
@property (nonatomic, weak) VAnswer* secondAnswer;

@property (nonatomic, copy) NSURL* firstAssetUrl;
@property (nonatomic, copy) NSURL* secondAssetUrl;

@end

@implementation VStreamPollCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray* answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupMedia];
}

- (void)setupMedia
{
    VAsset* firstAsset = [[self.sequence firstNode] firstAsset];
    if (firstAsset)
    {
        self.firstAssetUrl = [firstAsset.data convertToPreviewImageURL];
    }
    else
    {
        self.firstAssetUrl = [self.firstAnswer.mediaUrl convertToPreviewImageURL];
        self.secondAssetUrl = [self.secondAnswer.mediaUrl convertToPreviewImageURL];
    }
    
    UIImage* placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.firstAssetUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         self.previewImageView.alpha = 0;
         self.previewImageView.image = image;
         [UIView animateWithDuration:.3f animations:^
          {
              self.previewImageView.alpha = 1;
          }];
     }
                                          failure:nil];
    
    request = [NSMutableURLRequest requestWithURL:self.secondAssetUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageTwo setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         self.previewImageTwo.alpha = 0;
         self.previewImageTwo.image = image;
         [UIView animateWithDuration:.3f animations:^
          {
              self.previewImageTwo.alpha = 1;
          }];
     }
                                          failure:nil];
}
@end
