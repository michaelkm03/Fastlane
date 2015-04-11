//
//  VDefaultTemplateTests.m
//  victorious
//
//  Created by Josh Hinman on 4/10/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VBackground.h"
#import "VDependencyManager+VDefaultTemplate.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VDefaultTemplateTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VDefaultTemplateTests

- (void)setUp
{
    [super setUp];
    self.dependencyManager = [VDependencyManager dependencyManagerWithDefaultValuesForColorsAndFonts];
}

- (void)testDependencyManagerWithDefaults
{
    XCTAssertNotNil(self.dependencyManager);
}

- (void)testDefaultColors
{
    XCTAssertNotNil([self.dependencyManager background]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerContentTextColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerAccentColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerSecondaryAccentColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerLinkColorKey]);
    XCTAssertNotNil([self.dependencyManager colorForKey:VDependencyManagerSecondaryLinkColorKey]);
}

- (void)testDefaultFonts
{
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerHeading1FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerHeading2FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerHeading3FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerHeading4FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerParagraphFontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerLabel1FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerLabel3FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerLabel4FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerButton1FontKey]);
    XCTAssertNotNil([self.dependencyManager fontForKey:VDependencyManagerButton2FontKey]);
}

@end
