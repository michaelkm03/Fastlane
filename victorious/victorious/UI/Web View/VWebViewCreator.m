//
//  VWebViewCreator.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewCreator.h"

static const BOOL kForceUIWebView = NO;

@implementation VWebViewCreator

+ (id<VWebViewProtocol>)createWebView
{
    if ( NSClassFromString( @"WKWebView" ) != nil && !kForceUIWebView )
    {
        return [[VWebViewAdvanced alloc] init];
    }
    else
    {
        return [[VWebViewBasic alloc] init];
    }
}

@end