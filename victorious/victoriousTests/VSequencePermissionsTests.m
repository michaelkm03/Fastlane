//
//  VSequencePermissionstests.m
//  victorious
//
//  Created by Patrick Lynch on 6/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VSequencePermissions.h"

#define VSelectorName(s) NSStringFromSelector(@selector(s))

@interface VSequencePermissionstests : XCTestCase

@end

@implementation VSequencePermissionstests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInvalidInitialization
{
    XCTAssertNil( [[VSequencePermissions alloc] init] );
    XCTAssertNil( [[VSequencePermissions alloc] initWithNumber:nil] );
    XCTAssertNil( [VSequencePermissions permissionsWithNumber:nil] );
}

- (void)testPermissionToProperty
{
    // The order of these properties should match the order in which the equivalent
    // values of the VSequencePermission enum are defined
    NSArray *selectorNames = @[ VSelectorName( canDelete ),
                                VSelectorName( canRemix ),
                                VSelectorName( canShowVoteCount ),
                                VSelectorName( canComment ),
                                VSelectorName( canRepost ),
                                VSelectorName( canEditComments ),
                                VSelectorName( canDeleteComments ),
                                VSelectorName( canFlagSequence ),
                                VSelectorName( canGIF ),
                                VSelectorName( canMeme ),
                                VSelectorName( canQuote ) ];
    
    // This loop sets one permission, then iterates throguh all permissions and makes sure that
    // only the one that was set in the raw bitmask value now reads YES while all others read NO
    for ( NSUInteger i = 0; i < selectorNames.count; i++ )
    {
        NSUInteger rawValue = 1 << i;
        VSequencePermissions *permissions = [[VSequencePermissions alloc] initWithNumber:@(rawValue)];
        for ( NSUInteger j = 0; j < selectorNames.count; j++ )
        {
            NSString *selectorName = selectorNames[ j ];
            SEL selector = NSSelectorFromString( selectorName );
            IMP imp = [permissions methodForSelector:selector];
            BOOL (*func)(id, SEL) = (void *)imp;
            BOOL result = func( permissions, selector );
            if ( i == j )
            {
                XCTAssert( result, @"Failed to read BOOL property (%@) from bitmask (%@)", selectorName, permissions );
            }
            else
            {
                XCTAssertFalse( result, @"Failed to read BOOL property (%@) from bitmask (%@)", selectorName, permissions );
            }
        }
    }
}

@end
