//
//  UIResponder+VResponderChain.m
//  victorious
//
//  Created by Patrick Lynch on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "UIResponder+VResponderChain.h"

@implementation UIResponder (VResponderChain)

- (void)v_walkWithBlock:(void(^)(UIResponder *responder, BOOL *stop))block
{
    NSParameterAssert( block != nil );
    
    UIResponder *responder = self;
    BOOL shouldStop = NO;
    do
    {
        block( responder, &shouldStop );
        if ( shouldStop )
        {
            return;
        }
        responder = [responder nextResponder];
    }
    while ( responder != nil );
}

@end
