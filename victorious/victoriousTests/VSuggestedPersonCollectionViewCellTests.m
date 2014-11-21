//
//  VSuggestedPersonCollectionViewCellTests.m
//  victorious
//
//  Created by Patrick Lynch on 11/20/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VSuggestedPersonCollectionViewCell.h"

@interface VSuggestedPersonCollectionViewCell (UnitTest)

- (NSString *)followerTextWithNumberOfFollowers:(NSInteger)numberOfFollwers;

@end

@interface VSuggestedPersonCollectionViewCellTests : XCTestCase

@property (nonatomic, strong) VSuggestedPersonCollectionViewCell *cell;

@end

@implementation VSuggestedPersonCollectionViewCellTests

- (void)setUp
{
    [super setUp];
    
    self.cell = [[VSuggestedPersonCollectionViewCell alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSingular
{
    XCTAssertEqualObjects( [self.cell followerTextWithNumberOfFollowers:1], @"1 Follower" );
}

- (void)testNone
{
    XCTAssertEqualObjects( [self.cell followerTextWithNumberOfFollowers:0], @"No Followers" );
}

- (void)testPlural
{
    XCTAssertEqualObjects( [self.cell followerTextWithNumberOfFollowers:9], @"9 Followers" );
    XCTAssertEqualObjects( [self.cell followerTextWithNumberOfFollowers:99], @"99 Followers" );
    XCTAssertEqualObjects( [self.cell followerTextWithNumberOfFollowers:999], @"999 Followers" );
}

- (void)testThousands
{
    NSString *label = [self.cell followerTextWithNumberOfFollowers:1000];
    XCTAssertEqualObjects( label, @"1K Followers" );
    
    label = [self.cell followerTextWithNumberOfFollowers:2500];
    XCTAssertEqualObjects( label, @"2K Followers" );
    
    label = [self.cell followerTextWithNumberOfFollowers:5180];
    XCTAssertEqualObjects( label, @"5K Followers" );
    
    label = [self.cell followerTextWithNumberOfFollowers:21225];
    XCTAssertEqualObjects( label, @"21K Followers" );
    
    label = [self.cell followerTextWithNumberOfFollowers:1530500];
    XCTAssertEqualObjects( label, @"1M Followers" );
}

@end
