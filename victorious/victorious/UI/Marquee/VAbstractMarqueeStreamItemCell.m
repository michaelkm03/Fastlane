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

@interface VAbstractMarqueeStreamItemCell () <VSharedCollectionReusableViewMethods, AutoplayTracking, VContentPreviewViewProvider>

@property (nonatomic, assign) BOOL hasReliquishedPreviewView;

@end

@implementation VAbstractMarqueeStreamItemCell

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

- (void)setupWithStreamItem:(VStreamItem *)streamItem fromStreamWithApiPath:(NSString *)apiPath
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
    if ( streamItem == nil || self.hasReliquishedPreviewView )
    {
        return;
    }
    
    if ( [self.previewView canHandleStreamItem:streamItem] )
    {
        [self.previewView updateToStreamItem:streamItem];
        return;
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
    
    id<VPreviewView> previewView = (id<VPreviewView>)self.previewView;
    if ( [previewView respondsToSelector:@selector(setRenderingSize:)] )
    {
        CGRect bounds = self.bounds;
        [previewView setRenderingSize:CGSizeMake( bounds.size.width, bounds.size.width )];
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

- (void)trackAutoplayEvent:(AutoplayTrackingEvent *__nonnull)event
{
    // Set context and continue walking up responder chain
    event.context = self.context;
    
    id<AutoplayTracking>responder = [self.nextResponder v_targetConformingToProtocol:@protocol(AutoplayTracking)];
    if (responder != nil)
    {
        [responder trackAutoplayEvent:event];
    }
}

- (NSDictionary *__nonnull)additionalInfo
{
    return [self.previewView trackingInfo] ?: @{};
}

#pragma mark - VContentPreviewViewProvider

- (void)relinquishPreviewView
{
    self.hasReliquishedPreviewView = YES;
}

- (void)setHasReliquishedPreviewView:(BOOL)hasReliquishedPreviewView
{
    _hasReliquishedPreviewView = hasReliquishedPreviewView;
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
    self.hasReliquishedPreviewView = NO;
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
}

@end
