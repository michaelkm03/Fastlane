//
//  VFlaggedContentTests.m
//  victorious
//
//  Created by Patrick Lynch on 12/10/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "VFlaggedContent.h"

@interface VFlaggedContent(Tests)

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@interface VFlaggedContentTests : XCTestCase

@end

@implementation VFlaggedContentTests

- (void)testInitialization
{
    VFlaggedContent *flaggedContent = [[VFlaggedContent alloc] init];
    XCTAssertEqualObjects( flaggedContent.userDefaults, [NSUserDefaults standardUserDefaults] );
    XCTAssertEqual( flaggedContent.refreshTimeInterval, VDefaultRefreshTimeInterval );
    
    NSUserDefaults *testDefaults = [[NSUserDefaults alloc] init];
    flaggedContent = [[VFlaggedContent alloc] initWithDefaults:testDefaults];
    XCTAssertEqualObjects( flaggedContent.userDefaults, testDefaults );
    XCTAssertEqual( flaggedContent.refreshTimeInterval, VDefaultRefreshTimeInterval );

    flaggedContent = [[VFlaggedContent alloc] initWithDefaults:testDefaults refreshTimeInterval:99.0];
    XCTAssertEqualObjects( flaggedContent.userDefaults, testDefaults );
    XCTAssertEqual( flaggedContent.refreshTimeInterval, 99.0 );
}

- (void)testWriteAndRead
{
    NSUserDefaults *testDefaults = [[NSUserDefaults alloc] init];
    VFlaggedContent *flaggedContent = [[VFlaggedContent alloc] initWithDefaults:testDefaults];
    
    NSMutableArray *flaggedRemoteIds = [[NSMutableArray alloc] init];
    NSMutableArray *unflaggedRemoteIds = [[NSMutableArray alloc] init];
    for ( NSUInteger i = 0; i < 10; i++ )
    {
        NSString *remoteId = [NSString stringWithFormat:@"%@", @(i)];
        if ( i % 2 > 0 )
        {
            [flaggedRemoteIds addObject:remoteId];
            [flaggedContent addRemoteId:remoteId toFlaggedItemsWithType:VFlaggedContentTypeComment];
        }
        else
        {
            [unflaggedRemoteIds addObject:remoteId];
        }
    }
    
    NSArray *savedFlaggedRemoteIds = [flaggedContent flaggedContentIdsWithType:VFlaggedContentTypeComment];
    for ( NSString *string in unflaggedRemoteIds )
    {
        XCTAssertFalse( [savedFlaggedRemoteIds containsObject:string] );
    }
    for ( NSString *string in flaggedRemoteIds )
    {
        XCTAssertTrue( [savedFlaggedRemoteIds containsObject:string] );
    }
    
    XCTAssertEqual( flaggedRemoteIds.count, savedFlaggedRemoteIds.count );
}

- (void)testRefresh
{
    NSUserDefaults *testDefaults = [[NSUserDefaults alloc] init];
    VFlaggedContent *flaggedContent = [[VFlaggedContent alloc] initWithDefaults:testDefaults refreshTimeInterval:99.0];
    
    for ( NSUInteger i = 0; i < 10; i++ )
    {
        NSString *remoteId = [NSString stringWithFormat:@"%@", @(i)];
        [flaggedContent addRemoteId:remoteId toFlaggedItemsWithType:VFlaggedContentTypeComment];
    }
    
    [flaggedContent refreshFlaggedContents];
    
    NSArray *savedFlaggedRemoteIds = [flaggedContent flaggedContentIdsWithType:VFlaggedContentTypeComment];
    XCTAssertEqual( savedFlaggedRemoteIds.count, 10u,
                   @"Content should be unaffected before the time interval expires." );
    
    flaggedContent.refreshTimeInterval = 0.0;
    [flaggedContent refreshFlaggedContents];
    
    savedFlaggedRemoteIds = [flaggedContent flaggedContentIdsWithType:VFlaggedContentTypeComment];
    XCTAssertEqual( savedFlaggedRemoteIds.count, 0u,
                   @"Content should be removed after the time interval expires." );
}

@end
