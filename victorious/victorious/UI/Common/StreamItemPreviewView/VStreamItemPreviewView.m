//
//  VStreamItemPreviewView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamItemPreviewView.h"
#import "VStreamItem.h"
#import "VSequence.h"
#import "VStream.h"
#import "VSequencePreviewView.h"
#import "VStreamPreviewView.h"
#import "VFailureStreamItemPreviewView.h"
#import "UIView+AutoLayout.h"
#import "VDependencyManager+VBackgroundContainer.h"

@interface VStreamItemPreviewView ()

@end

@implementation VStreamItemPreviewView

+ (Class)classTypeForStreamItem:(VStreamItem *)streamItem
{
    Class classType = nil;
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        return [VSequencePreviewView classTypeForSequence:(VSequence *)streamItem];
    }
    else if ( [streamItem isKindOfClass:[VStream class]] )
    {
        return [VStreamPreviewView classTypeForStream:(VStream *)streamItem];
    }
    else
    {
        classType = [VFailureStreamItemPreviewView class];
    }
    
    return classType;
}

- (void)updateToStreamItem:(VStreamItem *)streamItem
{
    if ( [self isKindOfClass:[VSequencePreviewView class]] && [streamItem isKindOfClass:[VSequence class]] )
    {
        [(VSequencePreviewView *)self setSequence:(VSequence *)streamItem];
    }
    else
    {
        self.streamItem = streamItem;
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if ( self != nil )
    {
        _streamBackgroundColor = [UIColor colorWithWhite:0.97f alpha:1.0f];
        _displaySize = CGSizeZero;
    }
    return self;
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    self.readyForDisplay = NO;
}

- (void)setDependencyManager:(VDependencyManager *)dependencyManager
{
    _dependencyManager = dependencyManager;
    [dependencyManager addBackgroundToBackgroundHost:self];
}

+ (VStreamItemPreviewView *)streamItemPreviewViewWithStreamItem:(VStreamItem *)streamItem
{
    return [[[self classTypeForStreamItem:streamItem] alloc] initWithFrame:CGRectZero];
}

- (BOOL)canHandleStreamItem:(VStreamItem *)streamItem
{
    if ([self class] == [[self class] classTypeForStreamItem:streamItem])
    {
        return YES;
    }
    return NO;
}

- (void)setReadyForDisplay:(BOOL)readyForDisplay
{
    _readyForDisplay = readyForDisplay;
    if ( _readyForDisplay && self.displayReadyBlock != nil )
    {
        self.displayReadyBlock(self);
    }
}

- (void)setDisplayReadyBlock:(VRenderablePreviewViewDisplayReadyBlock)displayReadyBlock
{
    _displayReadyBlock = displayReadyBlock;
    if ( self.readyForDisplay && _displayReadyBlock != nil )
    {
        _displayReadyBlock(self);
    }
}

- (void)setDisplaySize:(CGSize)displaySize
{
    CGFloat greaterSide = MAX(displaySize.height, displaySize.width);
    _displaySize = CGSizeMake(greaterSide, greaterSide);
}

- (NSDictionary *)trackingInfo
{
    // Override in subclass
    return @{};
}

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    return [NSString stringWithFormat:@"%@.%@", baseIdentifier, NSStringFromClass([self classTypeForStreamItem:streamItem])];
}

- (void)setIsLoading:(BOOL)isLoading
{
    [self setIsLoading:isLoading animated:YES];
}

- (void)setIsLoading:(BOOL)isLoading animated:(BOOL)animated
{
    _isLoading = isLoading;
    
    void (^animations)() = ^void
    {
        // Allow the loading background in the cell superview to be seen if loading
        self.alpha = _isLoading ? 0.0f : 1.0f;
    };
    
    if ( animated )
    {
        [UIView animateWithDuration:0.2f animations:animations];
    }
    else
    {
        animations();
    }
}

@end
