//
//  VCoachmarkManagerTests.m
//  victorious
//
//  Created by Sharif Ahmed on 5/22/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VCoachmarkManager.h"
#import "VDependencyManager.h"
#import "VCoachmarkDisplayer.h"
#import "VCoachmarkDisplayResponder.h"
#import "VNavigationController.h"
#import "VCoachmarkPassthroughContainerView.h"
#import "VCoachmarkView.h"
#import "VCoachmark.h"

static NSString * const kShownCoachmarksKey = @"shownCoachmarks";
static const CGFloat kAnimationDelay = 1.0f;
static const CGFloat kArrowToLocationDistance = 5.0f; //Match to kCoachmarkVerticalInset in VCoachmarkManager
static const CGFloat kScreenHeight = 600;
static const CGRect kLowRect = { { 0.0f, kScreenHeight }, { 0.0f, 0.0f } };
static const CGRect kHighRect = { { 0.0f, 0.0f }, { 0.0f, 0.0f } };

#pragma mark - Responder

@interface CoachmarkDisplayResponder : UIResponder <VCoachmarkDisplayResponder>

@property (nonatomic, assign) BOOL returnHigh;

@end

@implementation CoachmarkDisplayResponder

- (void)findOnScreenMenuItemWithIdentifier:(NSString *)identifier andCompletion:(VMenuItemDiscoveryBlock)completion
{
    CGRect targetLocation = kLowRect;
    if ( self.returnHigh )
    {
        targetLocation = kHighRect;
    }
    completion(YES, targetLocation);
}

@end

#pragma mark - View controller

@interface CoachmarkDisplayerViewController : UIViewController <VCoachmarkDisplayer>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSString *screenIdentifier;
@property (nonatomic, strong) VNavigationController *v_navigationController;
@property (nonatomic, assign) BOOL returnNilNextResponder;
@property (nonatomic, assign) BOOL returnHigh;

@end

@implementation CoachmarkDisplayerViewController

- (UIResponder *)nextResponder
{
    if ( self.returnNilNextResponder )
    {
        return nil;
    }
    CoachmarkDisplayResponder *responder = [[CoachmarkDisplayResponder alloc] init];
    responder.returnHigh = self.returnHigh;
    return responder;
}

@end

#pragma mark - Tests

@interface VCoachmarkManagerTests : XCTestCase

@property (nonatomic, strong) VCoachmarkManager *coachmarkManager;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VCoachmarkManagerTests

- (void)setUp
{
    [super setUp];
    
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:[[NSBundle bundleForClass:[self class]] pathForResource:@"coachmarks" ofType:@"json"]] options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:configuration dictionaryOfClassesByTemplateName:nil];
    self.coachmarkManager = [[VCoachmarkManager alloc] initWithDependencyManager:self.dependencyManager];
    [self.coachmarkManager resetShownCoachmarks];
    self.coachmarkManager.allowCoachmarks = YES;
}

- (void)tearDown
{
    self.dependencyManager = nil;
    self.coachmarkManager = nil;
    [super tearDown];
}

#pragma mark - Init tests

- (void)testInit
{
    XCTAssertNotNil([[NSUserDefaults standardUserDefaults] objectForKey:kShownCoachmarksKey], @"resetShownCoachmarks should set an array to 'shownCoachmarks' in the standard user defaults on successful init");
}

- (void)testInitWithBadParams
{
    XCTAssertThrows([[VCoachmarkManager alloc] initWithDependencyManager:nil], @"initWithDependencyManager: should assert a failure when a nil dependencyManager is provided");
}

#pragma mark - Reset test

- (void)testResetShownCoachmarks
{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:@[@"1"] forKey:kShownCoachmarksKey];
    [userDefaults synchronize];
    
    [self.coachmarkManager resetShownCoachmarks];
    NSArray *storedCoachmarks = [userDefaults objectForKey:kShownCoachmarksKey];
    XCTAssertNotNil(storedCoachmarks, @"resetShownCoachmarks should set an array to 'shownCoachmarks' in the standard user defaults after reset");
    XCTAssertEqual([storedCoachmarks count], 0ul, @"resetShownCoachmarks should set an array to 'shownCoachmarks' in the standard user defaults after reset");
}

#pragma mark - Display coachmark tests

- (void)testDisplayCoachmarkViewInViewController
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"0"; //Has no valid coachmarks to display
    BOOL added = [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTAssertFalse(added, @"displayCoachmarkViewInViewController: should return NO when it is not going to add a coachmark view to a view controller");
    
    viewController.screenIdentifier = @"1"; //Has at least 1 valid coachmark to display
    added = [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTAssert(added, @"displayCoachmarkViewInViewController: should return YES when it is going to add a coachmark view to a view controller");
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"displayExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       BOOL foundSubview = NO;
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               foundSubview = YES;
                               break;
                           }
                       }
                       XCTAssert(foundSubview, @"The coachmarkManager should add a coachmark passthrough container view to the view controller's view after the animation delay");
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

- (void)testDisplayCoachmarkInViewControllerTooltip
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"4"; //Has at least 1 valid coachmark to display
    BOOL added = [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTAssert(added, @"displayCoachmarkViewInViewController: should be able to add a coachmark as a tooltip if something in the responder chain finds the view");
    
    [self.coachmarkManager resetShownCoachmarks];
    viewController.returnNilNextResponder = YES;
    added = [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTAssertFalse(added, @"displayCoachmarkViewInViewController: should not be able to add a coachmark as a tooltip if nothing in the responder chain finds the view");
}

- (void)testDisplayCoachmarkViewInViewControllerWithNavigationController
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    VNavigationController *navigationController = [[VNavigationController alloc] initWithNibName:nil bundle:nil];
    viewController.v_navigationController = navigationController;
    viewController.screenIdentifier = @"1";
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTestExpectation *expectation = [self expectationWithDescription:@"navigationDisplayExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       BOOL foundSubview = NO;
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               foundSubview = YES;
                               break;
                           }
                       }
                       XCTAssertFalse(foundSubview, @"The coachmarkManager should not add a coachmark passthrough container view to the view controller's view after the animation delay");
                       
                       foundSubview = NO;
                       for ( UIView *subview in navigationController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               foundSubview = YES;
                               break;
                           }
                       }
                       XCTAssert(foundSubview, @"The coachmarkManager should add a coachmark passthrough container view to the navigation controller's view after the animation delay");
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

#pragma mark - Display order and uniqueness tests

- (void)testDisplayCoachmarkInViewControllerInOrder
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"1"; //Has 2 valid coachmarks to display
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"displayOrderExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       __block UIView *firstView = nil;
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               NSString *coachmarkId = ((VCoachmarkPassthroughContainerView *)subview).coachmarkView.coachmark.remoteId;
                               XCTAssertEqualObjects(coachmarkId, @"10", @"displayCoachmarkViewInViewController: should display available coachmarks in order");
                               firstView = subview;
                               break;
                           }
                       }
                       
                       [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
                       dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                                      {
                                          for ( UIView *subview in viewController.view.subviews )
                                          {
                                              if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                                              {
                                                  if ( [subview isEqual:firstView] )
                                                  {
                                                      continue;
                                                  }
                                                  
                                                  NSString *coachmarkId = ((VCoachmarkPassthroughContainerView *)subview).coachmarkView.coachmark.remoteId;
                                                  XCTAssertEqualObjects(coachmarkId, @"12", @"displayCoachmarkViewInViewController: should display available coachmarks in order");
                                                  break;
                                              }
                                          }
                                          [expectation fulfill];
                                      });
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 3 handler:nil];
}

- (void)testDisplayToastBeforeTooltip
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"2"; //Has 2 valid coachmarks to display, with a tooltip BEFORE a toast
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"toastPreferenceExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               NSString *coachmarkId = ((VCoachmarkPassthroughContainerView *)subview).coachmarkView.coachmark.remoteId;
                               XCTAssertEqualObjects(coachmarkId, @"11", @"displayCoachmarkViewInViewController: should display toast before tooltip coachmarks");
                               break;
                           }
                       }
                       [expectation fulfill];
                    });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

- (void)testDisplayCoachmarkInViewControllerViewUniqueness
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"3"; //Only has 1 valid coachmark to display
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    XCTestExpectation *expectation = [self expectationWithDescription:@"uniqueCoachmarkExpectation"];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       BOOL added = [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
                       XCTAssertFalse(added, @"displayCoachmarkViewInViewController: should not re-add the same coachmark view multiple times");
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

#pragma mark - Display location tests

- (void)testToastLocations
{
    NSMutableDictionary *coachmarkViews = [[NSMutableDictionary alloc] init];
    XCTestExpectation *expectation = [self expectationWithDescription:@"toastLocationExpectation"];
    for ( NSInteger i = 1; i < 4; i++ )
    {
        CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
        viewController.view.frame = CGRectMake(0, 0, kScreenHeight, kScreenHeight);
        NSString *screenIdentifier = [NSString stringWithFormat:@"%ld", (long)i];
        viewController.screenIdentifier = screenIdentifier;
        [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                       {
                           for ( UIView *subview in viewController.view.subviews )
                           {
                               if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                               {
                                   coachmarkViews[screenIdentifier] = [NSValue valueWithCGRect:((VCoachmarkPassthroughContainerView *)subview).coachmarkView.frame];
                                   break;
                               }
                           }
                           
                           if ( coachmarkViews.count == 3 )
                           {
                               CGFloat topY = CGRectGetMinY([coachmarkViews[@"1"] CGRectValue]);
                               CGFloat middleY = CGRectGetMinY([coachmarkViews[@"2"] CGRectValue]);
                               CGFloat bottomY = CGRectGetMinY([coachmarkViews[@"3"] CGRectValue]);

                               XCTAssert(middleY > topY, @"Toast coachmarks with location top should be above coachmarks with location middle");
                               XCTAssert(bottomY > middleY, @"Toast coachmarks with location middle should be above coachmarks with location bottom");
                               [expectation fulfill];
                           }
                       });
    }
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

- (void)testTooltipLocation
{
    CoachmarkDisplayerViewController *viewController1 = [[CoachmarkDisplayerViewController alloc] init]; //For testing down arrow
    viewController1.view.frame = CGRectMake(0, 0, kScreenHeight, kScreenHeight);
    viewController1.screenIdentifier = @"4"; //Only has a tooltip to display
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController1];
    
    CoachmarkDisplayerViewController *viewController2 = [[CoachmarkDisplayerViewController alloc] init]; //For testing up arrow
    viewController2.view.frame = CGRectMake(0, 0, kScreenHeight, kScreenHeight);
    viewController2.returnHigh = YES;
    viewController2.screenIdentifier = @"5"; //Only has a tooltip to display
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController2];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"tooltipLocationExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       for ( UIView *subview in viewController1.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               VCoachmarkView *coachmarkView = ((VCoachmarkPassthroughContainerView *)subview).coachmarkView;
                               XCTAssertEqual(coachmarkView.arrowDirection, VTooltipArrowDirectionDown, @"tooltip arrow direction should be down when the center of the target rect is more than halfway down the screen displaying it");
                               CGRect tooltipFrame = coachmarkView.frame;
                               tooltipFrame = CGRectInset(tooltipFrame, 0, - (kArrowToLocationDistance + 1.0f)); //1.0f for intersection
                               XCTAssert(CGRectIntersectsRect(tooltipFrame, kLowRect));
                               break;
                           }
                       }
                       
                       for ( UIView *subview in viewController2.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               VCoachmarkView *coachmarkView = ((VCoachmarkPassthroughContainerView *)subview).coachmarkView;
                               XCTAssertEqual(coachmarkView.arrowDirection, VTooltipArrowDirectionUp, @"tooltip arrow direction should be up when the center of the target rect is less than halfway down the screen displaying it");
                               CGRect tooltipFrame = coachmarkView.frame;
                               tooltipFrame = CGRectInset(tooltipFrame, 0, - (kArrowToLocationDistance + 1.0f)); //1.0f for intersection
                               XCTAssert(CGRectIntersectsRect(tooltipFrame, kHighRect));
                               break;
                           }
                       }
                       
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

#pragma mark - Hide coachmark tests

- (void)testDisplayCoachmarkInViewControllerViewCancel
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"1";
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    [self.coachmarkManager hideCoachmarkViewInViewController:viewController animated:NO];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"displayCoachmarkCancelExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       BOOL foundSubview = NO;
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               foundSubview = YES;
                               break;
                           }
                       }
                       XCTAssertFalse(foundSubview, @"The coachmarkManager should not add a coachmark passthrough container view to the view controller's view if hide is called before it can display");
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

- (void)testHideCoachmarkViewInViewController
{
    CoachmarkDisplayerViewController *viewController = [[CoachmarkDisplayerViewController alloc] init];
    viewController.screenIdentifier = @"1";
    [self.coachmarkManager displayCoachmarkViewInViewController:viewController];
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"hideCoachmarkExpectation"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kAnimationDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^
                   {
                       BOOL foundSubview = NO;
                       for ( UIView *subview in viewController.view.subviews )
                       {
                           if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                           {
                               foundSubview = YES;
                               break;
                           }
                       }
                       XCTAssert(foundSubview, @"The coachmarkManager should add a coachmark passthrough container view to the view controller's view after the animation delay");
                       
                       if ( foundSubview )
                       {
                           [self.coachmarkManager hideCoachmarkViewInViewController:viewController animated:NO];
                           foundSubview = NO;
                           for ( UIView *subview in viewController.view.subviews )
                           {
                               if ( [subview isKindOfClass:[VCoachmarkPassthroughContainerView class]] )
                               {
                                   foundSubview = YES;
                                   break;
                               }
                           }
                           XCTAssertFalse(foundSubview, @"The coachmarkManager should remove the passthrough container view from the view controller's view after hideCoachmarkViewInViewController:animated: is called");
                       }
                       [expectation fulfill];
                   });
    [self waitForExpectationsWithTimeout:kAnimationDelay * 2 handler:nil];
}

@end
