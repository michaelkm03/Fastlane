//
//  VInsetStreamCollectionCell.m
//  victorious
//
//  Created by Josh Hinman on 3/12/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSString+VParseHelp.h"
#import "VDependencyManager.h"
#import "VInsetStreamCollectionCell.h"
#import "VSequence+Fetcher.h"
#import "VStreamCellActionView.h"

// IMPORTANT: these template C constants much match up with the heights of values from the VStreamCollectionCell-C xib
static const CGFloat kAspectRatio = 0.94375f; // 320/302
static const CGFloat kHeaderHeight = 50.0f;
static const CGFloat kActionViewHeight = 41.0f;
static const CGFloat kTextViewInset = 22.0f; // Needs to be sum of textview inset from left and right

// Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
static const CGFloat kTextNeighboringViewSeparatorHeight = 10.0f; // This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it
static const CGFloat kTextSeparatorHeight = 6.0f; // This represents the space between the label and textView. It's slightly smaller than the those separating the label and textview from their respective bottom and top to neighboring views so that the centers of words are better aligned

@implementation VInsetStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
        
    self.commentsLeftConstraint.constant = -VStreamCollectionCellTextViewLineFragmentPadding;
    self.commentLabelBottomConstraint.constant = kTextNeighboringViewSeparatorHeight;
    self.captionTextViewTopConstraint.constant = kTextNeighboringViewSeparatorHeight;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    
    width *= kAspectRatio;
    CGFloat height = width + kHeaderHeight + kActionViewHeight + kTextNeighboringViewSeparatorHeight * 2.0f; // Width represents the desired media height, there are 2 neighboring separators (top to textview and bottom to comment label)
    return CGSizeMake(width, height);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    CGSize actual = [self desiredSizeWithCollectionViewBounds:bounds];
    
    CGFloat width = actual.width - kTextViewInset - VStreamCollectionCellTextViewLineFragmentPadding * 2;
    if ( !sequence.nameEmbeddedInContent.boolValue && sequence.name.length > 0 )
    {
        // Subtract insets and line fragment padding that is padding text in textview BEFORE calculating size
        CGSize textSize = [sequence.name frameSizeForWidth:width
                                             andAttributes:[self sequenceDescriptionAttributesWithDependencyManager:dependencyManager]];
        actual.height += textSize.height + kTextSeparatorHeight;
    }
    
    CGSize textSize = [[sequence.commentCount stringValue] frameSizeForWidth:width
                                                               andAttributes:[self sequenceCommentCountAttributesWithDependencyManager:dependencyManager]];
    actual.height += textSize.height;
    
    return actual;
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{
        NSForegroundColorAttributeName: [dependencyManager colorForKey:VDependencyManagerContentTextColorKey],
        NSFontAttributeName: [dependencyManager fontForKey:VDependencyManagerParagraphFontKey]
    };
}

- (NSString *)headerViewNibName
{
    return @"VInsetStreamCellHeaderView";
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)sequenceActionsDelegate
{
    [super setSequenceActionsDelegate:sequenceActionsDelegate];
    self.actionView.sequenceActionsDelegate = sequenceActionsDelegate;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    self.actionView.dependencyManager = dependencyManager;
    [self.commentsLabel setTextColor:[self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.actionView.sequence = sequence;
    [self reloadCommentsCount];
    [self setupActionBar];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    
    [self.actionView addShareButton];
    if ( [self.sequence canRemix] )
    {
        [self.actionView addRemixButton];
    }
    if ( [self.sequence canRepost] )
    {
        [self.actionView addRepostButton];
    }
    [self.actionView addMoreButton];
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    
    //Remove the space between label and textView if the textView is empty
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kTextSeparatorHeight;
}

- (void)reloadCommentsCount
{
    NSNumber *commentCount = [self.sequence commentCount];
    NSString *commentsString = [NSString stringWithFormat:@"%@ %@", [commentCount stringValue], [commentCount integerValue] == 1 ? NSLocalizedString(@"Comment", @"") : NSLocalizedString(@"Comments", @"")];
    [self.commentsLabel setText:commentsString];
    self.commentHeightConstraint.constant = [commentsString sizeWithAttributes:@{ NSFontAttributeName : self.commentsLabel.font }].height;
}

@end
