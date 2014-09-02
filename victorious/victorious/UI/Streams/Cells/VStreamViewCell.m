//
//  VStreamViewCell.m
//  victoriOS
//
//  Created by David Keegan on 12/16/13.
//  Copyright (c) 2013 Victorious, Inc. All rights reserved.
//

#import "VStreamViewCell.h"
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

#import "VUserProfileViewController.h"

#import "VLargeNumberFormatter.h"

NSString *kStreamsWillCommentNotification = @"kStreamsWillCommentNotification";

@interface VStreamViewCell() <VEphemeralTimerViewDelegate>

@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *parentLabel;
@property (weak, nonatomic) IBOutlet UIButton *profileImageButton;
@property (weak, nonatomic) IBOutlet UIImageView *dateImageView;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;

@property (nonatomic) BOOL animating;
@property (nonatomic) NSUInteger originalHeight;

@property (strong, nonatomic) NSMutableArray* commentViews;

@property (strong, nonatomic) VEphemeralTimerView* ephemeralTimerView;

@property (nonatomic, strong) NSArray *hashTagRanges;

@end

static VLargeNumberFormatter* largeNumberFormatter;

@implementation VStreamViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if (!largeNumberFormatter)
    {
        largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    }
    
    self.originalHeight = self.frame.size.height;
    
    self.commentViews = [[NSMutableArray alloc] init];
    
    self.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVBackgroundColor];
    
    self.usernameLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel1Font];
    self.parentLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.dateLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel3Font];
    self.descriptionLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];

    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    
    self.ephemeralTimerView = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([VEphemeralTimerView class]) owner:self options:nil] firstObject];
    self.ephemeralTimerView.delegate = self;
    self.ephemeralTimerView.center = self.center;
    [self addSubview:self.ephemeralTimerView];
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

- (void)layoutSubviews
{
    self.profileImageButton.layer.cornerRadius = CGRectGetHeight(self.profileImageButton.bounds)/2;
    self.profileImageButton.clipsToBounds = YES;
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

    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_sequence.previewImage]];
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
    
    [self.profileImageButton setImageWithURL:[NSURL URLWithString:self.sequence.user.profileImagePathSmall ?: self.sequence.user.pictureUrl]
                            placeholderImage:[UIImage imageNamed:@"profile_thumb"]
                                    forState:UIControlStateNormal];
    
    if ([[[_sequence firstNode] firstAsset].type isEqualToString:VConstantsMediaTypeYoutube])
    {
        self.playButtonImage.hidden = NO;
    }
    else
    {
        self.playButtonImage.hidden = YES;
    }
    
    self.usernameLabel.text = self.sequence.user.name;

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
    
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    NSString* commentCount = self.sequence.commentCount.integerValue ? [largeNumberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
    [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
    
    // Hide Comment Button if Viewing from the User Profile
    if ([self.parentTableViewController isKindOfClass:[VUserProfileViewController class]])
    {
        [self.commentButton setHidden:YES];
    }
    
    
    NSString* parentUserString;
    if ([self.sequence isRepost] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"repostedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    if ([self.sequence isRemix] && self.sequence.parentUser)
    {
        parentUserString = [NSString stringWithFormat:NSLocalizedString(@"remixedFromFormat", nil), self.sequence.parentUser.name];
    }
    
    self.parentLabel.text = parentUserString;
    
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
