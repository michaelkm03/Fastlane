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
        if ( streamItem != nil )
        {
            NSAssert(false, @"Unable to handle stream item!");
        }
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

#pragma mark - VStreamCellComponentSpecialization

+ (NSString *)reuseIdentifierForStreamItem:(VStreamItem *)streamItem
                            baseIdentifier:(NSString *)baseIdentifier
                         dependencyManager:(VDependencyManager *)dependencyManager
{
    return [NSString stringWithFormat:@"%@.%@", baseIdentifier, NSStringFromClass([self classTypeForStreamItem:streamItem])];
}

@end
