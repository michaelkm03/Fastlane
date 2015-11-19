//
//  VCrossFadingMarqueeLabel.m
//  victorious
//
//  Created by Sharif Ahmed on 7/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCrossFadingMarqueeLabel.h"
#import "VMarqueeCaptionView.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager.h"

static NSString * const kCaptionViewNibName = @"VBlurredMarqueeCaptionView";

@interface VCrossFadingMarqueeLabel ()

@property (nonatomic, strong) NSArray *marqueeCaptionViews;
@property (nonatomic, strong) UIColor *tintColor;
@property (nonatomic, strong) UIFont *captionFont;
@property (nonatomic, strong) UIFont *headlineFont;
@property (nonatomic, strong) NSString *streamApiPath;
@property (nonatomic, readwrite) NSArray *marqueeItems;

@end

@implementation VCrossFadingMarqueeLabel

#pragma mark - View setup

- (void)reset
{
    for ( VMarqueeCaptionView *marqueeCaptionView in self.marqueeCaptionViews )
    {
        [marqueeCaptionView removeFromSuperview];
    }
    self.marqueeCaptionViews = nil;
}

- (void)setupWithMarqueeItems:(NSArray *)marqueeItems fromStreamWithApiPath:(NSString *)apiPath
{
    [self reset];
    self.streamApiPath = apiPath;
    self.marqueeItems = marqueeItems;
    [self populateCaptionViews];
}

- (void)populateCaptionViews
{
    NSMutableArray *captionViews = [[NSMutableArray alloc] init];
    for ( VStreamItem *marqueeItem in self.marqueeItems )
    {
        VMarqueeCaptionView *captionView = [[[NSBundle mainBundle] loadNibNamed:kCaptionViewNibName owner:self options:nil] firstObject];
        captionView.dependencyManager = self.dependencyManager;
        [captionView setupWithMarqueeItem:marqueeItem fromStreamWithApiPath:self.streamApiPath];
        [self addSubview:captionView];
        [self v_addPinToLeadingTrailingToSubview:captionView];
        [self v_addCenterVerticallyConstraintsToSubview:captionView];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=0)-[captionView]-(>=0)-|"
                                                                     options:kNilOptions metrics:nil
                                                                       views:@{ @"captionView" : captionView }]];
        [captionViews addObject:captionView];
    }
    self.marqueeCaptionViews = [NSArray arrayWithArray:captionViews];
    [self refresh];
}

#pragma mark - Superclass overrides

- (NSArray *)crossFadingViews
{
    return self.marqueeCaptionViews;
}

- (CGFloat)visibilitySpan
{
    return 0.8f;
}

@end
