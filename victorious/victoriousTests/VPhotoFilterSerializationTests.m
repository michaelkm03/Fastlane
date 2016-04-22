//
//  VPhotoFilterSerializationTests.m
//  victorious
//
//  Created by Josh Hinman on 7/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPhotoFilter.h"
#import "VPhotoFilterSerialization.h"

#import <CoreImage/CoreImage.h>
#import <XCTest/XCTest.h>

@interface VPhotoFilterSerializationTests : XCTestCase

@end

@implementation VPhotoFilterSerializationTests

- (void)testDeserialization
{
    NSURL *filtersXML = [[NSBundle bundleForClass:[self class]] URLForResource:@"filters" withExtension:@"xml"];
    NSArray *filters = [VPhotoFilterSerialization filtersFromPlistFile:filtersXML];
    
    XCTAssertEqual(filters.count, 2u);
    
    VPhotoFilter *filter1 = filters[0];
    XCTAssertEqualObjects(filter1.localizedName, @"LA");
    XCTAssertEqualObjects([filter1.components[0] name], @"CIColorControls");
    XCTAssertEqualObjects([filter1.components[0] valueForKey:@"inputSaturation"], @1.26);
    XCTAssertEqualObjects([filter1.components[0] valueForKey:@"inputBrightness"], @(-0.04));
    XCTAssertEqualObjects([filter1.components[0] valueForKey:@"inputContrast"],   @1.08);
    XCTAssertEqualObjects([filter1.components[1] name], @"CIExposureAdjust");
    XCTAssertEqualObjects([filter1.components[1] valueForKey:@"inputEV"], @0.63);
    XCTAssertEqualObjects([filter1.components[2] name], @"CIPhotoEffectChrome");
    
    VPhotoFilter *filter2 = filters[1];
    XCTAssertEqualObjects(filter2.localizedName, @"Oslo");
    XCTAssertEqualObjects([filter2.components[0] name], @"CIColorControls");
    XCTAssertEqualObjects([filter2.components[0] valueForKey:@"inputSaturation"], @1.388);
    XCTAssertEqualObjects([filter2.components[0] valueForKey:@"inputBrightness"], @(-0.012));
    XCTAssertEqualObjects([filter2.components[0] valueForKey:@"inputContrast"],   @1);
}

@end
