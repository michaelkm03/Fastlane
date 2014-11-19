//
//  VTemplateGeneratorTests.m
//  victorious
//
//  Created by Josh Hinman on 11/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VTemplateGenerator.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VTemplateGeneratorTests : XCTestCase

@property (nonatomic, strong) NSDictionary *template;

@end

@implementation VTemplateGeneratorTests

- (void)setUp
{
    [super setUp];
    NSData *initData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"init" withExtension:@"json"]];
    NSDictionary *initObject = [NSJSONSerialization JSONObjectWithData:initData options:0 error:nil];
    self.template = [[[VTemplateGenerator alloc] initWithInitData:initObject] configurationDict];
}

- (void)testAppearance
{
    NSString *expected = @"Cantarell";
    
    NSDictionary *font = self.template[@"font.header"];
    NSString *actual = font[@"fontName"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testScaffold
{
    NSDictionary *scaffold = self.template[@"scaffold"];
    
    NSString *expectedName = @"sideMenu.scaffold";
    NSString *actualName = scaffold[@"name"];
    XCTAssertEqualObjects(expectedName, actualName);
}

- (void)testMiscPropertyFromInitData
{
    NSString *expected = @"https://itunes.apple.com/us/app/id889351747";
    NSString *actual = self.template[@"app_store_url"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testPropertiesFromExperiments
{
    NSNumber *expected = @(YES);
    NSNumber *actual = [self.template valueForKeyPath:@"experiments.histogram_enabled"];
    XCTAssertEqualObjects(expected, actual);
}

@end
