//
//  VWebView.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

@import UIKit;

#import "VWebViewProtocol.h"
#import "VWebViewAdvanced.h"
#import "VWebViewBasic.h"

@interface VWebViewCreator : NSObject

/**
 Factory method that creates the appropriate web view (UIWebView or WKWebView) according
 to the current iOS version, abstracted behind VWebViewProtocol.
 */
+ (id<VWebViewProtocol>)createWebView;

@end