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
#import "VStreamWebViewController.h"
#import "VSequence+Fetcher.h"
#import "UIView+AutoLayout.h"
#import "VStreamItemPreviewView.h"

@interface VAbstractMarqueeStreamItemCell () <VSharedCollectionReusableViewMethods>

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
    self.dimmingView = [UIView new];
    self.dimmingView.backgroundColor = [UIColor blackColor];
    self.dimmingView.alpha = 0;
    self.dimmingView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.previewContainer addSubview:self.dimmingView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.dimmingView];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
}

- (void)setHighlighted:(BOOL)highlighted
{
    // Determine if this cell shows its highlighted state
    BOOL showsHighlight = [[self.dependencyManager numberForKey:kStreamCellShowsHighlightedStateKey] boolValue];
    if (showsHighlight)
    {
        [UIView animateWithDuration:0.1 animations:^
         {
             self.dimmingView.alpha = highlighted ? 0.6f : 0;
         }];
    }
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    [self updatePreviewViewForStreamItem:streamItem];
}

- (void)updatePreviewViewForStreamItem:(VStreamItem *)streamItem
{
    if ( streamItem == nil )
    {
        return;
    }
    
    if ( [self.previewView canHandleStreamItem:streamItem] )
    {
        if ( ![streamItem isEqual:self.previewView.streamItem] )
        {
            [self.previewView setStreamItem:streamItem];
        }
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VStreamItemPreviewView streamItemPreviewViewWithStreamItem:streamItem];
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingView];
    [self.previewContainer v_addFitToParentConstraintsToSubview:self.previewView];
    if ([self.previewView respondsToSelector:@selector(setDependencyManager:)])
    {
        [self.previewView setDependencyManager:self.dependencyManager];
    }
    [self.previewView setStreamItem:streamItem];
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                          baseIdentifier:(NSString *)baseIdentifier
{
    NSString *identifier = baseIdentifier == nil ? [[NSMutableString alloc] init] : [baseIdentifier copy];
    identifier = [NSString stringWithFormat:@"%@.%@", identifier, NSStringFromClass(self)];
    identifier = [VStreamItemPreviewView reuseIdentifierForStreamItem:streamItem
                                                       baseIdentifier:identifier];
    return identifier;
}

@end
