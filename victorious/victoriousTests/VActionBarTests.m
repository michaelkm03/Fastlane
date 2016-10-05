//
//  VActionBarTests.m
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

// VActionBar
#import "VFlexBar.h"
#import "VActionBarFixedWidthItem.h"

// Layout Helpers
#import "UIView+Autolayout.h"

#import "victorious-Swift.h"

static CGFloat kDefaultItemWidth = 44.0f; // ATTENTION! This must be the same as VActionBar's internal constant: kDefaultActionItemWidth

@class ActionBarFlexibleSpaceItem;
@class VActionBarFixedWidthItem;

@interface VFlexBar (tests)

- (CGFloat)flexibleSpaceWidthWithFlexibleItemCount:(NSInteger)numberOfFlexibleItems
                                 widthToDistribute:(CGFloat)width;

- (NSInteger)flexibleItemCountFromItems:(NSArray *)items;

- (void)applyFlexibleItemWith:(CGFloat)flexibleItemWidth
       toFlexibleItemsInItems:(NSArray *)items;

- (CGFloat)remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:(NSArray *)items
                                                              fromWidth:(CGFloat)width;

@end

@interface VActionBarTests : XCTestCase

@property (nonatomic, strong) VFlexBar *actionBar;

@end

@implementation VActionBarTests

- (void)setUp
{
    [super setUp];
    self.actionBar = [[VFlexBar alloc] initWithFrame:CGRectMake(0, 0, 300, 50)];
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
    
    [self.actionBar setActionItems:@[[ActionBarFlexibleSpaceItem flexibleSpaceItem],
                                     testView,
                                     [ActionBarFlexibleSpaceItem flexibleSpaceItem]]];
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
    
    numberOfFlexibleItems = [self.actionBar flexibleItemCountFromItems:@[[ActionBarFlexibleSpaceItem flexibleSpaceItem]]];
    XCTAssertEqual(numberOfFlexibleItems, 1);
    
    numberOfFlexibleItems = [self.actionBar flexibleItemCountFromItems:@[[ActionBarFlexibleSpaceItem flexibleSpaceItem],
                                                                         [ActionBarFlexibleSpaceItem flexibleSpaceItem],
                                                                         [ActionBarFlexibleSpaceItem flexibleSpaceItem],
                                                                         [ActionBarFlexibleSpaceItem flexibleSpaceItem],
                                                                         [ActionBarFlexibleSpaceItem flexibleSpaceItem]]];
    XCTAssertEqual(numberOfFlexibleItems, 5);
}

- (void)testApplyFlexibleItemWithToFlexibleItems
{
    ActionBarFlexibleSpaceItem *flexItem1 = [ActionBarFlexibleSpaceItem flexibleSpaceItem];
    ActionBarFlexibleSpaceItem *flexItem2 = [ActionBarFlexibleSpaceItem flexibleSpaceItem];
    ActionBarFlexibleSpaceItem *flexItem3 = [ActionBarFlexibleSpaceItem flexibleSpaceItem];
    ActionBarFlexibleSpaceItem *flexItem4 = [ActionBarFlexibleSpaceItem flexibleSpaceItem];
    
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
    
    #pragma mark -  test never goes negatvive
}

- (void)testRemainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItemsOneItem
{
    CGFloat totalWidth = 300.0f;
    CGFloat fixedItemWidth = 50.0f;

    CGFloat expectedWidth = totalWidth - fixedItemWidth;
    
    // Test flex ignoring
    CGFloat calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[[ActionBarFlexibleSpaceItem flexibleSpaceItem]]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth);
    
    // Test fixedWidthItem
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBarFixedWidthItem fixedWidthItemWithWidth:fixedItemWidth];
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
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - kDefaultItemWidth);
}

- (void)testRemainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItemsManyItems
{
    CGFloat totalWidth = 300.0f;
    CGFloat fixedItemWidth = 50.0f;
    
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBarFixedWidthItem fixedWidthItemWithWidth:fixedItemWidth];
    UIView *viewWithNoIntrinsicContentSizeOrInternalWidthConstraint = [[UIView alloc] initWithFrame:CGRectZero];
    UILabel *testLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    testLabel.text = @"test";
    
    // Test fixed item + default item
    CGFloat calculatedRemainingSpace = [self.actionBar remainingSpaceAfterFilteringFixedAndInstrinsicSpaceFromItems:@[fixedWidthItem, viewWithNoIntrinsicContentSizeOrInternalWidthConstraint]
                                                                                                          fromWidth:totalWidth];
    XCTAssertEqual(calculatedRemainingSpace, totalWidth - fixedItemWidth - kDefaultItemWidth);
    
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
    self.actionBar.actionItems = @[[ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare, [ActionBarFlexibleSpaceItem flexibleSpaceItem]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMidX(self.actionBar.bounds), CGRectGetMidX(redSquare.frame));
    
    // Test red square on left
    self.actionBar.actionItems = @[redSquare, [ActionBarFlexibleSpaceItem flexibleSpaceItem]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(self.actionBar.bounds), CGRectGetMinX(redSquare.frame));
    
    // Test red square on right
    self.actionBar.actionItems = @[[ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMaxX(self.actionBar.bounds), CGRectGetMaxX(redSquare.frame));

    // Test leading middle and trailing red squares
    self.actionBar.actionItems = @[redSquare, [ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare2, [ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare3];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(redSquare.frame), CGRectGetMinX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMidX(redSquare2.frame), CGRectGetMidX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMaxX(redSquare3.frame), CGRectGetMaxX(self.actionBar.bounds));

    // Test leading middle and trailing red squres with fixed edges
    CGFloat fixedEdgeWidth = 20.0f;
    self.actionBar.actionItems = @[[VActionBarFixedWidthItem fixedWidthItemWithWidth:fixedEdgeWidth], redSquare, [ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare2, [ActionBarFlexibleSpaceItem flexibleSpaceItem], redSquare3, [VActionBarFixedWidthItem fixedWidthItemWithWidth:fixedEdgeWidth]];
    [self.actionBar layoutIfNeeded];
    XCTAssertEqual(CGRectGetMinX(redSquare.frame), CGRectGetMinX(self.actionBar.bounds) + fixedEdgeWidth);
    XCTAssertEqual(CGRectGetMidX(redSquare2.frame), CGRectGetMidX(self.actionBar.bounds));
    XCTAssertEqual(CGRectGetMaxX(redSquare3.frame), CGRectGetMaxX(self.actionBar.bounds) - fixedEdgeWidth);

    // Test fixed widith item + default item + intrinsic content size
    CGFloat fixedItemWidth = 50.0f;
    VActionBarFixedWidthItem *fixedWidthItem = [VActionBarFixedWidthItem fixedWidthItemWithWidth:fixedItemWidth];
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
