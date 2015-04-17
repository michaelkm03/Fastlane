//
//  VSleekStreamCollectionCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCollectionCell.h"

// Stream Support
#import "VSequence+Fetcher.h"

// Dependencies
#import "VDependencyManager.h"

// Views + Helpers
#import "NSString+VParseHelp.h"
#import "VStreamCellHeaderView.h"
#import "VSleekActionView.h"

const CGFloat kSleekCellHeaderHeight = 50.0f;
const CGFloat kSleekCellActionViewHeight = 41.0f;
static const CGFloat kTextViewInset = 58.0f; //Needs to be sum of textview inset from left and right

const CGFloat kSleekCellActionViewBottomConstraintHeight = 34.0f; //This represents the space between the bottom of the cell and the actionView
const CGFloat kSleekCellActionViewTopConstraintHeight = 8.0f; //This represents the space between the bottom of the content and the top of the actionView

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kSleekCellTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@interface VSleekStreamCollectionCell ()


@property (nonatomic, weak) IBOutlet UIView *loadingBackgroundContainer;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewTopConstraint;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *actionViewBottomConstraint;
@property (weak, nonatomic) IBOutlet VSleekActionView *sleekActionView;

@end

@implementation VSleekStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.actionViewBottomConstraint.constant = kSleekCellActionViewBottomConstraintHeight;
    self.actionViewTopConstraint.constant = kSleekCellActionViewTopConstraintHeight;
}

- (NSString *)headerViewNibName
{
    return @"VInsetStreamCellHeaderView";
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    if ( dependencyManager != nil )
    {
        [super setDependencyManager:dependencyManager];
        
        self.streamCellHeaderView.usernameLabel.textColor = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.streamCellHeaderView.dateLabel.textColor = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        self.streamCellHeaderView.commentButton.tintColor = [dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
        self.streamCellHeaderView.colorForParentSequenceAuthorName = [dependencyManager colorForKey:VDependencyManagerLinkColorKey];
        self.streamCellHeaderView.colorForParentSequenceText = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
        [self.streamCellHeaderView refreshAppearanceAttributes];
        
    }
    [self.sleekActionView setDependencyManager:dependencyManager];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.sleekActionView.sequence = sequence;
}

- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)sequenceActionsDelegate
{
    [super setSequenceActionsDelegate:sequenceActionsDelegate];
    self.sleekActionView.sequenceActionsDelegate = sequenceActionsDelegate;
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kSleekCellTextNeighboringViewSeparatorHeight;
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

#pragma mark - VBackgroundContainer

- (UIView *)loadingBackgroundContainerView
{
    return self.loadingBackgroundContainer;
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
