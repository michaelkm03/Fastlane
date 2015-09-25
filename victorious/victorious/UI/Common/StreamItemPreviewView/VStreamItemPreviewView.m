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

@interface VStreamItemPreviewView ()

@property (nonatomic, strong) UIView *backgroundContainerView;

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

- (void)setStreamItem:(VStreamItem *)streamItem
{
    _streamItem = streamItem;
    self.readyForDisplay = NO;
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

- (void)setDisplayReadyBlock:(VPreviewViewDisplayReadyBlock)displayReadyBlock
{
    _displayReadyBlock = displayReadyBlock;
    if ( self.readyForDisplay && _displayReadyBlock != nil )
    {
        _displayReadyBlock(self);
    }
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self sendSubviewToBack:_backgroundContainerView];
}

- (void)setIsLoading:(BOOL)isLoading
{
    _isLoading = isLoading;
    _backgroundContainerView.alpha = isLoading;
}

- (UIView *)backgroundContainerView
{
    if ( _backgroundContainerView != nil )
    {
        return _backgroundContainerView;
    }
    
    _backgroundContainerView = [[UIView alloc] init];
    _backgroundContainerView.backgroundColor = [UIColor redColor];
    _backgroundContainerView.alpha = 0.0f;
    _backgroundContainerView.userInteractionEnabled = NO;
    [self addSubview:_backgroundContainerView];
    [self v_addFitToParentConstraintsToSubview:_backgroundContainerView];
    return _backgroundContainerView;
}

@end
