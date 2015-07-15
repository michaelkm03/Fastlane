//
//  VStreamPreviewView.m
//  victorious
//
//  Created by Sharif Ahmed on 5/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VStreamPreviewView.h"

#import "VStream.h"

#import "VImageStreamPreviewView.h"
#import "VFailureStreamItemPreviewView.h"

@implementation VStreamPreviewView

+ (Class)classTypeForStream:(VStream *)stream
{
    Class classType = nil;
    if ( [stream previewImagesObject] )
    {
        classType = [VImageStreamPreviewView class];
    }
    else
    {
        NSAssert(@"Unable to handle stream!", @"");
        classType = [VFailureStreamItemPreviewView class];
    }
    
    return classType;
}

+ (VStreamPreviewView *)streamPreviewViewWithStream:(VStream *)stream
{
    return [[[self classTypeForStream:stream] alloc] initWithFrame:CGRectZero];
}

- (void)setStreamItem:(VStreamItem *)streamItem
{
    if ( [streamItem isKindOfClass:[VStream class]] )
    {
        [self setStream:(VStream *)streamItem];
    }
    else
    {
#ifndef NS_BLOCK_ASSERTIONS
        NSString *errorString = [NSString stringWithFormat:@"VStreamPreviewView cannot handle streamItem of class %@!", NSStringFromClass([streamItem class])];
        NSAssert(false, errorString);
#endif
    }
}

- (void)setStream:(VStream *)stream
{
    [super setStreamItem:stream];
}

- (BOOL)canHandleStream:(VStream *)stream
{
    if ([self class] == [[self class] classTypeForStream:stream])
    {
        return YES;
    }
    return NO;
}

+ (NSString *)reuseIdentifierForStream:(VStream *)stream baseIdentifier:(NSString *)baseIdentifier dependencyManager:(VDependencyManager *)dependencyManager
{
    return [self reuseIdentifierForStreamItem:stream baseIdentifier:baseIdentifier dependencyManager:dependencyManager];
}

@end
