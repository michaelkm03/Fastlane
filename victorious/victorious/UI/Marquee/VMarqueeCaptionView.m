//
//  VMarqueeCaptionView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMarqueeCaptionView.h"
#import "VDependencyManager.h"
#import "VEditorializationItem.h"
#import "victorious-Swift.h"

static const CGFloat kPaddingForEmojiInLCaptionLabel = 10.0f;

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
}

- (void)updateLabelText
{
    NSString *captionText = self.hasHeadline ? self.editorialization.marqueeHeadline : self.marqueeItem.name;
    
    if (captionText != nil )
    {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = [self.captionFont v_fontSpecificLineSpace];
        NSMutableAttributedString *attributedCaptionString = [[NSMutableAttributedString alloc] initWithString:captionText attributes:@{NSParagraphStyleAttributeName: paragraphStyle}];
        
        CGFloat currentHeight = CGRectGetHeight([attributedCaptionString boundingRectWithSize:CGSizeMake(CGRectGetWidth(self.bounds), CGFLOAT_MAX)
                                                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                                                      context:nil]);
        CGFloat desiredLabelHeight = currentHeight + kPaddingForEmojiInLCaptionLabel;
        if (desiredLabelHeight > self.captionLabelMinimumHeightConstraint.constant)
        {
            self.captionLabelMinimumHeightConstraint.constant = desiredLabelHeight;
            [self setNeedsUpdateConstraints];
        }
        
        self.captionLabel.attributedText = attributedCaptionString;
    }
    else
    {
        self.captionLabelMinimumHeightConstraint.constant = 0;
        self.captionLabel.attributedText = nil;
    }
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
