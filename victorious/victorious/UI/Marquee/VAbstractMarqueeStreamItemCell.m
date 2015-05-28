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

@interface VAbstractMarqueeStreamItemCell () <VSharedCollectionReusableViewMethods, VStreamCellComponentSpecialization>

@property (nonatomic, strong) VStreamItemPreviewView *previewView;

@end

@implementation VAbstractMarqueeStreamItemCell

+ (CGSize)desiredSizeWithCollectionViewBounds:(CGRect)bounds
{
    NSAssert(false, @"desiredSizeWithCollectionViewBounds: must be overridden by subclasses of VAbstractMarqueeStreamItemCell");
    return CGSizeZero;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    if ( streamItem != nil )
    {
        [self updatePreviewViewForStreamItem:streamItem];
    }
    self.previewView.hidden = streamItem == nil;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.streamItem = nil;
}

#pragma mark - VPreviewView updating

- (void)updatePreviewViewForStreamItem:(VStreamItem *)streamItem
{
    if ( [self.previewView canHandleStreamItem:streamItem] )
    {
        [self.previewView setStreamItem:streamItem];
        return;
    }
    
    [self.previewView removeFromSuperview];
    self.previewView = [VStreamItemPreviewView streamItemPreviewViewWithStreamItem:streamItem];
    [self.previewContainer addSubview:self.previewView];
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
