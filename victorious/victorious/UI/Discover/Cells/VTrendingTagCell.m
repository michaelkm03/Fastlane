//
//  VTrendingTagCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrendingTagCell.h"
#import "VThemeManager.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VUserHashtag.h"
#import "VHashTags.h"
#import "VConstants.h"
#import "VHashtag.h"
#import "VFollowHashtagControl.h"

static const UIEdgeInsets kHashtagLabelEdgeInsets = { 0, 6, 0, 7 };

IB_DESIGNABLE
@interface VHashtagLabel : UILabel

@property (nonatomic, assign) UIEdgeInsets edgeInsets;

@end

@implementation VHashtagLabel

- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, kHashtagLabelEdgeInsets)];
}

- (CGSize)intrinsicContentSize
{
    CGSize size = [super intrinsicContentSize];
    size.width  += kHashtagLabelEdgeInsets.left + kHashtagLabelEdgeInsets.right;
    size.height += kHashtagLabelEdgeInsets.top + kHashtagLabelEdgeInsets.bottom;
    return size;
}

@end

static const CGFloat kTrendingTagCellRowHeight = 40.0f;

@interface VTrendingTagCell()

@property (nonatomic, weak) IBOutlet VHashtagLabel *hashTagLabel;
@property (nonatomic, weak) IBOutlet UIButton *followUnfollowButton;
@property (nonatomic, strong) NSString *hashtagText;


@end

@implementation VTrendingTagCell

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)applyTheme
{
    self.hashTagLabel.backgroundColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
    self.hashTagLabel.textColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVMainTextColor];
    self.hashTagLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading2Font];
    
    // Follow / Unfollow Button
    [self.followUnfollowButton setImage:[self.followUnfollowButton.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    self.followUnfollowButton.tintColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
}

- (void)setHashtag:(VHashtag *)hashtag
{
    // Make sure there's a # at the beginning of the text
    self.hashtagText = [VHashTags stringWithPrependedHashmarkFromString:hashtag.tag];
    
    [self.hashTagLabel setText:self.hashtagText];
    
    [self applyTheme];
}

- (BOOL)subscribedToTag
{
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];
    BOOL subscription = [mainUser.hashtags containsObject:self.hashtagText];
    return subscription;
}

- (void)updateSubscribeStatus
{
    //If we get into a weird state and the relaionships are the same don't do anything
    if (self.followHashtagControl.subscribed == self.subscribedToTag)
    {
        return;
    }
    if (!self.shouldAnimateSubscription)
    {
        self.followHashtagControl.subscribed = self.subscribedToTag;
        return;
    }
    
    [self.followHashtagControl setSubscribed:self.subscribedToTag
                                    animated:YES];
}

- (IBAction)followUnfollowHashtag:(id)sender
{
    self.shouldAnimateSubscription = YES;
    if (self.subscribeToTagAction)
    {
        self.subscribeToTagAction();
    }
}

@end
