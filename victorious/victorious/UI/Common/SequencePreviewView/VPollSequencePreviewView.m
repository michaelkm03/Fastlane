//
//  VPollSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VPollSequencePreviewView.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"
#import "VAnswer+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VImageAssetFinder+PollAssets.h"
#import "VPollView.h"
#import "UIView+AutoLayout.h"
#import "VImageAssetFinder.h"
#import "VResultView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "NSURL+MediaType.h"

static NSString *kOrIconKey = @"orIcon";

@interface VPollSequencePreviewView ()

@property (nonatomic, strong) VPollView *pollView;
@property (nonatomic, strong) UILabel *voterCountLabel;
@property (nonatomic, strong) UIView *voterCountLabelContainer;
@property (nonatomic, strong) NSLayoutConstraint *voterCountLabelWidth;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizerA;
@property (nonatomic, strong) UITapGestureRecognizer *gestureRecognizerB;
@property (nonatomic, strong) VImageAssetFinder *assetFinder;
@property (nonatomic, readonly) VAnswer *answerA;
@property (nonatomic, readonly) VAnswer *answerB;
@property (nonatomic, strong) VResultView *answerAResultView;
@property (nonatomic, strong) VResultView *answerBResultView;
@property (nonatomic, readonly) UIColor *favoredColor;
@property (nonatomic, readonly) UIColor *unfavoredColor;
@property (nonatomic, assign) BOOL haveResultsBeenSet;

@end

@implementation VPollSequencePreviewView

#pragma mark - VHasManagedDependencies

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        self.clipsToBounds = YES;
        
        _pollView = [[VPollView alloc] initWithFrame:CGRectZero];
        [self addSubview:_pollView];
        [self v_addFitToParentConstraintsToSubview:_pollView];
        
        // Add gesture recognizers to show full size asse when previews are tapped
        _gestureRecognizerA = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(answerASelected:)];
        [_pollView.answerAImageView addGestureRecognizer:_gestureRecognizerA];
        _gestureRecognizerB = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(answerBSelected:)];
        [_pollView.answerBImageView addGestureRecognizer:_gestureRecognizerB];
        
        _assetFinder = [[VImageAssetFinder alloc] init];
        
        CGRect labelFrame = CGRectMake( 0, 0, 120.0f, 30.0f );
        _voterCountLabelContainer = [[UIView alloc] initWithFrame:labelFrame];
        _voterCountLabelContainer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];
        [self addSubview:_voterCountLabelContainer];
        [_voterCountLabelContainer v_addHeightConstraint:labelFrame.size.height];
        _voterCountLabelWidth = [_voterCountLabelContainer v_addWidthConstraint:labelFrame.size.height];
        [self v_addPinToTopToSubview:_voterCountLabelContainer topMargin:12.0f];
        [self v_addCenterHorizontallyConstraintsToSubview:_voterCountLabelContainer];
        _voterCountLabelContainer.layer.cornerRadius = CGRectGetHeight(_voterCountLabelContainer.bounds) * 0.5f;
        _voterCountLabelContainer.alpha = 0.0f;
        
        _voterCountLabel = [[UILabel alloc] initWithFrame:labelFrame];
        _voterCountLabel.userInteractionEnabled = NO;
        _voterCountLabel.textColor = [UIColor whiteColor];
        _voterCountLabel.textAlignment = NSTextAlignmentCenter;
        [_voterCountLabelContainer addSubview:_voterCountLabel];
        [_voterCountLabelContainer v_addFitToParentConstraintsToSubview:_voterCountLabel];
    }
    return self;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    self.pollView.pollIcon = [dependencyManager imageForKey:kOrIconKey];
    self.voterCountLabel.font = [dependencyManager fontForKey:VDependencyManagerLabel1FontKey];
    
    [self setupResultViews];
}

#pragma mark - VSequencePreviewView Overrides

- (void)setSequence:(VSequence *)sequence
{
    [super setSequence:sequence];
    
    __weak typeof(self) weakSelf = self;
    [self.pollView.answerAImageView sd_setImageWithURL:self.answerA.previewMediaURL
                                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        __weak typeof(self) weakSelf = strongSelf;
        
        [strongSelf.pollView.answerBImageView sd_setImageWithURL:strongSelf.answerB.previewMediaURL
                                                       completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             __strong typeof(weakSelf) strongSelf = weakSelf;
             strongSelf.readyForDisplay = YES;
         }];
    }];
    
    self.pollView.playIconA.hidden = ![self.answerA.mediaUrl v_hasVideoExtension];
    self.pollView.playIconB.hidden = ![self.answerB.mediaUrl v_hasVideoExtension];
}

- (VAnswer *)answerA
{
    return [self.assetFinder answerAFromAssets:self.sequence.previewImageAssets] ?: [self.sequence.firstNode answerA];
}

- (VAnswer *)answerB
{
    return [self.assetFinder answerBFromAssets:self.sequence.previewImageAssets] ?: [self.sequence.firstNode answerB];
}

#pragma mark - Target/Action

- (void)answerASelected:(id)sender
{
    NSURL *mediaURL = [NSURL URLWithString:self.answerA.mediaUrl];
    
    NSDictionary *params = @{ VTrackingKeyIndex : @0,
                              VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
    
    [self.detailDelegate previewView:self
                   didSelectMediaURL:mediaURL
                        previewImage:self.pollView.answerAImageView.image
                             isVideo:[mediaURL v_hasVideoExtension]
                          sourceView:self.pollView.answerAImageView];
}

- (void)answerBSelected:(id)sender
{
    NSURL *mediaURL = [NSURL URLWithString:self.answerB.mediaUrl];
    
    NSDictionary *params = @{ VTrackingKeyIndex : @1,
                              VTrackingKeyMediaType : [mediaURL pathExtension] ?: @"" };
    [[VTrackingManager sharedInstance] trackEvent:VTrackingEventUserDidSelectPollMedia parameters:params];
    
    [self.detailDelegate previewView:self
                   didSelectMediaURL:mediaURL
                        previewImage:self.pollView.answerBImageView.image
                             isVideo:[mediaURL v_hasVideoExtension]
                          sourceView:self.pollView.answerBImageView];
}

- (void)setGestureRecognizersEnabled:(BOOL)enabled
{
    _gestureRecognizerA.enabled = enabled;
    _gestureRecognizerB.enabled = enabled;
    _pollView.answerAImageView.userInteractionEnabled = enabled;
    _pollView.answerBImageView.userInteractionEnabled = enabled;
}

- (UIColor *)favoredColor
{
    return [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
}

- (UIColor *)unfavoredColor
{
    return [self.dependencyManager colorForKey:VDependencyManagerAccentColorKey];
}

- (void)setupResultViews
{
    if ( self.answerAResultView != nil && self.answerBResultView != nil )
    {
        return;
    }
    
    NSDictionary *metrics = @{ @"width" : @(36.0f), @"top" : @(90.0f), @"priority" : @(UILayoutPriorityDefaultHigh) };
    
    self.answerAResultView = [[VResultView alloc] initWithFrame:self.pollView.bounds];
    self.answerBResultView = [[VResultView alloc] initWithFrame:self.pollView.bounds];
    NSDictionary *viewsA = @{ @"view" : self.answerAResultView };
    self.answerAResultView.color = self.unfavoredColor;
    [self.pollView addSubview:self.answerAResultView];
    self.answerAResultView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top@priority-[view]|"
                                                                          options:kNilOptions
                                                                          metrics:metrics
                                                                            views:viewsA]];
    [self.pollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view(width@priority)]"
                                                                          options:kNilOptions
                                                                          metrics:metrics
                                                                            views:viewsA]];
    
    self.answerBResultView = [[VResultView alloc] initWithFrame:self.pollView.bounds];
    NSDictionary *viewsB = @{ @"view" : self.answerBResultView };
    self.answerBResultView.color = self.unfavoredColor;
    [self.pollView addSubview:self.answerBResultView];
    self.answerBResultView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.pollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top@priority-[view]|"
                                                                          options:kNilOptions
                                                                          metrics:metrics
                                                                            views:viewsB]];
    [self.pollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[view(width@priority)]|"
                                                                          options:kNilOptions
                                                                          metrics:metrics
                                                                            views:viewsB]];
    
    [self.pollView layoutIfNeeded];
    
    [self setResultViewsHidden:YES animated:NO];
}

- (void)setResultViewsHidden:(BOOL)hidden animated:(BOOL)animated
{
    for ( VResultView *view in @[ self.answerBResultView, self.answerAResultView ] )
    {
        [self setResultView:view hidden:hidden animated:animated];
    }
}

- (void)setResultView:(VResultView *)view hidden:(BOOL)hidden animated:(BOOL)animated
{
    void (^animations)() = ^
    {
        view.alpha = hidden ? 0.0f : 1.0f;
    };
    void (^completion)(BOOL) = ^(BOOL finished)
    {
        if ( hidden )
        {
            [view setProgress:0.0f animated:NO];
        }
    };
    if ( animated )
    {
        [UIView animateWithDuration:0.3f animations:animations];
    }
    else
    {
        animations();
        completion(YES);
    }
}

#pragma mark - VPollResultReceiver

- (void)showResults
{
    [self setResultViewsHidden:NO animated:self.haveResultsBeenSet];
    self.haveResultsBeenSet = YES;
}

- (void)setVoterCountText:(NSString *)text
{
    if ( text.length > 0 )
    {
        self.voterCountLabel.text = text;
        self.voterCountLabelWidth.active = NO;
        [self.voterCountLabel sizeToFit];
        self.voterCountLabelWidth.constant = CGRectGetWidth(self.voterCountLabel.frame) + 20.0f;
        self.voterCountLabelWidth.active = YES;
        [UIView animateWithDuration:0.5f
                              delay:0.0f
             usingSpringWithDamping:1.0f
              initialSpringVelocity:0
                            options:kNilOptions
                         animations:^
         {
             self.voterCountLabelContainer.alpha = 1.0f;
         }
                         completion:nil];
    }
}

- (void)setAnswerAPercentage:(CGFloat)answerAPercentage animated:(BOOL)animated
{
    [self.answerAResultView setProgress:answerAPercentage animated:animated];
}

- (void)setAnswerBPercentage:(CGFloat)answerBPercentage animated:(BOOL)animated
{
    [self.answerBResultView setProgress:answerBPercentage animated:animated];
}

- (void)setAnswerAIsFavored:(BOOL)answerAIsFavored
{
    [self.answerAResultView setColor:answerAIsFavored ? self.favoredColor : self.unfavoredColor];
}

- (void)setAnswerBIsFavored:(BOOL)answerBIsFavored
{
    [self.answerBResultView setColor:answerBIsFavored ? self.favoredColor : self.unfavoredColor];
}

#pragma mark - Focus

- (void)setFocusType:(VFocusType)focusType
{
    if ( super.focusType == focusType)
    {
        return;
    }
    
    super.focusType = focusType;
    
    switch ( self.focusType )
    {
        case VFocusTypeDetail:
            [self.pollView setPollIconHidden:YES animated:YES];
            [self setGestureRecognizersEnabled:YES];
            if ( self.haveResultsBeenSet )
            {
                [self setResultViewsHidden:NO animated:YES];
            }
            break;
        default:
            [self.pollView setPollIconHidden:NO animated:YES];
            [self setGestureRecognizersEnabled:NO];
            [self setResultViewsHidden:YES animated:YES];
            self.voterCountLabelContainer.alpha = 0.0f;
    }
}

@end
