//
//  VCommandHandler.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VResponder.h"

@interface VResponder ()

@property (nonatomic, weak) UIResponder *internalNextResponder;

@end

@implementation VResponder

#pragma mark - Init

- (instancetype)initWithNextResponder:(UIResponder *)nextResponder
{
    NSParameterAssert(nextResponder != nil);
    
    self = [super init];
    if (self != nil)
    {
        _internalNextResponder = nextResponder;
    }
    return self;
}

#pragma mark - UIResponder

- (UIResponder *)nextResponder
{
    return self.internalNextResponder;
}

@end
