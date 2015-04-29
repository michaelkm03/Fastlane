//
//  VDiscoverViewControllerTests.m
//  victorious
//
//  Created by Patrick Lynch on 10/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <UIKit/UIKit.h>
#import "NSObject+VMethodSwizzling.h"
#import "VDiscoverViewController.h"
#import "VSuggestedPeopleCell.h"
#import "VNoContentTableViewCell.h"
#import "VTrendingTagCell.h"
#import "VSuggestedPeopleCollectionViewController.h"
#import "VDummyModels.h"
#import "VTestHelpers.h"
#import "VDiscoverHeaderView.h"

@interface VDiscoverViewController (UnitTest)

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;
@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) NSArray *sectionHeaderTitles;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (void)registerCells;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)hashtagsDidFailToLoadWithError:(NSError *)error;
- (void)hashtagsDidLoad:(NSArray *)hashtags;
- (void)showStreamWithHashtag:(VHashtag *)hashtag;
- (void)reload;
- (void)refresh:(BOOL)shouldClearCurrentContent;
- (void)updatedFollowedTags;

@end

@interface VSuggestedPeopleCollectionViewController (UnitTest)

- (void)reload;

@end

@interface VDiscoverViewControllerTests : XCTestCase

@property (nonatomic, assign) IMP originalDiscoverRefresh;
@property (nonatomic, assign) IMP originalSuggestedPeopleRefresh;
@property (nonatomic, assign) IMP originalShowHashtagStream;
@property (nonatomic, strong) VDiscoverViewController *viewController;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation VDiscoverViewControllerTests

- (void)setUp
{
    [super setUp];
    
    // Replace these with empty blocks to prevent them from making actual calls to the server
    self.originalDiscoverRefresh = [VDiscoverViewController v_swizzleMethod:@selector(reload)
                                                              withBlock:^{}];
    self.originalSuggestedPeopleRefresh = [VSuggestedPeopleCollectionViewController v_swizzleMethod:@selector(reload)
                                                                                      withBlock:^{}];
    
    self.viewController = [[VDiscoverViewController alloc] init];
    XCTAssertNotNil( self.viewController );
    XCTAssertNotNil( self.viewController.tableView );
    XCTAssertNotNil( self.viewController.suggestedPeopleViewController );
    XCTAssertEqualObjects( self.viewController, self.viewController.suggestedPeopleViewController.delegate );
    XCTAssertNotNil( self.viewController.suggestedPeopleViewController.collectionView );
    self.tableView = self.viewController.tableView;
}

- (void)tearDown
{
    [super tearDown];
    
    [VDiscoverViewController v_restoreOriginalImplementation:self.originalDiscoverRefresh
                                                   forMethod:@selector(reload)];
    [VSuggestedPeopleCollectionViewController v_restoreOriginalImplementation:self.originalSuggestedPeopleRefresh
                                                                    forMethod:@selector(reload)];
    
    if ( self.originalShowHashtagStream != nil )
    {
        [VDiscoverViewController v_restoreOriginalImplementation:self.originalShowHashtagStream
                                                       forMethod:@selector(showStreamWithHashtag:)];
    }
}

- (void)testHeaderViews
{
    XCTAssertNotNil( [self.viewController tableView:self.tableView viewForHeaderInSection:VDiscoverViewControllerSectionSuggestedPeople] );
    XCTAssertNotNil( [self.viewController tableView:self.tableView viewForHeaderInSection:VDiscoverViewControllerSectionTrendingTags] );
    XCTAssertEqual( self.viewController.sectionHeaderTitles.count, (NSUInteger)2 );
    
    for ( NSInteger section = 0; section < VDiscoverViewControllerSectionsCount; section++ )
    {
        CGFloat height = [self.viewController tableView:self.tableView heightForHeaderInSection:section];
        XCTAssertEqual( height, [VDiscoverHeaderView desiredHeight] );
        UIView *headerView = [self.viewController tableView:self.tableView viewForHeaderInSection:section];
        XCTAssert( [headerView isKindOfClass:[VDiscoverHeaderView class]] );
    }
    
    // These are invalid sections (too low/high) and should return 0
    XCTAssertEqual( [self.viewController tableView:self.tableView heightForHeaderInSection:-1], 0.0f );
    XCTAssertEqual( [self.viewController tableView:self.tableView heightForHeaderInSection:VDiscoverViewControllerSectionsCount], 0.0f );
}

- (void)testRowsAndSections
{
    // Should be at least one table view cell even without data (for empty/error cell)
    XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:VDiscoverViewControllerSectionSuggestedPeople], (NSInteger)1 );
    XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:VDiscoverViewControllerSectionTrendingTags], (NSInteger)1 );
    
    XCTAssertEqual( [self.viewController numberOfSectionsInTableView:self.tableView], VDiscoverViewControllerSectionsCount );
    
    XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:-1], (NSInteger)0 );
    XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:VDiscoverViewControllerSectionsCount], (NSInteger)0,
                   @"Should return 0 since there are only 2 sections." );
    
    [self.viewController updatedFollowedTags];
    for ( NSInteger i = 1; i < 10; i++ )
    {
        self.viewController.suggestedPeopleViewController.suggestedUsers = [VDummyModels createUsers:i];
        XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:0], (NSInteger)1,
                       @"Even with many users, there should only be 1 row in section 0 because users are \
                       displayed in a collection view that is a subview of the table view cell." );
        
        self.viewController.trendingTags = [VDummyModels createHashtags:i];
        XCTAssertEqual( [self.viewController tableView:self.tableView numberOfRowsInSection:VDiscoverViewControllerSectionTrendingTags], i );
    }
}

- (void)testSuggestedPersonCell
{
    UITableViewCell *cell = nil;
    
    // No data has been added, so a VNoContentTableViewCell should be created
    cell = [self.viewController tableView:self.tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionTrendingTags)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    self.viewController.suggestedPeopleViewController.suggestedUsers = [VDummyModels createUsers:2];
    
    cell = [self.viewController tableView:self.tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionSuggestedPeople)];
    XCTAssert( [cell isKindOfClass:[VSuggestedPeopleCell class]], @"Cell should be a valid VSuggestedPeopleCell" );
}

- (void)testTrendingCell
{
    __block UITableViewCell *cell = nil;
    
    cell = [self.viewController tableView:self.tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionSuggestedPeople)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    self.viewController.trendingTags = [VDummyModels createHashtags:5];
    [self.viewController updatedFollowedTags];
    [self.viewController.tableView reloadData];
    
    [self.viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPath = VIndexPathMake(idx, VDiscoverViewControllerSectionTrendingTags);
        cell = [self.viewController tableView:self.tableView cellForRowAtIndexPath:indexPath];
        XCTAssert( [cell isKindOfClass:[VTrendingTagCell class]], @"Cell should be a valid VTrending" );
    }];
}

- (void)testInvalidSectionCell
{
    XCTAssertNil( [self.viewController tableView:self.tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionsCount)],
                 @"There are only 2 sections, so this should return nil" );
}

- (void)testNetworkRequestResponseSuccess
{
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    NSUInteger objectsCount = 5;
    [self.viewController hashtagsDidLoad:[VDummyModels createHashtags:objectsCount]];
    XCTAssertNil( self.viewController.error );
    XCTAssertEqual( self.viewController.trendingTags.count, objectsCount );
    XCTAssert( self.viewController.hasLoadedOnce );
}

- (void)testNetworkRequestResponseError
{
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    [self.viewController hashtagsDidFailToLoadWithError:[[NSError alloc] init]];
    XCTAssertNotNil( self.viewController.error );
    XCTAssertEqual( self.viewController.trendingTags.count, (NSUInteger)0 );
    XCTAssert( self.viewController.hasLoadedOnce );
}

- (void)testNetworkRequestResponseErrorNil
{
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    [self.viewController hashtagsDidFailToLoadWithError:nil];
    XCTAssertNotNil( self.viewController.error );
    XCTAssertEqual( self.viewController.trendingTags.count, (NSUInteger)0 );
    XCTAssert( self.viewController.hasLoadedOnce );
}

- (void)testSelectRow
{
    // Add some data
    self.viewController.trendingTags = [VDummyModels createHashtags:5];
    
    __block VHashtag *selectedHashtag = nil;
    
    // Replace this selector with one that sets our selectedHashtag variable to the
    // hashtag that tableView:didSelectRowAtIndexPath: uses as a parameter when showStreamWithHashtag: is called
    self.originalShowHashtagStream = [VDiscoverViewController v_swizzleMethod:@selector(showStreamWithHashtag:)
                                                                withBlock:^void (VDiscoverViewController *obj, VHashtag *hashtag)
                                  {
                                      selectedHashtag = hashtag;
                                  }];
    
    // Simulate selection of each cell
    [self.viewController updatedFollowedTags];
    [self.viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop)
     {
         [self.viewController tableView:self.tableView didSelectRowAtIndexPath:VIndexPathMake(idx, VDiscoverViewControllerSectionTrendingTags)];
         XCTAssertEqualObjects( selectedHashtag, hashtag,
                               @"The swizzled method above should be called and should set selectedHashtag \
                               to the hashtag in self.viewController.trendingTags that we're expecting." );
    }];
}

- (void)testRefresh
{
    NSUInteger count = 5;
    
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    
    [self.viewController refresh:YES];
    [self.viewController hashtagsDidLoad:[VDummyModels createHashtags:count]]; // Simulates successful reload response
    XCTAssert( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.trendingTags.count, count );
    
    [self.viewController refresh:NO];
    XCTAssert( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.trendingTags.count, count );
    
    [self.viewController refresh:YES];
    XCTAssertFalse( self.viewController.hasLoadedOnce );
    XCTAssertEqual( self.viewController.trendingTags.count, (NSUInteger)0 );
}

@end
