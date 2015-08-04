//
//  VExperimentSettingsTests.m
//  victorious
//
//  Created by Patrick Lynch on 8/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VExperimentSettings.h"

@interface VExperimentSettingsTests : XCTestCase

@end

@implementation VExperimentSettingsTests

- (void)setUp
{
    [super setUp];
}

- (void)testSaveLoadAndReset
{
    VExperimentSettings *settings;
    NSSet *experimentIds;
    
    settings = [[VExperimentSettings alloc] init];
    experimentIds = [NSSet setWithArray:@[ @0, @1, @2, @3 ]];
    settings.activeExperiments = experimentIds;
    
    settings = [[VExperimentSettings alloc] init];
    XCTAssertEqual( settings.activeExperiments.count, experimentIds.count );
    XCTAssertEqualObjects( settings.commaSeparatedList, [experimentIds.allObjects componentsJoinedByString:@","] );
    
    settings = [[VExperimentSettings alloc] init];
    experimentIds = [NSSet set];
    settings.activeExperiments = experimentIds;
    
    settings = [[VExperimentSettings alloc] init];
    XCTAssertEqual( settings.activeExperiments.count, 0u );
    XCTAssertEqualObjects( settings.commaSeparatedList, @"" );
    
    settings = [[VExperimentSettings alloc] init];
    [settings reset];
    
    settings = [[VExperimentSettings alloc] init];
    XCTAssertNil( settings.activeExperiments );
    XCTAssertNil( settings.commaSeparatedList );
}

@end
