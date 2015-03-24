//
//  VTrendingTagCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTrendingTagCell.h"
#import "VObjectManager+Users.h"
#import "VUser.h"
#import "VHashTags.h"
#import "VConstants.h"
#import "VHashtag.h"
#import "VFollowHashtagControl.h"
#import "VDependencyManager.h"

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
@property (nonatomic, readwrite) BOOL isSubscribedToTag;

@end

@implementation VTrendingTagCell

- (void)setShouldCellRespond:(BOOL)shouldCellRespond
{
    if (_shouldCellRespond == shouldCellRespond)
    {
        return;
    }

    _shouldCellRespond = shouldCellRespond;
}

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)setHashtag:(VHashtag *)hashtag
{
    _hashtag = hashtag;

    // Make sure there's a # at the beginning of the text
    NSString *hashtagText = hashtag.tag;
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];

    [self.hashTagLabel setText:text];

    if (self.isSubscribedToTag)
    {
        self.followHashtagControl.subscribed = YES;
    }
    [self updateSubscribeStatusAnimated:NO];
}

- (BOOL)isSubscribedToTag
{
    BOOL subscribed = NO;
    VUser *mainUser = [[VObjectManager sharedManager] mainUser];

    for (VHashtag *aTag in mainUser.hashtags)
    {
        if ([aTag.tag isEqualToString:self.hashtag.tag])
        {
            subscribed = YES;
            break;
        }
    }
    _isSubscribedToTag = subscribed;

    return subscribed;
}

- (void)updateSubscribeStatusAnimated:(BOOL)animated
{
    //If we get into a weird state and the relaionships are the same don't do anything
    if (self.followHashtagControl.subscribed == self.isSubscribedToTag)
    {
        return;
    }
    if (!self.shouldAnimateSubscription)
    {
        self.followHashtagControl.subscribed = self.isSubscribedToTag;
        return;
    }

    // Animate it
    [self.followHashtagControl setSubscribed:self.isSubscribedToTag
                                    animated:animated];

    // Re-enable the control
    self.followHashtagControl.userInteractionEnabled = YES;
    [self enableSubscriptionIcon:nil];
}

- (IBAction)followUnfollowHashtag:(id)sender
{
    if (!self.shouldCellRespond)
    {
        return;
    }
    else
    {
        self.shouldAnimateSubscription = YES;
        if (self.subscribeToTagAction != nil)
        {
            self.subscribeToTagAction();
        }
    }
}

- (void)prepareForReuse
{
    self.shouldCellRespond = YES;
    self.isSubscribedToTag = NO;
    self.followHashtagControl.userInteractionEnabled = YES;
    self.followHashtagControl.alpha = 1.0f;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.hashTagLabel.backgroundColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.hashTagLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.hashTagLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
    self.followHashtagControl.tintColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

#pragma mark - Disable / Enable Tag Subscription Button

- (void)disableSubscriptionIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followHashtagControl.alpha = 0.3f;
    };

    [UIView transitionWithView:self.followHashtagControl
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
}

- (void)enableSubscriptionIcon:(id)sender
{
    void (^animations)() = ^(void)
    {
        self.followHashtagControl.alpha = 1.0f;
    };

    [UIView transitionWithView:self.followHashtagControl
                      duration:0.3
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:animations
                    completion:nil];
}

@end
