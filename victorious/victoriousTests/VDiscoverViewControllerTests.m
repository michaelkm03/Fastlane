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

// Quick and dirty convenience method to avoid cluttering code
NSIndexPath *VIndexPathMake( NSInteger row, NSInteger section ) {
    return [NSIndexPath indexPathForRow:row inSection:section];
}

@interface VDiscoverViewController (UnitTest)

@property (nonatomic, strong) VSuggestedPeopleCollectionViewController *suggestedPeopleViewController;
@property (nonatomic, strong) NSArray *trendingTags;
@property (nonatomic, strong) NSError *error;
@property (nonatomic, assign) BOOL hasLoadedOnce;
@property (nonatomic, strong) NSArray *sectionHeaders;

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section;
- (void)registerCells;
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)hashtagsDidFailToLoadWithError:(NSError *)error;
- (void)hashtagsDidLoad:(NSArray *)hashtags;
- (void)showStreamWithHashtag:(VHashtag *)hashtag;

@end

@interface VDiscoverViewControllerTests : XCTestCase
{
    IMP _originalDiscoverRefresh;
    IMP _originalSuggestedPeopleRefresh;
    IMP _originalShowHashtagStream;
    VDiscoverViewController *_viewController;
    UITableView *_tableView;
}

@end

@implementation VDiscoverViewControllerTests

- (void)setUp
{
    [super setUp];
    
    // Replace these with empty blocks to prevent them from making actual calls to the server
    _originalDiscoverRefresh = [VDiscoverViewController v_swizzleMethod:@selector(refresh)
                                                              withBlock:^{}];
    _originalSuggestedPeopleRefresh = [VSuggestedPeopleCollectionViewController v_swizzleMethod:@selector(refresh)
                                                                                      withBlock:^{}];
    
    _viewController = [[VDiscoverViewController alloc] init];
    XCTAssertNotNil( _viewController );
    XCTAssertNotNil( _viewController.tableView );
    XCTAssertNotNil( _viewController.suggestedPeopleViewController );
    XCTAssertEqualObjects( _viewController, _viewController.suggestedPeopleViewController.delegate );
    XCTAssertNotNil( _viewController.suggestedPeopleViewController.collectionView );
    _tableView = _viewController.tableView;
}

- (void)tearDown
{
    [super tearDown];
    
    [VDiscoverViewController v_restoreOriginalImplementation:_originalDiscoverRefresh
                                                   forMethod:@selector(refresh)];
    [VSuggestedPeopleCollectionViewController v_restoreOriginalImplementation:_originalSuggestedPeopleRefresh
                                                                    forMethod:@selector(refresh)];
    
    if ( _originalShowHashtagStream != nil )
    {
        [VDiscoverViewController v_restoreOriginalImplementation:_originalShowHashtagStream
                                                       forMethod:@selector(showStreamWithHashtag:)];
    }
}

- (void)testHeaderViews
{
    XCTAssertNotNil( [_viewController tableView:_tableView viewForHeaderInSection:VDiscoverViewControllerSectionSuggestedPeople] );
    XCTAssertNotNil( [_viewController tableView:_tableView viewForHeaderInSection:VDiscoverViewControllerSectionTrendingTags] );
    XCTAssertEqual( _viewController.sectionHeaders.count, (NSUInteger)2 );
    
    for ( NSInteger section = 0; section < VDiscoverViewControllerSectionsCount; section++ )
    {
        UIView *headerView = _viewController.sectionHeaders[ section ];
        CGFloat height = [_viewController tableView:_tableView heightForHeaderInSection:section];
        XCTAssertEqual( height, CGRectGetHeight( headerView.frame ) );
    }
    
    // These are invalid sections (too low/high) and should return 0
    XCTAssertEqual( [_viewController tableView:_tableView heightForHeaderInSection:-1], 0.0f );
    XCTAssertEqual( [_viewController tableView:_tableView heightForHeaderInSection:VDiscoverViewControllerSectionsCount], 0.0f );
}

- (void)testRowsAndSections
{
    // Should be at least one table view cell even without data (for empty/error cell)
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:VDiscoverViewControllerSectionSuggestedPeople], (NSInteger)1 );
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:VDiscoverViewControllerSectionTrendingTags], (NSInteger)1 );
    
    XCTAssertEqual( [_viewController numberOfSectionsInTableView:_tableView], VDiscoverViewControllerSectionsCount );
    
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:-1], (NSInteger)0 );
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:VDiscoverViewControllerSectionsCount], (NSInteger)0,
                   @"Should return 0 since there are only 2 sections." );
    
    for ( NSInteger i = 1; i < 10; i++ )
    {
        _viewController.suggestedPeopleViewController.suggestedUsers = [VDummyModels createUsers:i];
        XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:0], (NSInteger)1,
                       @"Even with many users, there should only be 1 row in section 0 because users are \
                       displayed in a collection view that is a subview of the table view cell." );
        
        _viewController.trendingTags = [VDummyModels createHashtags:i];
        XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:VDiscoverViewControllerSectionTrendingTags], i );
    }
}

- (void)testSuggestedPersonCell
{
    UITableViewCell *cell = nil;
    
    // No data has been added, so a VNoContentTableViewCell should be created
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionTrendingTags)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    _viewController.suggestedPeopleViewController.suggestedUsers = [VDummyModels createUsers:2];
    
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionSuggestedPeople)];
    XCTAssert( [cell isKindOfClass:[VSuggestedPeopleCell class]], @"Cell should be a valid VSuggestedPeopleCell" );
}

- (void)testTrendingCell
{
    __block UITableViewCell *cell = nil;
    
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionSuggestedPeople)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    _viewController.trendingTags = [VDummyModels createHashtags:5];
    
    [_viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop) {
        cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(idx, VDiscoverViewControllerSectionTrendingTags)];
        XCTAssert( [cell isKindOfClass:[VTrendingTagCell class]], @"Cell should be a valid VTrending" );
    }];
}

- (void)testInvalidSectionCell
{
    XCTAssertNil( [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, VDiscoverViewControllerSectionsCount)],
                 @"There are only 2 sections, so this should return nil" );
}

- (void)testNetworkRequestResponseSuccess
{
    XCTAssertFalse( _viewController.hasLoadedOnce );
    NSUInteger objectsCount = 5;
    [_viewController hashtagsDidLoad:[VDummyModels createHashtags:objectsCount]];
    XCTAssertNil( _viewController.error );
    XCTAssertEqual( _viewController.trendingTags.count, objectsCount );
    XCTAssert( _viewController.hasLoadedOnce );
}

- (void)testNetworkRequestResponseError
{
    XCTAssertFalse( _viewController.hasLoadedOnce );
    [_viewController hashtagsDidFailToLoadWithError:[[NSError alloc] init]];
    XCTAssertNotNil( _viewController.error );
    XCTAssertEqual( _viewController.trendingTags.count, (NSUInteger)0 );
    XCTAssert( _viewController.hasLoadedOnce );
}

- (void)testNetworkRequestResponseErrorNil
{
    XCTAssertFalse( _viewController.hasLoadedOnce );
    [_viewController hashtagsDidFailToLoadWithError:nil];
    XCTAssertNotNil( _viewController.error );
    XCTAssertEqual( _viewController.trendingTags.count, (NSUInteger)0 );
    XCTAssert( _viewController.hasLoadedOnce );
}

- (void)testSelectRow
{
    // Add some data
    _viewController.trendingTags = [VDummyModels createHashtags:5];
    
    __block VHashtag *selectedHashtag = nil;
    
    // Replace this selector with one that sets our selectedHashtag variable to the
    // hashtag that tableView:didSelectRowAtIndexPath: uses as a parameter when showStreamWithHashtag: is called
    _originalShowHashtagStream = [VDiscoverViewController v_swizzleMethod:@selector(showStreamWithHashtag:)
                                                                withBlock:^void (VDiscoverViewController *obj, VHashtag *hashtag)
                                  {
                                      selectedHashtag = hashtag;
                                  }];
    
    // Simulate selection of each cell
    [_viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop)
     {
         [_viewController tableView:_tableView didSelectRowAtIndexPath:VIndexPathMake(idx, VDiscoverViewControllerSectionTrendingTags)];
         XCTAssertEqualObjects( selectedHashtag, hashtag,
                               @"The swizzled method above should be called and should set selectedHashtag \
                               to the hashtag in _viewController.trendingTags that we're expecting." );
    }];
}

@end
