//
//  VWebViewBasic.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewBasic.h"

@implementation VWebViewBasic

@synthesize unifiedDelegate;

- (UIView *)asView
{
    return self;
}

- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString *output = [self stringByEvaluatingJavaScriptFromString:script];
    completionHandler( output, nil );
}

@end
