//
//  VTemplateSerializationTests.m
//  victorious
//
//  Created by Josh Hinman on 4/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTemplateSerialization.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VTemplateSerializationTests : XCTestCase

@end

@implementation VTemplateSerializationTests

- (void)testDeserialization
{
    NSDictionary *mockTemplate = @{ @"hello": @"world" };
    NSDictionary *mockServerResponse = @{ @"error": @0,
                                          @"message": @"",
                                          @"api_version": @"1.2-1",
                                          @"host": @"ip-172-31-7-171",
                                          @"app_id": @1,
                                          @"user_id": [NSNull null],
                                          @"login_id": [NSNull null],
                                          @"page_number": @0,
                                          @"total_pages": @0,
                                          @"payload": mockTemplate };
    NSData *mockData = [NSJSONSerialization dataWithJSONObject:mockServerResponse options:0 error:nil];
    NSDictionary *retVal = [VTemplateSerialization templateConfigurationDictionaryWithData:mockData];
    XCTAssertEqualObjects(retVal, mockTemplate);
}

@end
