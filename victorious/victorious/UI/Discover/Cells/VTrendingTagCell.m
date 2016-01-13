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
#import "VFollowControl.h"
#import "VDependencyManager.h"
#import "victorious-swift.h"

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

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass( self.class );
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    if ([AgeGate isAnonymousUser])
    {
        [self.followHashtagControl removeFromSuperview];
        self.followHashtagControl = nil;
    }
}

+ (NSInteger)cellHeight
{
    return kTrendingTagCellRowHeight;
}

- (void)setHashtagText:(NSString *)hashtagText
{
    _hashtagText = hashtagText;

    // Make sure there's a # at the beginning of the text
    NSString *text = [VHashTags stringWithPrependedHashmarkFromString:hashtagText];

    [self.hashTagLabel setText:text];

    [self updateSubscribeStatusAnimated:NO showLoading:NO];
}

- (BOOL)isSubscribedToTag
{
    _isSubscribedToTag = [[VCurrentUser user] isFollowingHashtagString:self.hashtagText];
    return _isSubscribedToTag;
}

- (void)updateSubscribeStatusAnimated:(BOOL)animated showLoading:(BOOL)loading
{
    VFollowControlState controlState = VFollowControlStateLoading;
    if ( !loading )
    {
        controlState = [VFollowControl controlStateForFollowing:self.isSubscribedToTag];
    }
    [self.followHashtagControl setControlState:controlState
                                      animated:animated];
}

- (IBAction)followUnfollowHashtag:(id)sender
{
    if (self.subscribeToTagAction != nil)
    {
        self.subscribeToTagAction();
    }
}

- (void)prepareForReuse
{
    self.isSubscribedToTag = NO;
    self.followHashtagControl.userInteractionEnabled = YES;
    self.followHashtagControl.alpha = 1.0f;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    self.followHashtagControl.dependencyManager = dependencyManager;
    self.hashTagLabel.backgroundColor = [_dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.hashTagLabel.textColor = [_dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    self.hashTagLabel.font = [_dependencyManager fontForKey:VDependencyManagerHeading2FontKey];
}

@end
