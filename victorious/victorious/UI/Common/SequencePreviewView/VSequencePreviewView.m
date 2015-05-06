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

// Subclasses
#import "VTextSequencePreviewView.h"
#import "VPollSequencePreviewView.h"
#import "VImageSequencePreviewView.h"
#import "VVideoSequencePreviewView.h"
#import "VHTMLSequncePreviewView.h"

@implementation VSequencePreviewView

+ (NSArray *)reuseIdentifiers
{
    return @[NSStringFromClass([VTextSequencePreviewView class]),
             NSStringFromClass([VPollSequencePreviewView class]),
             NSStringFromClass([VVideoSequencePreviewView class]),
             NSStringFromClass([VImageSequencePreviewView class]),
             NSStringFromClass([VHTMLSequncePreviewView class])];
}

+ (VSequencePreviewView *)sequencePreviewViewWithSequence:(VSequence *)sequence
{
    VSequencePreviewView *previewView;
    if ([sequence isText])
    {
        previewView = [[VTextSequencePreviewView alloc] initWithFrame:CGRectZero];
    }
    else if ([sequence isPoll])
    {
        previewView = [[VPollSequencePreviewView alloc] initWithFrame:CGRectZero];
    }
    else if ([sequence isVideo])
    {
        previewView = [[VVideoSequencePreviewView alloc] initWithFrame:CGRectZero];
    }
    else if ([sequence isImage])
    {
        previewView = [[VImageSequencePreviewView alloc] initWithFrame:CGRectZero];
    }
    else if ([sequence isWebContent])
    {
        previewView = [[VHTMLSequncePreviewView alloc] initWithFrame:CGRectZero];
    }
    else
    {
        NSAssert(@"Unable to handle sequence!", @"");
    }
    
    return previewView;
}

- (void)setSequence:(VSequence *)sequence
{
    NSAssert(false, @"Override in subclasses!");
}

@end
