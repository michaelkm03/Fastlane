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
#import "VUser.h"
#import "VHashtag.h"
#import "VObjectManager.h"

// Quick and dirty convenience method to avoid cluttering code
NSIndexPath *VIndexPathMake( NSInteger row, NSInteger section ) {
    return [NSIndexPath indexPathForRow:row inSection:section];
}

@interface VObjectManager (UnitTest)

- (id)objectWithEntityName:(NSString *)entityName subclass:(Class)subclass;

@end

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
                                                       forMethod:@selector(showStreamWithHastag:)];
    }
}

- (NSArray *)createUsers:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VUser *user = (VUser *)[[VObjectManager sharedManager] objectWithEntityName:@"User" subclass:[VUser class]];
        user.name = [NSString stringWithFormat:@"user_%lu", (unsigned long)i];
        user.remoteId = @(i);
        [models addObject:user];
    }
    return [NSArray arrayWithArray:models];
}

- (NSArray *)createHashtags:(NSInteger)count
{
    NSMutableArray *models = [[NSMutableArray alloc] init];
    for ( NSInteger i = 0; i < count; i++ )
    {
        VHashtag *hashtag = (VHashtag *)[[VObjectManager sharedManager] objectWithEntityName:@"Hashtag" subclass:[VHashtag class]];
        hashtag.tag = [NSString stringWithFormat:@"hashtag_%lu", (unsigned long)i];
        [models addObject:hashtag];
    }
    return [NSArray arrayWithArray:models];
}

- (void)testHeaderViews
{
    XCTAssertNotNil( [_viewController tableView:_tableView viewForHeaderInSection:0] );
    XCTAssertNotNil( [_viewController tableView:_tableView viewForHeaderInSection:1] );
    XCTAssertEqual( _viewController.sectionHeaders.count, (NSUInteger)2 );
    
    for ( NSInteger section = 0; section < 2; section++ )
    {
        UIView *headerView = _viewController.sectionHeaders[ section ];
        CGFloat height = [_viewController tableView:_tableView heightForHeaderInSection:section];
        XCTAssertEqual( height, CGRectGetHeight( headerView.frame ) );
    }
    
    // These are invalid sections (too low/high) and should return 0
    XCTAssertEqual( [_viewController tableView:_tableView heightForHeaderInSection:-1], 0.0f );
    XCTAssertEqual( [_viewController tableView:_tableView heightForHeaderInSection:3], 0.0f );
}

- (void)testRowsAndSections
{
    // Should be at least one table view cell even without data (for empty/error cell)
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:0], (NSInteger)1 );
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:1], (NSInteger)1 );
    
    XCTAssertEqual( [_viewController numberOfSectionsInTableView:_tableView], (NSInteger)2 );
    
    XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:2], (NSInteger)0,
                   @"Should return 0 since there are only 2 sections." );
    
    for ( NSInteger i = 1; i < 10; i++ )
    {
        _viewController.suggestedPeopleViewController.suggestedUsers = [self createUsers:i];
        XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:0], (NSInteger)1,
                       @"Even with many users, there should only be 1 row in section 0." );
        
        _viewController.trendingTags = [self createHashtags:i];
        XCTAssertEqual( [_viewController tableView:_tableView numberOfRowsInSection:1], i );
    }
}

- (void)testSuggestedPersonCell
{
    UITableViewCell *cell = nil;
    
    // No data has been added, so a VNoContentTableViewCell should be created
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, 1)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    _viewController.suggestedPeopleViewController.suggestedUsers = [self createUsers:2];
    
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, 0)];
    XCTAssert( [cell isKindOfClass:[VSuggestedPeopleCell class]], @"Cell should be a valid VSuggestedPeopleCell" );
}

- (void)testTrendingCell
{
    __block UITableViewCell *cell = nil;
    
    cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, 0)];
    XCTAssert( [cell isKindOfClass:[VNoContentTableViewCell class]],
              @"Cell should be a VNoContentTableViewCell before data is created." );
    
    // Add some data
    _viewController.trendingTags = [self createHashtags:5];
    
    [_viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop) {
        cell = [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(idx, 1)];
        XCTAssert( [cell isKindOfClass:[VTrendingTagCell class]], @"Cell should be a valid VTrending" );
    }];
}

- (void)testInvalidSectionCell
{
    XCTAssertNil( [_viewController tableView:_tableView cellForRowAtIndexPath:VIndexPathMake(0, 2)],
                 @"There are only 2 sections, so this should return nil" );
}

- (void)testNetworkRequestResponseSuccess
{
    XCTAssertFalse( _viewController.hasLoadedOnce );
    NSUInteger objectsCount = 5;
    [_viewController hashtagsDidLoad:[self createHashtags:objectsCount]];
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
    _viewController.trendingTags = [self createHashtags:5];
    
    __block VHashtag *selectedHashtag = nil;
    
    _originalShowHashtagStream = [VDiscoverViewController v_swizzleMethod:@selector(showStreamWithHashtag:)
                                                                withBlock:^void (VDiscoverViewController* obj, VHashtag *hashtag)
                                  {
                                      selectedHashtag = hashtag;
                                  }];
    
    // Simulate selection of each cell
    [_viewController.trendingTags enumerateObjectsUsingBlock:^(VHashtag *hashtag, NSUInteger idx, BOOL *stop)
     {
         [_viewController tableView:_tableView didSelectRowAtIndexPath:VIndexPathMake(idx, 1)];
         XCTAssertEqualObjects( selectedHashtag, hashtag );
    }];
}

@end
