//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
#import "VStreamCellHeaderView.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "VThemeManager.h"
#import "NSDate+timeSince.h"
#import "VUser.h"

#import "VHashTags.h"

#import "VUserProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIButton+VImageLoading.h"
#import "UIImage+ImageCreation.h"

#import "VConstants.h"

#import "VCommentCell.h"

#import "VEphemeralTimerView.h"


NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";

@interface VStreamViewCell() <VEphemeralTimerViewDelegate>

@property (nonatomic, weak) IBOutlet UILabel        *descriptionLabel;

@property (nonatomic) BOOL                          animating;
@property (nonatomic) NSUInteger                    originalHeight;

@property (nonatomic, strong) VEphemeralTimerView   *ephemeralTimerView;
@property (nonatomic, strong) NSArray               *hashTagRanges;

@end



@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
    self.originalHeight = self.frame.size.height;
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    self.ephemeralTimerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VEphemeralTimerView class]) owner:self options:nil] firstObject];
    self.ephemeralTimerView.delegate = self;
    self.ephemeralTimerView.center = self.center;
    [self addSubview:self.ephemeralTimerView];
 
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:@"VStreamCellHeaderView" owner:self options:nil] objectAtIndex:0];
    [self addSubview:self.streamCellHeaderView];

}

- (void)contentExpired
{
//    self.shadeView.backgroundColor = [UIColor whiteColor];
    self.previewImageView.alpha = .5f;
}

- (void)removeExpiredOverlay
{
//    self.shadeView.backgroundColor = [UIColor clearColor];
    self.previewImageView.alpha = 1.0f;
}

- (NSDictionary *)attributesForCellText
{
    return @{
             NSFontAttributeName: [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font],
             NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor],
             };
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self removeExpiredOverlay];

    [self.streamCellHeaderView setSequence:self.sequence];
    [self.streamCellHeaderView setParentViewController:self.parentTableViewController];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[_sequence.previewImagePaths firstObject]]];
    [request addValue:@"image/*" forHTTPHeaderField:@"Accept"];
    [self.previewImageView setImageWithURLRequest:request
                                 placeholderImage:[UIImage resizeableImageWithColor:
                                                   [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor]]
                                          success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image)
     {
         if (!request)
         {
             self.previewImageView.image = image;
             return;
         }
         
         self.previewImageView.alpha = 0;
         self.previewImageView.image = image;
         [UIView animateWithDuration:.3f
                          animations:^
          {
              self.previewImageView.alpha = 1;
          }];
     }
                                          failure:nil];
    
    // Hide Comment Button if Viewing from the User Profile
    if ([self.parentTableViewController isKindOfClass:[VUserProfileViewController class]])
    {
        [self.streamCellHeaderView hideCommentsButton];
        [self.streamCellHeaderView setIsFromProfile:YES];
    }

    
    VAsset* firstAsset = [[_sequence firstNode].assets.array firstObject];
    if ([firstAsset.type isEqualToString:VConstantsMediaTypeYoutube])
    {
        self.playButtonImage.hidden = NO;
    }
    else
    {
        self.playButtonImage.hidden = YES;
    }
    
    if (!self.sequence.nameEmbeddedInContent.boolValue)
    {
        NSString *text = self.sequence.name;
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[self attributesForCellText]];
        self.hashTagRanges = [VHashTags detectHashTags:text];
        NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
        paragraphStyle.maximumLineHeight = 25;
        paragraphStyle.minimumLineHeight = 25;
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        
        NSShadow *shadow = [NSShadow new];
        [shadow setShadowBlurRadius:5.0f];
        [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.75f]];
        [shadow setShadowOffset:CGSizeMake(2, -1)];
        
        if ([self.hashTagRanges count] > 0)
        {
            [VHashTags formatHashTagsInString:newAttributedCellText
                                withTagRanges:self.hashTagRanges
                                   attributes:@{NSForegroundColorAttributeName: [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor]}];
        }
        [newAttributedCellText addAttribute:NSParagraphStyleAttributeName
                                      value:paragraphStyle
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        [newAttributedCellText addAttribute:NSShadowAttributeName
                                      value:shadow
                                      range:NSMakeRange(0, newAttributedCellText.length)];
        
        self.descriptionLabel.attributedText = newAttributedCellText;
    }
    
    self.descriptionLabel.hidden = self.sequence.nameEmbeddedInContent.boolValue;
    
    
    if (_sequence.expiresAt)
    {
        self.ephemeralTimerView.hidden = NO;
        self.ephemeralTimerView.expireDate = _sequence.expiresAt;
        self.animationImage.hidden = YES;
        self.animationBackgroundImage.hidden = YES;
    }
    else
    {
        self.animationImage.hidden = NO;
        self.animationBackgroundImage.hidden = NO;
        self.ephemeralTimerView.hidden = YES;
    }
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (BOOL)remixRepostCheck:(NSString *)sequenceCategory
{
    if ([sequenceCategory rangeOfString:@"remix"].location == NSNotFound && [sequenceCategory rangeOfString:@"repost"].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (IBAction)commentButtonAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kStreamsWillCommentNotification object:self];
}

- (IBAction)profileButtonAction:(id)sender
{
    //If this cell is from the profile we should disable going to the profile
    BOOL fromProfile = NO;
    for (UIViewController* vc in self.parentTableViewController.navigationController.viewControllers)
    {
        if ([vc isKindOfClass:[VUserProfileViewController class]])
        {
            fromProfile = YES;
        }
    }
    if (fromProfile)
    {
        return;
    }
    
    VUserProfileViewController* profileViewController = [VUserProfileViewController userProfileWithUser:self.sequence.user];
    [self.parentTableViewController.navigationController pushViewController:profileViewController animated:YES];
}

- (void) hideOverlays
{
    self.overlayView.alpha = 0;
    self.shadeView.alpha = 0;
    self.animationImage.alpha = 0;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height);
}

- (void) showOverlays
{
    self.overlayView.alpha = 1;
    self.shadeView.alpha = 1;
    self.animationImage.alpha = 1;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y);
}

@end
