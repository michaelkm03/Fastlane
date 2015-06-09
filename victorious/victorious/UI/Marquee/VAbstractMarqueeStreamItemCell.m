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
    
    [UIView animateWithDuration:kHighlightTimeInterval animations:^
     {
         self.dimmingContainer.alpha = highlighted ? kHighlightViewAlpha : 0;
     }];
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
    [self.previewContainer insertSubview:self.previewView belowSubview:self.dimmingContainer];
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

#pragma mark - VHighlightContainer

- (UIView *)highlightContainerView
{
    return self.dimmingContainer;
}

@end
