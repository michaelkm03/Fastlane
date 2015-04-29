//
//  VCommandHandler.m
//  victorious
//
//  Created by Michael Sena on 4/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommandHandler.h"

@interface VCommandHandler ()

@property (nonatomic, weak) UIResponder *internalNextResponder;

@end

@implementation VCommandHandler

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
