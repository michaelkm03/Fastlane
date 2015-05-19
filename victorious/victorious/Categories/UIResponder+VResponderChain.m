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
    }
    while (( responder = [responder nextResponder] ));
}

- (void)v_logResponderChain
{
    __block NSString *output = @"";
    __block NSString *tab = @"";
    [self v_walkWithBlock:^(UIResponder *responder, BOOL *stop)
    {
        tab = [tab stringByAppendingString:@"\t"];
        output = [output stringByAppendingFormat:@"\n%@%@", tab, responder];
    }];
    VLog( @"Responder Chain: \n%@", output );
}

@end
