//
//  VWebViewFactory.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VWebViewFactory.h"

static const BOOL kForceUIWebView = NO;

@implementation VWebViewFactory

+ (id<VWebViewProtocol>)createWebView
{
    if ( [[self class] canUsedAdvancedWebView] )
    {
        return [[VWebViewAdvanced alloc] init];
    }
    else
    {
        return [[VWebViewBasic alloc] init];
    }
}

+ (BOOL)canUsedAdvancedWebView
{
    return NSClassFromString( @"WKWebView" ) != nil && !kForceUIWebView;
}

@end