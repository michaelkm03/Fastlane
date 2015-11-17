//
//  VMarqueeCaptionView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMarqueeCaptionView.h"
#import "VStreamItem+Fetcher.h"
#import "VDependencyManager.h"
#import "VEditorializationItem.h"
#import "victorious-Swift.h"

static const CGFloat kDesiredLabelSizeMultiplier = 1.5;

@interface VMarqueeCaptionView ()

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *dividerLines;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *dividierVerticalConstraints;
@property (nonatomic, strong) UIFont *captionFont;
@property (nonatomic, strong) UIFont *headlineFont;
@property (nonatomic, readwrite) BOOL hasHeadline;
@property (nonatomic, readwrite) VStreamItem *marqueeItem;
@property (nonatomic, strong) VEditorializationItem *editorialization;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *captionLabelMinimumHeightConstraint;

@end

@implementation VMarqueeCaptionView

- (void)setupWithMarqueeItem:(VStreamItem *)marqueeItem fromStreamWithApiPath:(NSString *)apiPath
{
    BOOL firstItem = self.marqueeItem == nil;
    self.marqueeItem = marqueeItem;
    
    self.editorialization = [marqueeItem editorializationForStreamWithApiPath:apiPath];
    
    BOOL hasHeadline = self.editorialization.marqueeHeadline.length > 0;
    self.hasHeadline = hasHeadline;
    if ( !hasHeadline && firstItem )
    {
        [self updateDividerConstraints];
    }
    [self updateLabelText];
}

#pragma mark - Setters

- (void)setHasHeadline:(BOOL)hasHeadline
{
    if ( _hasHeadline == hasHeadline )
    {
        //No need to update
        return;
    }
    
    _hasHeadline = hasHeadline;
    [self updateDividerConstraints];
    [self updateFont];
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    if ( dependencyManager != nil )
    {
        UIColor *tintColor = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
        UIFont *captionFont = [self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey];
        UIFont *headlineFont = [self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey];
        
        self.captionLabel.textColor = tintColor;
        for ( UIView *view in self.dividerLines )
        {
            [view setBackgroundColor:tintColor];
        }
        self.captionFont = captionFont;
        self.headlineFont = headlineFont;
        [self updateFont];
    }
}

#pragma mark - View updating

- (void)updateFont
{
    UIFont *font = self.hasHeadline ? self.headlineFont : self.captionFont;
    [self.captionLabel setFont:font];
    
    CGSize currentSize = [self.captionLabel.attributedText size];
    CGFloat desiredLabelHeight = currentSize.height * kDesiredLabelSizeMultiplier;
    if (desiredLabelHeight > self.captionLabelMinimumHeightConstraint.constant)
    {
        self.captionLabelMinimumHeightConstraint.constant = desiredLabelHeight;
        [self setNeedsUpdateConstraints];
    }
}

- (void)updateLabelText
{
    NSString *captionText = self.hasHeadline ? self.editorialization.marqueeHeadline : self.marqueeItem.name;
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = [self.captionFont v_fontSpecificLineSpace];
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:captionText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
    
    self.captionLabel.attributedText = attributedText;
}

- (void)updateDividerConstraints
{
    for ( NSLayoutConstraint *constraint in self.dividierVerticalConstraints )
    {
        [constraint setActive:self.hasHeadline];
    }
    for ( UIView *dividerLine in self.dividerLines )
    {
        dividerLine.hidden = !self.hasHeadline;
    }
}

@end
