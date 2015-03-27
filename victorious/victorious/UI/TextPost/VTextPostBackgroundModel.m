//
//  VTextPostBackgroundModel.m
//  victorious
//
//  Created by Patrick Lynch on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostBackgroundModel.h"

@implementation VTextPostBackgroundModel

- (instancetype)initWithLineCount:(NSUInteger)lineCount
{
    self = [super init];
    if (self)
    {
        _lineCount = lineCount;
    }
    return self;
}

- (NSArray *)framesForLineAtIndex:(NSUInteger)lineIndex
{
    return nil;
}

- (void)setFrames:(NSArray *)frames forLineAtIndex:(NSUInteger)lineIndex
{
    
}

- (void)addFrame:(CGRect)frame toLineAtIndex:(NSUInteger)lineIndex
{
    
}

@end
