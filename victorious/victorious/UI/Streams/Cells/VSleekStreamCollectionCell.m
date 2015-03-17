//
//  VStreamCollectionCell-D.m
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSleekStreamCollectionCell.h"
#import "VSleekStreamCellActionView.h"
#import "VSequence+Fetcher.h"
#import "NSString+VParseHelp.h"
#import "VDependencyManager.h"

const CGFloat kTemplateDHeaderHeight = 50.0f;
const CGFloat kTemplateDActionViewHeight = 41.0f;
static const CGFloat kTextViewInset = 58.0f; //Needs to be sum of textview inset from left and right

const CGFloat kTemplateDActionViewBottomConstraintHeight = 28.0f; //This represents the space between the bottom of the cell and the actionView

//Use these 2 constants to adjust the spacing between the caption and comment count as well as the distance between the caption and the view above it and the comment label and the view below it
const CGFloat kTemplateDTextNeighboringViewSeparatorHeight = 10.0f; //This represents the space between the comment label and the view below it and the distance between the caption textView and the view above it

@implementation VSleekStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.actionViewBottomConstraint.constant = kTemplateDActionViewBottomConstraintHeight;
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
    [super setDependencyManager:dependencyManager];
    self.actionView.dependencyManager = dependencyManager;
    self.actionView.layer.borderColor = [UIColor clearColor].CGColor;
}

- (void)setDescriptionText:(NSString *)text
{
    [super setDescriptionText:text];
    
    BOOL zeroConstraints = !(!self.sequence.nameEmbeddedInContent.boolValue && text.length > 0);
    
    self.captionTextViewBottomConstraint.constant = zeroConstraints ? 0.0f : kTemplateDTextNeighboringViewSeparatorHeight;
}

- (void)reloadCommentsCount
{
    [(VSleekStreamCellActionView *)self.actionView updateCommentsCount:[self.sequence commentCount]];
}

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    self.actionView.sequence = sequence;
    [self setupActionBar];
    [self reloadCommentsCount];
}

- (void)setupActionBar
{
    [self.actionView clearButtons];
    
    //Add the "comments" button
    [(VSleekStreamCellActionView *)self.actionView addCommentsButton];
    
    [self.actionView addShareButton];
    if ( [self.sequence canRepost] )
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
}

- (NSUInteger)maxCaptionLines
{
    return 0;
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = width + kTemplateDHeaderHeight + kTemplateDActionViewHeight + kTemplateDActionViewBottomConstraintHeight;
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
        actual.height += textSize.height + kTemplateDTextNeighboringViewSeparatorHeight; //Neighboring space adds space BELOW the captionTextView
    }
    return actual;
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    attributes[ NSFontAttributeName ] = [dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
    attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerContentTextColorKey];
    attributes[ NSParagraphStyleAttributeName ] = [[NSMutableParagraphStyle alloc] init];
    return [NSDictionary dictionaryWithDictionary:attributes];
}

@end
