//
//  VStreamCollectionCell-D.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <FBKVOController.h>

#import "VSleekStreamCollectionCell.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "VSleekStreamCellActionView.h"
#import "NSString+VParseHelp.h"
#import "VStreamCellHeaderView.h"

const CGFloat kSleekCellHeaderHeight = 50.0f;
const CGFloat kSleekCellActionViewHeight = 41.0f;
static const CGFloat kTextViewInset = 58.0f; //Needs to be sum of textview inset from left and right

const CGFloat kSleekCellActionViewBottomConstraintHeight = 34.0f; //This represents the space between the bottom of the cell and the actionView
const CGFloat kSleekCellActionViewTopConstraintHeight = 8.0f; //This represents the space between the bottom of the content and the top of the actionView

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kSleekCellTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VSleekStreamCollectionCell ()

@property (nonatomic, weak) IBOutlet UIView *backgroundHost;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;

@end

@implementation VSleekStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.actionViewBottomConstraint.constant = kSleekCellActionViewBottomConstraintHeight;
    self.actionViewTopConstraint.constant = kSleekCellActionViewTopConstraintHeight;
}

- (NSString *)headerViewNibName
{
    return @"VInsetStreamCellHeaderView";
}

- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)sequenceActionsDelegate
{
    [super setSequenceActionsDelegate:sequenceActionsDelegate];
    self.actionView.sequenceActionsDelegate = sequenceActionsDelegate;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( dependencyManager != nil )
    {
        [super setDependencyManager:dependencyManager];
        self.actionView.dependencyManager = dependencyManager;
        self.streamCellHeaderView.usernameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.streamCellHeaderView.dateLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.streamCellHeaderView.commentButton.tintColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
        self.streamCellHeaderView.colorForParentSequenceAuthorName = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.streamCellHeaderView.colorForParentSequenceText = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        [self.streamCellHeaderView refreshAppearanceAttributes];
    }
    self.actionView.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kSleekCellTextNeighboringViewSeparatorHeight;
}

- (void)reloadCommentsCount
{
    [(VSleekStreamCellActionView *)self.actionView updateCommentsCount:[self.sequence commentCount]];
}

- (void)setSequence:(VSequence *)sequence
{
    [self.KVOController unobserve:self.sequence keyPath:NSStringFromSelector(@selector(hasReposted))];
    
    [super setSequence:sequence];
    self.actionView.sequence = sequence;
    [self setupActionBar];
    [self reloadCommentsCount];
    
    __weak typeof(self) welf = self;
    [self.KVOController observe:sequence
                        keyPath:NSStringFromSelector(@selector(hasReposted))
                        options:NSKeyValueObservingOptionNew
                          block:^(id observer, id object, NSDictionary *change)
     {
         [welf setupActionBar];
     }];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    
    //Add the "comments" button
    [(VSleekStreamCellActionView *)self.actionView addCommentsButton];
    
    [self.actionView addShareButton];
    if ( [self.sequence canRepost] || [self.sequence.hasReposted boolValue] )
    {
        [self.actionView addRepostButton];
    }
    
    if ( [self.sequence canRemix] )
    {
        BOOL isVideo = [self.sequence isVideo];
        if ( [self.sequence isImage] || isVideo )
        {
            [self.actionView addMemeButton];
        }
        if ( isVideo )
        {
            [self.actionView addGifButton];
        }
    }
    
    [self.actionView updateLayoutOfButtons];
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

#pragma mark - VBackgroundContainer

- (UIView *)backgroundContainerView
{
    return self.backgroundHost;
}

#pragma mark - Class Methods

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width + kSleekCellHeaderHeight + kSleekCellActionViewHeight + kSleekCellActionViewBottomConstraintHeight + kSleekCellActionViewTopConstraintHeight;
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];

    CGFloat width = actual.width - kTextViewInset - VStreamCollectionCellTextViewLineFragmentPadding * 2;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        //Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
        actual.height += textSize.height + kSleekCellTextNeighboringViewSeparatorHeight; //Neighboring space adds space BELOW the captionTextView
    }
    return actual;
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    if ( dependencyManager != nil )
    {
        attributes[ NSFontAttributeName ] = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    }
    attributes[ NSParagraphStyleAttributeName ] = [[NSMutableParagraphStyle alloc] init];
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
