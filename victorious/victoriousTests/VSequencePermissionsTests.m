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

- (void)testExample
{
    NSDictionary *mapping = @{ @(VSequencePermissionCanDelete)          : VSelectorName(canDelete),
                               @(VSequencePermissionCanRemix)           : VSelectorName(canRemix),
                               @(VSequencePermissionCanShowVoteCount)   : VSelectorName(canShowVoteCount),
                               @(VSequencePermissionCanComment)         : VSelectorName(canComment),
                               @(VSequencePermissionCanRepost)          : VSelectorName(canRepost),
                               @(VSequencePermissionCanEditComment)     : VSelectorName(canEditComment),
                               @(VSequencePermissionCanDeleteComment)   : VSelectorName(canDeleteComment),
                               @(VSequencePermissionCanFlagSequence)    : VSelectorName(canFlagSequence),
                               @(VSequencePermissionCanMeme)            : VSelectorName(canMeme),
                               @(VSequencePermissionCanGif)             : VSelectorName(canGIF),
                               @(VSequencePermissionCanQuote)           : VSelectorName(canQuote) };
    
    VSequencePermissions *permissions;
    unsigned long long value = 1;
    
    for ( NSNumber *key in mapping )
    {
        
    }
    
    
    
    value = VSequencePermissionCanDelete | VSequencePermissionCanShowVoteCount;
    permissions = [[VSequencePermissions alloc] initWithNumber:@(value)];
    NSLog( @"%@", permissions.description );
}

@end
