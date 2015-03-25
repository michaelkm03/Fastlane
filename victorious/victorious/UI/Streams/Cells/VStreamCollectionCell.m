//
//  VStreamCollectionCell.m
//  victorious
//
//  Created by Will Long on 10/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamCollectionCell.h"

#import "VStreamCellHeaderView.h"
#import "VSequence.h"
#import "VObjectManager+Sequence.h"
#import "NSDate+timeSince.h"
#import "VUser.h"

#import "VUserProfileViewController.h"

#import "VSequence+Fetcher.h"
#import "VNode+Fetcher.h"
#import "VAsset.h"

#import "UIImage+ImageCreation.h"

#import "VConstants.h"

#import "VCommentCell.h"
#import "VStreamCellActionView.h"
#import "VSleekStreamCellActionView.h"

#import "UIImageView+VLoadingAnimations.h"
#import "NSString+VParseHelp.h"

#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"
#import "UIView+Autolayout.h"
#import "VVideoView.h"

@interface VStreamCollectionCell() <VSequenceActionsDelegate, CCHLinkTextViewDelegate, VVideoViewDelegtae>

@property (nonatomic, weak) IBOutlet UIImageView *playImageView;
@property (nonatomic, weak) IBOutlet UIImageView *playBackgroundImageView;

@property (nonatomic, weak) IBOutlet UIImageView *bottomGradient;

@property (nonatomic, weak) IBOutlet VVideoView *videoPlayerView;
@property (nonatomic, weak) IBOutlet UIView *contentContainer;

@property (nonatomic, strong) VAsset *videoAsset;
@property (nonatomic, assign) BOOL isPlayButtonVisible;

@property (nonatomic, readonly) BOOL canPlayVideo;

@end

const CGFloat VStreamCollectionCellTextViewLineFragmentPadding = 0.0f;

@implementation VStreamCollectionCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.streamCellHeaderView = [[[NSBundle mainBundle] loadNibNamed:self.headerViewNibName owner:self options:nil] objectAtIndex:0];

    [self.streamCellHeaderView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.streamCellHeaderView setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self addSubview:self.streamCellHeaderView];
    NSDictionary *views = @{ @"header": self.streamCellHeaderView };
    CGFloat height = CGRectGetHeight(self.streamCellHeaderView.bounds);
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[header]|"
                                                                 options:0
                                                                 metrics:nil
                                                                   views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[header(height)]"
                                                                 options:0
                                                                 metrics:@{ @"height":@(height) }
                                                                   views:views]];
    self.captionTextView.textContainer.lineFragmentPadding = VStreamCollectionCellTextViewLineFragmentPadding;
    self.captionTextView.textContainerInset = UIEdgeInsetsZero;
    self.streamCellHeaderView.delegate = self;
}

- (NSString *)headerViewNibName
{
    return @"VStreamCellHeaderView";
}

- (void)setSequenceActionsDelegate:(id<VSequenceActionsDelegate>)sequenceActionsDelegate
{
    _sequenceActionsDelegate = sequenceActionsDelegate;
    self.streamCellHeaderView.delegate = sequenceActionsDelegate;
}

- (void)setDescriptionText:(NSString *)text
{
    BOOL hasText = !self.sequence.nameEmbeddedInContent.boolValue;
    if ( hasText )
    {
        NSMutableAttributedString *newAttributedCellText = [[NSMutableAttributedString alloc] initWithString:(text ?: @"")
                                                                                                  attributes:[[self class] sequenceDescriptionAttributesWithDependencyManager:self.dependencyManager]];
        self.captionTextView.linkDelegate = self;
        self.captionTextView.textContainer.maximumNumberOfLines = [self maxCaptionLines];
        self.captionTextView.textContainer.lineBreakMode = NSLineBreakByTruncatingTail;
        self.captionTextView.attributedText = newAttributedCellText;
    }
    else
    {
        self.captionTextView.attributedText = [[NSAttributedString alloc] initWithString:@""];
    }
}

//Subclass this to allow for more lines in caption, 0 for infinite lines
- (NSUInteger)maxCaptionLines
{
    return 3;
}

- (void)reloadCommentsCount
{
    [self.streamCellHeaderView reloadCommentsCount];
}

- (void)refreshDescriptionAttributes
{
    [self setDescriptionText:self.captionTextView.text];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    [self pauseVideo];
    self.videoPlayerView.alpha = 0.0f;
    self.videoAsset = nil;
}

- (CGRect)mediaContentFrame
{
    return self.contentContainer.frame;
}

- (void)setSequence:(VSequence *)sequence
{
    _sequence = sequence;
    
    [self.streamCellHeaderView setSequence:self.sequence];
    [self.streamCellHeaderView setParentViewController:self.parentViewController];

    NSURL *imageUrl;
    if ([sequence isImage])
    {
        imageUrl = [NSURL URLWithString:[self.sequence.firstNode imageAsset].data];
    }
    else
    {
        imageUrl = [NSURL URLWithString:self.sequence.previewImagesObject];
    }
    [self.previewImageView fadeInImageAtURL:imageUrl
                           placeholderImage:nil];
    
    [self setDescriptionText:self.sequence.name];
    
    self.captionTextView.hidden = self.sequence.nameEmbeddedInContent.boolValue || self.sequence.name.length == 0;
        
    self.bottomGradient.hidden = (sequence.nameEmbeddedInContent != nil) ? [sequence.nameEmbeddedInContent boolValue] : NO;
    
    if ( [sequence isVideo] )
    {
        VAsset *asset = [self.sequence.firstNode mp4Asset];
        if ( asset.streamAutoplay.boolValue )
        {
            self.videoAsset = asset;
            self.isPlayButtonVisible = NO;
            [self.videoPlayerView setItemURL:[NSURL URLWithString:self.videoAsset.data]
                                        loop:self.videoAsset.loop.boolValue
                                  audioMuted:self.videoAsset.audioMuted.boolValue];
        }
        else
        {
            self.isPlayButtonVisible = YES;
        }
    }
    else
    {
        self.isPlayButtonVisible = NO;
    }
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    [super setDependencyManager:dependencyManager];
    
    if ( dependencyManager != nil )
    {
        self.streamCellHeaderView.dependencyManager = dependencyManager;
        
        self.contentView.backgroundColor = [dependencyManager colorForKey:VDependencyManagerSecondaryBackgroundColorKey];
        self.commentsLabel.font = [[VStreamCollectionCell sequenceCommentCountAttributesWithDependencyManager:dependencyManager] objectForKey:NSFontAttributeName];
        [self refreshDescriptionAttributes];
    }
}

- (BOOL)canPlayVideo
{
    return self.videoAsset != nil;
}

- (void)playVideo
{
    if ( self.canPlayVideo )
    {
        [self.videoPlayerView play];
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^void
         {
             self.videoPlayerView.alpha = 1.0f;
         }
                         completion:nil];
    }
}

- (void)pauseVideo
{
    if ( self.canPlayVideo  )
    {
        [UIView animateWithDuration:0.2f
                              delay:0.0f
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^void
         {
             self.videoPlayerView.alpha = 0.0f;
         }
                         completion:^(BOOL finished)
         {
             [self.videoPlayerView pause];
         }];
    }
}

- (void)setIsPlayButtonVisible:(BOOL)isPlayButtonVisible
{
    _isPlayButtonVisible = isPlayButtonVisible;
    self.playImageView.hidden = self.playBackgroundImageView.hidden = !isPlayButtonVisible;
}

- (void)setHeight:(CGFloat)height
{
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
}

- (BOOL)remixRepostCheck:(NSString *)sequenceCategory
{
    if ([sequenceCategory rangeOfString:@"remix"].location == NSNotFound && [sequenceCategory rangeOfString:@"repost"].location == NSNotFound)
    {
        return NO;
    }
    return YES;
}

- (void)hideOverlays
{
    self.overlayView.alpha = 0;
    self.shadeView.alpha = 0;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y - self.frame.size.height);
}

- (void)showOverlays
{
    self.overlayView.alpha = 1;
    self.shadeView.alpha = 1;
    self.overlayView.center = CGPointMake(self.center.x, self.center.y);
}

#pragma mark - VSequenceActionsDelegate

- (void)willCommentOnSequence:(VSequence *)sequence fromView:(UIView *)view
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(willCommentOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate willCommentOnSequence:self.sequence fromView:self];
    }
}

- (void)selectedUserOnSequence:(VSequence *)sequence fromView:(UIView *)view
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(selectedUserOnSequence:fromView:)])
    {
        [self.sequenceActionsDelegate selectedUserOnSequence:self.sequence fromView:self];
    }
}

#pragma mark - VSharedCollectionReusableViewMethods

+ (NSString *)suggestedReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (UINib *)nibForCell
{
    return [UINib nibWithNibName:[self suggestedReuseIdentifier]
                          bundle:nil];
}

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    CGFloat width = CGRectGetWidth(bounds);
    return CGSizeMake(width, width);
}

+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds sequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self desiredSizeWithCollectionViewBounds:bounds];
}

+ (NSDictionary *)sequenceCommentCountAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    return @{ NSFontAttributeName : [dependencyManager fontForKey:VDependencyManagerLabel3FontKey] };
}

+ (NSDictionary *)sequenceDescriptionAttributesWithDependencyManager:(VDependencyManager *)dependencyManager
{
    NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    
    attributes[ NSForegroundColorAttributeName ] = [dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    attributes[ NSFontAttributeName ] = [[dependencyManager fontForKey:VDependencyManagerHeading2FontKey] fontWithSize:19];
    
    paragraphStyle.maximumLineHeight = 25;
    paragraphStyle.minimumLineHeight = 25;
    
    NSShadow *shadow = [NSShadow new];
    [shadow setShadowBlurRadius:4.0f];
    [shadow setShadowColor:[[UIColor blackColor] colorWithAlphaComponent:0.3f]];
    [shadow setShadowOffset:CGSizeMake(0, 0)];
    attributes[NSShadowAttributeName] = shadow;
    
    attributes[ NSParagraphStyleAttributeName ] = paragraphStyle;
    
    return [NSDictionary dictionaryWithDictionary:attributes];
}

#pragma mark - CCHLinkTextViewDelegate

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    if ([self.sequenceActionsDelegate respondsToSelector:@selector(hashTag:tappedFromSequence:fromView:)])
    {
        [self.sequenceActionsDelegate hashTag:value
                           tappedFromSequence:self.sequence
                                     fromView:self];
    }
}

#pragma mark - VVideoViewDelegate

- (void)videoViewPlayerDidBecomeReady:(VVideoView *)videoView
{
    [self playVideo];
}

@end
