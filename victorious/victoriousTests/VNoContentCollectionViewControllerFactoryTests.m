//
//  VNoContentCollectionViewControllerProviderTests.m
//  victorious
//
//  Created by Sharif Ahmed on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VNoContentCollectionViewCellFactory.h"

@interface VDummyCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@end

@implementation VDummyCollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1;
}

@end

@interface VNoContentCollectionViewControllerFactoryTests : XCTestCase

@property (nonatomic, strong) VNoContentCollectionViewCellFactory *noContentCollectionViewCellFactory;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VDummyCollectionViewDataSource *collectionViewDataSource;

@end

@implementation VNoContentCollectionViewControllerFactoryTests

- (void)setUp
{
    [super setUp];
    self.noContentCollectionViewCellFactory = [[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:@[[NSDictionary class]]];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionViewDataSource = [[VDummyCollectionViewDataSource alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInit
{
    VNoContentCollectionViewCellFactory *testProvider = [[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:@[[NSDictionary class]]];
    XCTAssert([testProvider isKindOfClass:[VNoContentCollectionViewCellFactory class]], @"VNoContentCollectionViewCellFactory should return a fully formed VNoContentCollectionViewCellFactory from initWithAcceptableContentClasses");
    XCTAssertThrows([[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:nil], @"VNoContentCollectionViewCellFactory should throw an error when init-ed with nil acceptableContentClasses");
}

- (void)testRegister
{
    XCTAssertThrows([self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:nil], @"registerNoContentCellWithCollectionView: should throw an error when provided a nil collectionView");
}

- (void)testCellSize
{
    CGSize cellSize = [self.noContentCollectionViewCellFactory cellSizeForCollectionViewBounds:CGRectMake(0, 0, 100, 100)];
    XCTAssert(!CGSizeEqualToSize(cellSize, CGSizeZero), @"VNoContentCollectionViewCellFactory should provide a nonzero cell size for nonzero bounds");
}

- (void)testNoContentCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.collectionView.dataSource = self.collectionViewDataSource;
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:self.collectionView];
    UICollectionViewCell *noContentCell = [self.noContentCollectionViewCellFactory noContentCellForCollectionView:self.collectionView atIndexPath:indexPath];
    
    XCTAssert([noContentCell isKindOfClass:[UICollectionViewCell class]], @"VNoContentCollectionViewCellFactory should return a valid UICollectionViewCell from noContentCellForCollectionView:atIndexPath:");
    XCTAssertThrows([self.noContentCollectionViewCellFactory noContentCellForCollectionView:nil atIndexPath:indexPath]);
    XCTAssertThrows([self.noContentCollectionViewCellFactory noContentCellForCollectionView:self.collectionView atIndexPath:nil]);
}

- (void)testShouldDisplayNoContentCellForClass
{
    Class validContentClass = [NSDictionary class];
    VNoContentCollectionViewCellFactory *testProvider = [[VNoContentCollectionViewCellFactory alloc] initWithAcceptableContentClasses:@[validContentClass]];
    XCTAssertFalse([testProvider shouldDisplayNoContentCellForContentClass:validContentClass], @"shouldDisplayNoContent should return YES when passed a class provided to it's initWithAcceptableContentClasses: method");
    XCTAssert([testProvider shouldDisplayNoContentCellForContentClass:[NSString class]], @"shouldDisplayNoContent should return NO when passed a class NOT provided to it's initWithAcceptableContentClasses: method");
    XCTAssert([testProvider shouldDisplayNoContentCellForContentClass:nil], @"shouldDisplayNoContent should return NO when passed nil");
}

- (void)testIsNoContentCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.collectionView.dataSource = self.collectionViewDataSource;
    [self.noContentCollectionViewCellFactory registerNoContentCellWithCollectionView:self.collectionView];
    UICollectionViewCell *noContentCell = [self.noContentCollectionViewCellFactory noContentCellForCollectionView:self.collectionView atIndexPath:indexPath];
    
    XCTAssert([VNoContentCollectionViewCellFactory isNoContentCell:noContentCell], @"isNoContentCell: should return YES when passed a cell from noContentCellForCollectionView:atIndexPath:");
    XCTAssertFalse([VNoContentCollectionViewCellFactory isNoContentCell:nil], @"isNoContentCell: should return NO when passed a nil cell");
    XCTAssertFalse([VNoContentCollectionViewCellFactory isNoContentCell:[[UICollectionViewCell alloc] init]], @"isNoContentCell: should return NO when passed a cell that isn't a no content view cell");
}

@end
