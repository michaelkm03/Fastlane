//
//  VNoContentCollectionViewControllerProviderTests.m
//  victorious
//
//  Created by Sharif Ahmed on 4/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VNoContentCollectionViewCellProvider.h"

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

@interface VNoContentCollectionViewControllerProviderTests : XCTestCase

@property (nonatomic, strong) VNoContentCollectionViewCellProvider *noContentCollectionViewCellProvider;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) VDummyCollectionViewDataSource *collectionViewDataSource;

@end

@implementation VNoContentCollectionViewControllerProviderTests

- (void)setUp
{
    [super setUp];
    self.noContentCollectionViewCellProvider = [[VNoContentCollectionViewCellProvider alloc] initWithAcceptableContentClasses:@[[NSDictionary class]]];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    self.collectionViewDataSource = [[VDummyCollectionViewDataSource alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testInit
{
    VNoContentCollectionViewCellProvider *testProvider = [[VNoContentCollectionViewCellProvider alloc] initWithAcceptableContentClasses:@[[NSDictionary class]]];
    XCTAssert([testProvider isKindOfClass:[VNoContentCollectionViewCellProvider class]], @"VNoContentCollectionViewCellProvider should return a fully formed VNoContentCollectionViewCellProvider from initWithAcceptableContentClasses");
    XCTAssertThrows([[VNoContentCollectionViewCellProvider alloc] initWithAcceptableContentClasses:nil], @"VNoContentCollectionViewCellProvider should throw an error when init-ed with nil acceptableContentClasses");
}

- (void)testRegister
{
    XCTAssertThrows([self.noContentCollectionViewCellProvider registerNoContentCellWithCollectionView:nil], @"registerNoContentCellWithCollectionView: should throw an error when provided a nil collectionView");
}

- (void)testCellSize
{
    CGSize cellSize = [self.noContentCollectionViewCellProvider cellSizeForCollectionViewBounds:CGRectMake(0, 0, 100, 100)];
    XCTAssert(!CGSizeEqualToSize(cellSize, CGSizeZero), @"VNoContentCollectionViewCellProvider should provide a nonzero cell size for nonzero bounds");
}

- (void)testNoContentCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.collectionView.dataSource = self.collectionViewDataSource;
    [self.noContentCollectionViewCellProvider registerNoContentCellWithCollectionView:self.collectionView];
    UICollectionViewCell *noContentCell = [self.noContentCollectionViewCellProvider noContentCellForCollectionView:self.collectionView atIndexPath:indexPath];
    
    XCTAssert([noContentCell isKindOfClass:[UICollectionViewCell class]], @"VNoContentCollectionViewCellProvider should return a valid UICollectionViewCell from noContentCellForCollectionView:atIndexPath:");
    XCTAssertThrows([self.noContentCollectionViewCellProvider noContentCellForCollectionView:nil atIndexPath:indexPath]);
    XCTAssertThrows([self.noContentCollectionViewCellProvider noContentCellForCollectionView:self.collectionView atIndexPath:nil]);
}

- (void)testShouldDisplayNoContentCellForClass
{
    Class validContentClass = [NSDictionary class];
    VNoContentCollectionViewCellProvider *testProvider = [[VNoContentCollectionViewCellProvider alloc] initWithAcceptableContentClasses:@[validContentClass]];
    XCTAssertFalse([testProvider shouldDisplayNoContentCellForContentClass:validContentClass], @"shouldDisplayNoContent should return YES when passed a class provided to it's initWithAcceptableContentClasses: method");
    XCTAssert([testProvider shouldDisplayNoContentCellForContentClass:[NSString class]], @"shouldDisplayNoContent should return NO when passed a class NOT provided to it's initWithAcceptableContentClasses: method");
    XCTAssert([testProvider shouldDisplayNoContentCellForContentClass:nil], @"shouldDisplayNoContent should return NO when passed nil");
}

- (void)testIsNoContentCell
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    self.collectionView.dataSource = self.collectionViewDataSource;
    [self.noContentCollectionViewCellProvider registerNoContentCellWithCollectionView:self.collectionView];
    UICollectionViewCell *noContentCell = [self.noContentCollectionViewCellProvider noContentCellForCollectionView:self.collectionView atIndexPath:indexPath];
    
    XCTAssert([VNoContentCollectionViewCellProvider isNoContentCell:noContentCell], @"isNoContentCell: should return YES when passed a cell from noContentCellForCollectionView:atIndexPath:");
    XCTAssertFalse([VNoContentCollectionViewCellProvider isNoContentCell:nil], @"isNoContentCell: should return NO when passed a nil cell");
    XCTAssertFalse([VNoContentCollectionViewCellProvider isNoContentCell:[[UICollectionViewCell alloc] init]], @"isNoContentCell: should return NO when passed a cell that isn't a no content view cell");
}

@end
