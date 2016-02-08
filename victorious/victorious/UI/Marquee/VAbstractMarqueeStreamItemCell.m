//
//  VAbstractMarqueeStreamItemCell.m
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractMarqueeStreamItemCell.h"
#import "VSharedCollectionReusableViewMethods.h"
#import "VDependencyManager.h"
#import "VDependencyManager+VHighlightContainer.h"
#import "VStreamWebViewController.h"
#import "VSequence+Fetcher.h"
#import "UIView+AutoLayout.h"
#import "VStreamItemPreviewView.h"
#import "UIResponder+VResponderChain.h"
#import "victorious-Swift.h"
#import "VTextSequencePreviewView.h"
#import "VTextStreamPreviewView.h"

@interface VAbstractMarqueeStreamItemCell () <VSharedCollectionReusableViewMethods, VideoTracking, VContentPreviewViewProvider>

@end

@implementation VAbstractMarqueeStreamItemCell

@synthesize hasRelinquishedPreviewView = _hasRelinquishedPreviewView;

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"desiredSizeWithCollectionViewBounds: must be overridden by subclasses of VAbstractMarqueeStreamItemCell");
    return CGSizeZero;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // Dimming view
    self.dimmingContainer = [UIView new];
    self.dimmingContainer.alpha = 0;
    self.dimmingContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewContainer addSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.dimmingContainer];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    [self.dependencyManager setHighlighted:highlighted onHost:self];
}

- (void)setupWithStreamItem:(VStreamItem *)streamItem fromStreamWithStreamID:(NSString *)streamID
{
    self.streamItem = streamItem;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    [self updatePreviewViewForStreamItem:streamItem];
}

- (BOOL)shouldSupportAutoplay
{
    return YES;
}

- (void)updatePreviewViewForStreamItem:(VStreamItem *)streamItem
{
    if ( self.hasRelinquishedPreviewView )
    {
        return;
    }
    
    if ([self.previewView canHandleStreamItem:streamItem])
    {
        [self.previewView setStreamItem:streamItem];
        if ( self.previewView.superview == self.previewContainer )
        {
            //The preview view has the right sequence and is already present in our UI
            if ( [self.previewView conformsToProtocol:@protocol(VContentFittingPreviewView)] )
            {
                [(id<VContentFittingPreviewView>)self.previewView updateToFitContent:NO];
            }
            return;
        }
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VStreamItemPreviewView streamItemPreviewViewWithStreamItem:streamItem];
    self.previewView.streamBackgroundColor = [UIColor blackColor];
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    [self.previewView setDependencyManager:self.dependencyManager];
    BOOL isTextContent = [self.previewView isKindOfClass:[VTextSequencePreviewView class]] || [self.previewView isKindOfClass:[VTextStreamPreviewView class]];
    self.previewView.onlyShowPreview = isTextContent && self.onlyShowPreviewForTextPosts;
    self.previewView.displaySize = self.bounds.size;
    
    // Turn off autoplay for explore marquee shelf
    if ([self.previewView isKindOfClass:[VBaseVideoSequencePreviewView class]])
    {
        ((VBaseVideoSequencePreviewView *)self.previewView).onlyShowPreview = !self.shouldSupportAutoplay;
    }
    
    [self.previewView updateToStreamItem:streamItem];
    
    if ( [self.previewView conformsToProtocol:@protocol(VRenderablePreviewView)] )
    {
        id<VRenderablePreviewView> renderablePreviewView = (id<VRenderablePreviewView>)self.previewView;
        [renderablePreviewView setRenderingSize:CGSizeMake( CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds) )];
    }
    if ( [self.previewView conformsToProtocol:@protocol(VContentFittingPreviewView)] )
    {
        [(id<VContentFittingPreviewView>)self.previewView updateToFitContent:NO];
    }
    
    [self.previewView setStreamItem:streamItem];
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    NSString *identifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier copy];
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    identifier = [VStreamItemPreviewView reuseIdentifierForStreamItem:streamItem
                                                       baseIdentifier:identifier
                                                    dependencyManager:dependencyManager];
    return identifier;
}

#pragma mark - VHighlightContainer

- (UIView *)highlightContainerView
{
    return self.dimmingContainer;
}

- (UIView *)highlightActionView
{
    return self.dimmingContainer;
}

#pragma mark - Tracking

- (VSequence *)sequenceToTrack
{
    if ([self.streamItem isKindOfClass:[VSequence class]])
    {
        return (VSequence *)self.streamItem;
    }
    
    return nil;
}

#pragma mark - Autoplay tracking

- (void)trackAutoplayEvent:(VideoTrackingEvent *__nonnull)event
{
    // Set context and continue walking up responder chain
    event.context = self.context;
    event.autoPlay = YES;
    
    id<VideoTracking>responder = [self.nextResponder v_targetConformingToProtocol:@protocol(VideoTracking)];
    if ( responder != nil )
    {
        [responder trackAutoplayEvent:event];
    }
    else
    {
        [event track];
    }
}

- (NSDictionary *__nonnull)additionalInfo
{
    return [self.previewView trackingInfo] ?: @{};
}

#pragma mark - VContentPreviewViewProvider

- (void)setHasRelinquishedPreviewView:(BOOL)hasReliquishedPreviewView
{
    _hasRelinquishedPreviewView = hasReliquishedPreviewView;
    if ( !hasReliquishedPreviewView )
    {
        [self updatePreviewViewForStreamItem:self.streamItem];
    }
}

- (UIView *)getPreviewView
{
    return self.previewView;
}

- (UIView *)getContainerView
{
    return self.contentView;
}

- (void)restorePreviewView:(VSequencePreviewView *)previewView
{
    self.hasRelinquishedPreviewView = NO;
    self.previewView = previewView;
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
}

@end
