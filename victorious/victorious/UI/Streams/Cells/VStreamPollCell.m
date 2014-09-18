//
//  VStreamPollCell.m
//  victoriOS
//
//  Created by Will Long on 12/19/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamPollCell.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAnswer.h"
#import "VAsset.h"
#import "VPollResult.h"
#import "VUser.h"

#import "UIImage+ImageCreation.h"

#import "NSString+VParseHelp.h"

#import "VThemeManager.h"

NSString * const VStreamPollCellNibName = @"VStreamPollCell";

@interface VStreamPollCell ()
@property (nonatomic, weak) VAnswer *firstAnswer;
@property (nonatomic, weak) VAnswer *secondAnswer;

@property (nonatomic, copy) NSURL *firstAssetUrl;
@property (nonatomic, copy) NSURL *secondAssetUrl;

@end

@implementation VStreamPollCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    NSArray *answers = [[self.sequence firstNode] firstAnswers];
    self.firstAnswer = [answers firstObject];
    if ([answers count] >= 2)
    {
        self.secondAnswer = answers[1];
    }
    
    [self setupMedia];
}

- (void)setupMedia
{
    self.firstAssetUrl = [NSURL URLWithString: self.firstAnswer.thumbnailUrl];
    self.secondAssetUrl = [NSURL URLWithString:self.secondAnswer.thumbnailUrl];
    
    UIImage *placeholderImage = [UIImage resizeableImageWithColor:[[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]];
    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:self.firstAssetUrl];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:placeholderImage
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         if (!request)
         {
             self.previewImageView.image = image;
             return;
         }
         
         self.previewImageView.alpha = 0;
         self.previewImageView.image = image;
         self.previewImageView.contentMode = UIViewContentModeScaleAspectFill;
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
         if (!request)
         {
             self.previewImageTwo.image = image;
             return;
         }
         self.previewImageTwo.alpha = 0;
         self.previewImageTwo.image = image;
         self.previewImageTwo.contentMode = UIViewContentModeScaleAspectFill;
         [UIView animateWithDuration:.3f animations:^
          {
              self.previewImageTwo.alpha = 1;
          }];
     }
                                          failure:nil];
}

@end
