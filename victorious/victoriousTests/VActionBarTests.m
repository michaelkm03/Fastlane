//
//  VActionBarTests.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VActionBar.h"

#import "UIView+Autolayout.h"

@class VActionBarFlexibleSpaceItem;
@class VActionBarFixedWidthItem;

@interface VActionBar (tests)

- (CGFloat)flexibleSpaceWidthWithFlexibleItemCount:(NSInteger)numberOfFlexibleItems
                                 widthToDistribute:(CGFloat)width;

- (NSInteger)flexibleItemCountFromItems:(NSArray *)items;

- (void)applyFlexibleItemWith:(CGFloat)flexibleItemWidth
       toFlexibleItemsInItems:(NSArray *)items;

- (CGFloat)remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:(NSArray *)items
                                                              fromWidth:(CGFloat)width;

@end

@interface VActionBarTests : XCTestCase

@property (nonatomic, strong) VActionBar *actionBar;

@end

@implementation VActionBarTests

- (void)setUp
{
    [super setUp];
    self.actionBar = [[VActionBar alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
    self.actionBar.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionBar v_addWidthConstraint:300.0f];
    [self.actionBar v_addHeightConstraint:50.0f];
}

- (void)testFlexibleSpaceComputations
{
    CGFloat calculatedFlexSpace = [self.actionBar flexibleSpaceWidthWithFlexibleItemCount:5
                                                                        widthToDistribute:300];
    XCTAssertEqual( calculatedFlexSpace, 60);
    
    calculatedFlexSpace = [self.actionBar flexibleSpaceWidthWithFlexibleItemCount:2
                                                                widthToDistribute:600];
    XCTAssertEqual( calculatedFlexSpace, 300);
    
    calculatedFlexSpace = [self.actionBar flexibleSpaceWidthWithFlexibleItemCount:3
                                                                widthToDistribute:100];
    XCTAssertEqual( calculatedFlexSpace, 33.0f);
}

- (void)testValidData
{
    UIView *testView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.actionBar setActionItems:@[testView]];
    
    [self.actionBar setActionItems:@[[VActionBar flexibleSpaceItem],
                                     testView,
                                     [VActionBar flexibleSpaceItem]]];
}

- (void)testInvalidItems
{
    XCTAssertThrows([self.actionBar setActionItems:@[@"badData"]]);
    XCTAssertThrows([self.actionBar setActionItems:@[[NSNull null]]]);
}

- (void)testflexibleItemCountFromItems
{
    NSInteger numberOfFlexibleItems = [self.actionBar flexibleItemCountFromItems:@[]];
    XCTAssertEqual(numberOfFlexibleItems, 0);
    
    numberOfFlexibleItems = [self.actionBar flexibleItemCountFromItems:@[[VActionBar flexibleSpaceItem]]];
    XCTAssertEqual(numberOfFlexibleItems, 1);
    
    numberOfFlexibleItems = [self.actionBar flexibleItemCountFromItems:@[[VActionBar flexibleSpaceItem],
                                                                         [VActionBar flexibleSpaceItem],
                                                                         [VActionBar flexibleSpaceItem],
                                                                         [VActionBar flexibleSpaceItem],
                                                                         [VActionBar flexibleSpaceItem]]];
    XCTAssertEqual(numberOfFlexibleItems, 5);
}

- (void)testApplyFlexibleItemWithToFlexibleItems
{
    VActionBarFlexibleSpaceItem *flexItem1 = [VActionBar flexibleSpaceItem];
    VActionBarFlexibleSpaceItem *flexItem2 = [VActionBar flexibleSpaceItem];
    VActionBarFlexibleSpaceItem *flexItem3 = [VActionBar flexibleSpaceItem];
    VActionBarFlexibleSpaceItem *flexItem4 = [VActionBar flexibleSpaceItem];
    
    [self.actionBar applyFlexibleItemWith:50 toFlexibleItemsInItems:@[flexItem1,
                                                                      flexItem2,
                                                                      flexItem3,
                                                                      flexItem4]];
    
    XCTAssertEqual([flexItem1 v_internalWidthConstraint].constant, 50);
    XCTAssertEqual([flexItem2 v_internalWidthConstraint].constant, 50);
    XCTAssertEqual([flexItem3 v_internalWidthConstraint].constant, 50);
    XCTAssertEqual([flexItem4 v_internalWidthConstraint].constant, 50);
}

- (void)testRemainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItemsNoItems
{
    CGFloat totalWidth = 300.0f;
    CGFloat calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(totalWidth, calculatedRemainingSpace);
}

- (void)testRemainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItemsOneItem
{
    CGFloat totalWidth = 300.0f;
    CGFloat fixedItemWidth = 50.0f;
    CGFloat defaultItemWidth = 44.0f; // ATTENTION! This must be the same as VActionBar's internal constant: kDefaultActionItemWidth
    CGFloat expectedWidth = totalWidth - fixedItemWidth;
    
    // Test flex ignoring
    CGFloat calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[[VActionBar flexibleSpaceItem]]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth);
    
    // Test fixedWidthItem
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBar fixedWidthItemWithWidth:fixedItemWidth];
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[fixedWidthItem]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, expectedWidth);
    
    // Test View with internal width
    UIView *viewWithWidthConstraint = [[UIView alloc] initWithFrame:CGRectZero];
    [viewWithWidthConstraint v_addWidthConstraint:fixedItemWidth];
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[viewWithWidthConstraint]
                                                                                                  fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, expectedWidth);
    
    // Test intrinsic content size
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    testLabel.text = @"test";
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[testLabel]
                                                                                                  fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - testLabel.intrinsicContentSize.width);
    
    // Test default item width
    UIView *viewWithNoIntrinsicContentSizeOrInternalWidthConstraint = [[UIView alloc] initWithFrame:CGRectZero];
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[viewWithNoIntrinsicContentSizeOrInternalWidthConstraint]
                                                                                                  fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - defaultItemWidth);
}

- (void)testRemainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItemsManyItems
{
    CGFloat totalWidth = 300.0f;
    CGFloat fixedItemWidth = 50.0f;
    CGFloat defaultItemWidth = 44.0f; // ATTENTION! This must be the same as VActionBar's internal constant: kDefaultActionItemWidth
    
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBar fixedWidthItemWithWidth:fixedItemWidth];
    UIView *viewWithNoIntrinsicContentSizeOrInternalWidthConstraint = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    testLabel.text = @"test";
    
    // Test fixed item + default item
    CGFloat calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[fixedWidthItem, viewWithNoIntrinsicContentSizeOrInternalWidthConstraint]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - fixedItemWidth - defaultItemWidth);
    
    // Test fixed item + Intrinsic Content Size
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[fixedWidthItem, testLabel]
                                                                                                  fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - fixedItemWidth - testLabel.intrinsicContentSize.width);
    
    // Test default item + intrinsic content size
    calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[fixedWidthItem, testLabel]
                                                                                                  fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - fixedItemWidth - testLabel.intrinsicContentSize.width);
}

- (void)testVisual
{
    self.actionBar.backgroundColor = [UIColor whiteColor];

    // Test variables
    UIView *redSquare = [[UIView alloc] initWithFrame:CGRectZero];
    redSquare.backgroundColor = [UIColor redColor];
    redSquare.translatesAutoresizingMaskIntoConstraints = NO;
    [redSquare v_addWidthConstraint:20.0f];
    [redSquare v_addHeightConstraint:20.0f];
    UIView *redSquare2 = [[UIView alloc] initWithFrame:CGRectZero];
    redSquare2.backgroundColor = [UIColor redColor];
    redSquare2.translatesAutoresizingMaskIntoConstraints = NO;
    [redSquare2 v_addWidthConstraint:20.0f];
    [redSquare2 v_addHeightConstraint:20.0f];
    UIView *redSquare3 = [[UIView alloc] initWithFrame:CGRectZero];
    redSquare3.backgroundColor = [UIColor redColor];
    redSquare3.translatesAutoresizingMaskIntoConstraints = NO;
    [redSquare3 v_addWidthConstraint:20.0f];
    [redSquare3 v_addHeightConstraint:20.0f];
    
    // Test square in middle
    self.actionBar.actionItems = @[[VActionBar flexibleSpaceItem], redSquare, [VActionBar flexibleSpaceItem]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMidX(self.actionBar.bounds), CGRectGetMidX(redSquare.frame));
    
    // Test red square on left
    self.actionBar.actionItems = @[redSquare, [VActionBar flexibleSpaceItem]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(self.actionBar.bounds), CGRectGetMinX(redSquare.frame));
    
    // Test red square on right
    self.actionBar.actionItems = @[[VActionBar flexibleSpaceItem], redSquare];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMaxX(self.actionBar.bounds), CGRectGetMaxX(redSquare.frame));

    // Test leading middle and trailing red squares
    self.actionBar.actionItems = @[redSquare, [VActionBar flexibleSpaceItem], redSquare2, [VActionBar flexibleSpaceItem], redSquare3];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(redSquare.frame), CGRectGetMinX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMidX(redSquare2.frame), CGRectGetMidX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMaxX(redSquare3.frame), CGRectGetMaxX(self.actionBar.bounds));

    // Test leading middle and trailing red squres with fixed edges
    CGFloat fixedEdgeWidth = 20.0f;
    self.actionBar.actionItems = @[[VActionBar fixedWidthItemWithWidth:fixedEdgeWidth], redSquare, [VActionBar flexibleSpaceItem], redSquare2, [VActionBar flexibleSpaceItem], redSquare3, [VActionBar fixedWidthItemWithWidth:fixedEdgeWidth]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(redSquare.frame), CGRectGetMinX(self.actionBar.bounds) + fixedEdgeWidth);
    XCTAssertEqual(CGRectGetMidX(redSquare2.frame), CGRectGetMidX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMaxX(redSquare3.frame), CGRectGetMaxX(self.actionBar.bounds) - fixedEdgeWidth);

    // Test fixed widith item + default item + intrinsic content size
    CGFloat fixedItemWidth = 50.0f;
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBar fixedWidthItemWithWidth:fixedItemWidth];
    UIView *viewWithNoIntrinsicContentSizeOrInternalWidthConstraint = [[UIView alloc] initWithFrame:CGRectZero];
    viewWithNoIntrinsicContentSizeOrInternalWidthConstraint.translatesAutoresizingMaskIntoConstraints = NO;
    viewWithNoIntrinsicContentSizeOrInternalWidthConstraint.backgroundColor = [UIColor redColor];
    [viewWithNoIntrinsicContentSizeOrInternalWidthConstraint v_addHeightConstraint:20.0f];
    
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    testLabel.translatesAutoresizingMaskIntoConstraints = NO;
    testLabel.text = @"test";
    testLabel.textColor = [UIColor greenColor];
    
    self.actionBar.actionItems = @[fixedWidthItem, viewWithNoIntrinsicContentSizeOrInternalWidthConstraint, testLabel];
}

@end
