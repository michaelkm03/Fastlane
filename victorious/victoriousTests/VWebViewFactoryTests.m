//
//  VWebViewFactoryTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VWebViewFactory.h"
#import "NSObject+VMethodSwizzling.h"
#import "VWebViewProtocol.h"

@interface VWebViewFactory()

+ (BOOL)canUsedAdvancedWebView;

@end

@interface VWebViewFactoryTests : XCTestCase

@end

@implementation VWebViewFactoryTests

- (void)testWebViewFactory
{
    __block id webView = nil;
    __block BOOL blockCalledBasic = NO;
    __block BOOL blockCalledAdvanced = NO;
    
    [VWebViewFactory v_swizzleClassMethod:@selector(canUsedAdvancedWebView) withBlock:^BOOL
     {
         return YES;
     }
                             executeBlock:^
     {
         webView = [VWebViewFactory createWebView];
         XCTAssertNotNil( webView );
         XCTAssert( [webView isKindOfClass:[VWebViewAdvanced class]] );
         XCTAssert( [webView conformsToProtocol:@protocol(VWebViewProtocol)] );
         blockCalledAdvanced = YES;
     }];
    
    [VWebViewFactory v_swizzleClassMethod:@selector(canUsedAdvancedWebView) withBlock:^BOOL
     {
         return NO;
     }
                             executeBlock:^
     {
         webView = [VWebViewFactory createWebView];
         XCTAssertNotNil( webView );
         XCTAssert( [webView isKindOfClass:[VWebViewBasic class]] );
         XCTAssert( [webView conformsToProtocol:@protocol(VWebViewProtocol)] );
         blockCalledBasic = YES;
     }];
    
    XCTAssert( blockCalledAdvanced );
    XCTAssert( blockCalledBasic );
    
}

@end
