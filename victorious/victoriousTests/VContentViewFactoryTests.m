//
//  VContentViewFactoryTests.m
//  victorious
//
//  Created by Josh Hinman on 3/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "NSObject+VMethodSwizzling.h"
#import "VContentViewFactory.h"
#import "VDependencyManager.h"
#import "VSequence+Fetcher.h"

#import <OCMock/OCMock.h>
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VContentViewFactoryTests : XCTestCase

@property (nonatomic, strong) id customSchemeSequence;
@property (nonatomic, strong) id httpWebSequence;
@property (nonatomic, strong) id httpsWebSequence;
@property (nonatomic, strong) id nonWebSequence;
@property (nonatomic, strong) id dependencyManager;
@property (nonatomic, strong) VContentViewFactory *contentViewFactory;

@end

@implementation VContentViewFactoryTests

- (void)setUp
{
    [super setUp];
    
    self.customSchemeSequence = [OCMockObject niceMockForClass:[VSequence class]];
    [[[self.customSchemeSequence stub] andReturnValue:@YES] isWebContent];
    [[[self.customSchemeSequence stub] andReturn:@"alsidkjlasiflis://nonexistant"] webContentUrl];
    
    self.httpWebSequence = [OCMockObject niceMockForClass:[VSequence class]];
    [[[self.httpWebSequence stub] andReturnValue:@YES] isWebContent];
    [[[self.httpWebSequence stub] andReturn:@"http://www.example.com/"] webContentUrl];
    
    self.httpsWebSequence = [OCMockObject niceMockForClass:[VSequence class]];
    [[[self.httpsWebSequence stub] andReturnValue:@YES] isWebContent];
    [[[self.httpsWebSequence stub] andReturn:@"https://www.google.com/"] webContentUrl];
    
    self.nonWebSequence = [OCMockObject niceMockForClass:[VSequence class]];
    [[[self.nonWebSequence stub] andReturnValue:@NO] isWebContent];
    
    self.dependencyManager = [OCMockObject niceMockForClass:[VDependencyManager class]];
    self.contentViewFactory = [[VContentViewFactory alloc] initWithDependencyManager:self.dependencyManager];
}

- (void)testCantDisplayUnknownCustomScheme
{
    NSString *reason = nil;
    BOOL canDisplay = [self.contentViewFactory canDisplaySequence:self.customSchemeSequence localizedReason:&reason];
    XCTAssertFalse(canDisplay);
    XCTAssertNotNil(reason);
}

- (void)testCanDisplayHTTPSequence
{
    BOOL canDisplay = [self.contentViewFactory canDisplaySequence:self.httpWebSequence localizedReason:nil];
    XCTAssert(canDisplay);
}

- (void)testCanDisplayHTTPSSequence
{
    BOOL canDisplay = [self.contentViewFactory canDisplaySequence:self.httpsWebSequence localizedReason:nil];
    XCTAssert(canDisplay);
}

- (void)testCanDisplayNonWebSequence
{
    BOOL canDisplay = [self.contentViewFactory canDisplaySequence:self.nonWebSequence localizedReason:nil];
    XCTAssert(canDisplay);
}

- (void)testCanDisplayValidLink
{
    [UIApplication v_swizzleMethod:@selector(canOpenURL:)
                         withBlock:^(id me, NSURL *url)
    {
        return YES;
    }
                      executeBlock:^(void)
    {
        BOOL canDisplay = [self.contentViewFactory canDisplaySequence:self.customSchemeSequence localizedReason:nil];
        XCTAssert(canDisplay);
    }];
}

@end
