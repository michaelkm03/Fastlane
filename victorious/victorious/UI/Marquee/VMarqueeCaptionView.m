//
//  VMarqueeCaptionView.m
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMarqueeCaptionView.h"
#import "VStreamItem.h"
#import "VDependencyManager.h"

@interface VMarqueeCaptionView ()

@property (nonatomic, strong) IBOutletCollection(UIView) NSArray *dividerLines;
@property (nonatomic, strong) IBOutletCollection(NSLayoutConstraint) NSArray *dividierVerticalConstraints;
@property (nonatomic, strong) UIFont *captionFont;
@property (nonatomic, strong) UIFont *headlineFont;
@property (nonatomic, readwrite) BOOL hasHeadline;

@end

@implementation VMarqueeCaptionView

#pragma mark - Setters

- (void)setMarqueeItem:(VStreamItem *)marqueeItem
{
    BOOL firstItem = self.marqueeItem == nil;
    if ( [_marqueeItem isEqual:marqueeItem] )
    {
        //No need to update
        return;
    }
    _marqueeItem = marqueeItem;

    BOOL hasHeadline = marqueeItem.headline != nil;
    self.hasHeadline = hasHeadline;
    if ( !hasHeadline && firstItem )
    {
        [self updateDividerConstraints];
    }
    [self updateLabelText];
}

- (void)setHasHeadline:(BOOL)hasHeadline
{
    if ( _hasHeadline == hasHeadline )
    {
        //No need to update
        return;
    }
    
    _hasHeadline = hasHeadline;
    [self updateDividerConstraints];
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
    NSString *captionText = self.hasHeadline ? self.marqueeItem.headline : self.marqueeItem.name;
    self.captionLabel.text = captionText;
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
