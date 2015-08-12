//
//  VSequencePreviewView.m
//  victorious
//
//  Created by Michael Sena on 5/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VSequencePreviewView.h"

// Models + Helpers
#import "VSequence+Fetcher.h"
#import "VStreamItem.h"

// Subclasses
#import "VTextSequencePreviewView.h"
#import "VPollSequencePreviewView.h"
#import "VImageSequencePreviewView.h"
#import "VHTMLSequncePreviewView.h"
#import "VFailureSequencePreviewView.h"
#import "VGIFVideoSequencePreviewView.h"
#import "VVideoSequencePreviewView.h"

@implementation VSequencePreviewView

+ (Class)classTypeForSequence:(VSequence *)sequence
{
    Class classType = nil;
    if ([sequence isText])
    {
        classType = [VTextSequencePreviewView class];
    }
    else if ([sequence isPoll])
    {
        classType = [VPollSequencePreviewView class];
    }
    else if ([sequence isVideo])
    {
        if (sequence.isGifStyle.boolValue)
        {
            classType = [VGIFVideoSequencePreviewView class];
        }
        else
        {
            classType = [VVideoSequencePreviewView class];
        }
    }
    else if ([sequence isImage] || [sequence isPreviewImageContent])
    {
        classType = [VImageSequencePreviewView class];
    }
    else if ([sequence isWebContent])
    {
        classType = [VHTMLSequncePreviewView class];
    }
    else
    {
        classType = [VFailureSequencePreviewView class];
    }
    
    return classType;
}

+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence
{
    return [[[self classTypeForSequence:sequence] alloc] initWithFrame:CGRectZero];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    if ( [streamItem isKindOfClass:[VSequence class]] )
    {
        [self setSequence:(VSequence *)streamItem];
    }
    else
    {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *errorString = [NSString stringWithFormat:@"VSequencePreviewView cannot handle streamItem of class %@!", NSStringFromClass([streamItem class])];
        NSAssert(false, errorString);
#endif
    }
}

- (void)setSequence:(VSequence *)sequence
{
    [super setStreamItem:sequence];
}

- (BOOL)canHandleSequence:(VSequence *)sequence
{
    if ([self class] == [[self class] classTypeForSequence:sequence])
    {
        return YES;
    }
    return NO;
}

+ (NSString *)reuseIdentifierForSequence:(VSequence *)sequence
                          baseIdentifier:(NSString *)baseIdentifier
                       dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self reuseIdentifierForStreamItem:sequence baseIdentifier:baseIdentifier dependencyManager:dependencyManager];
}

@end
