//
//  VStreamCellHeaderView.m
//  victorious
//
//  Created by Lawrence Leach on 9/10/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCellHeaderView.h"
#import "VDefaultProfileButton.h"

#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "NSDate+timeSince.h"
#import "VUser.h"
#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"
#import "VLargeNumberFormatter.h"
#import "UIImage+ImageCreation.h"
#import "VConstants.h"

#import "VUserProfileViewController.h"

#import <KVOController/FBKVOController.h>

static VLargeNumberFormatter *largeNumberFormatter;

static const CGFloat kUserInfoViewMaxHeight = 25.0f;
static const CGFloat kCommentButtonBuffer = 5.0f;

@interface VStreamCellHeaderView ()

@property (nonatomic, weak) IBOutlet UILabel *parentLabel;

@property (nonatomic, assign) NSInteger defaultUsernameBottomConstraintValue;

@end

@implementation VStreamCellHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void)
    {
        largeNumberFormatter = [[VLargeNumberFormatter alloc] init];
    });
    
    _commentViews = [[NSMutableArray alloc] init];
    
    self.dateImageView.image = [self.dateImageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, kCommentButtonBuffer, 0, 0)];

    [self refreshAppearanceAttributes];
    
    self.defaultUsernameBottomConstraintValue = self.usernameLabelBottomConstraint.constant;
    
}

- (void)hideCommentsButton
{
    [self.commentButton setHidden:YES];
}

- (void)reloadCommentsCount
{
    // Get comment count (if any)
    NSString *commentCount = self.sequence.commentCount.integerValue ? [largeNumberFormatter stringForInteger:self.sequence.commentCount.integerValue] : @"";
    [self.commentButton setTitle:commentCount forState:UIControlStateNormal];
}

- (void)setParentText:(NSString *)text
{
    // Format repost / remix string
    NSString *parentUserString;
    NSString *displaySafeText = text == nil ? @"" : text;
    if ( self.colorForParentSequenceText != nil )
    {
        self.parentLabel.textColor = self.colorForParentSequenceText;
    }
    
    CGFloat usernameBottomConstant = self.usernameLabelTopConstraint.constant;
    if (self.sequence.isRepost.boolValue && self.sequence.parentUser != nil)
    {
        usernameBottomConstant = self.defaultUsernameBottomConstraintValue;
        NSUInteger repostCount = [self.sequence.repostCount unsignedIntegerValue];
        if ( repostCount == 0 )
        {
            parentUserString = [NSString stringWithFormat:NSLocalizedString(@"repostedByFormat", nil), displaySafeText];
        }
        else if ( repostCount == 1 )
        {
            parentUserString = [NSString stringWithFormat:NSLocalizedString(@"doubleRepostedByFormat", nil), displaySafeText];
        }
        else
        {
            parentUserString = [NSString stringWithFormat:NSLocalizedString(@"multipleRepostedByFormat", nil), displaySafeText, [self.sequence.repostCount unsignedLongValue]];
        }
    }
    else if (self.sequence.isRemix.boolValue && self.sequence.parentUser != nil)
    {
        usernameBottomConstant = self.defaultUsernameBottomConstraintValue;
        NSString *formatString = NSLocalizedString(@"remixedFromFormat", nil);
        if ([[[[self.sequence firstNode] mp4Asset] playerControlsDisabled] boolValue])
        {
            formatString = NSLocalizedString(@"giffedFromFormat", nil);
        }
        parentUserString = [NSString stringWithFormat:formatString, displaySafeText];
    }
    
    self.usernameLabelBottomConstraint.constant = usernameBottomConstant;
    
    NSDictionary *attributes = @{
                                 NSFontAttributeName: self.parentLabel.font,
                                 NSForegroundColorAttributeName:  self.parentLabel.textColor,
                                 };
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:parentUserString ?: @""
                                                                                         attributes:attributes];
    if ( text != nil && parentUserString != nil && self.colorForParentSequenceAuthorName != nil )
    {
        NSRange range = [parentUserString rangeOfString:text];
        
        [attributedString addAttribute:NSForegroundColorAttributeName
                                 value:self.colorForParentSequenceAuthorName
                                 range:range];
    }
    
    self.parentLabel.attributedText = attributedString;
}

- (void)refreshParentLabelAttributes
{
    [self setParentText:[self parentUser].name];
}

- (void)setSequence:(VSequence *)sequence
{
    if (_sequence == sequence)
    {
        return;
    }
    
    [self.KVOController unobserve:sequence.user];
    
    _sequence = sequence;
    
    if (sequence.user == nil)
    {
        return;
    }
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:sequence.user
                       keyPaths:@[NSStringFromSelector(@selector(name)), NSStringFromSelector(@selector(pictureUrl))]
                        options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf updateWithCurrentUser];
     }];
}

- (void)updateWithCurrentUser
{
    if (self.sequence.user == nil)
    {
        return;
    }
    
    VUser *originalPoster = [self originalPoster];
    VUser *parentUser = [self parentUser];
    
    [self.profileImageButton setProfileImageURL:[NSURL URLWithString:originalPoster.pictureUrl]
                                       forState:UIControlStateNormal];
    
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    
    [self reloadCommentsCount];
    
    NSString *parentText = parentUser != nil ? parentUser.name : @"";
    [self setParentText:parentText];
    
    // Set username and format date
    self.usernameLabel.text = originalPoster.name;
    self.dateLabel.text = [self.sequence.releasedAt timeSince];
    
    // Check if this is a repost / remix and size the userInfoView accordingly
    if (self.sequence.parentUser)
    {
        self.userInfoViewHeightConstraint.constant = kUserInfoViewMaxHeight;
    }
    else
    {
        self.userInfoViewHeightConstraint.constant = self.usernameLabel.intrinsicContentSize.height;
    }
}

- (VUser *)originalPoster
{
    return [self.sequence.isRepost boolValue] ? self.sequence.parentUser : self.sequence.user;
}

- (VUser *)parentUser
{
    return [self.sequence.isRepost boolValue] ? self.sequence.user : self.sequence.parentUser;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [self refreshAppearanceAttributes];
    [self refreshParentLabelAttributes];
}

- (void)setColorForParentSequenceAuthorName:(UIColor *)colorForParentSequenceAuthorName
{
    _colorForParentSequenceAuthorName = colorForParentSequenceAuthorName;
    [self refreshParentLabelAttributes];
}

- (void)setColorForParentSequenceText:(UIColor *)colorForParentSequenceText
{
    _colorForParentSequenceText = colorForParentSequenceText;
    [self refreshParentLabelAttributes];
}

- (void)refreshAppearanceAttributes
{
    if ( self.dependencyManager == nil )
    {
        return;
    }
    
    // Style the ui
    self.usernameLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    self.parentLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    [self.commentButton.titleLabel setFont:[self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey]];
    self.dateLabel.font = [self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey];
    self.profileImageButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
    self.dateImageView.tintColor = self.dateLabel.textColor;
    self.commentButton.tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
}

#pragma mark - Button Actions

- (IBAction)profileButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(selectedUser:onSequence:fromView:)])
    {
        VSequence *sequence = self.sequence;
        VUser *user = sequence.user;
        if ( sequence.isRepost.boolValue && sequence.parentUser != nil )
        {
            user = sequence.parentUser;
        }
        [self.delegate selectedUser:user onSequence:sequence fromView:self];
    }
}

- (IBAction)commentButtonAction:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.delegate willCommentOnSequence:self.sequence fromView:self];
    }
}

@end
