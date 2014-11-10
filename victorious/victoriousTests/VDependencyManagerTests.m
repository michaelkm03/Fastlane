//
//  VDependencyManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 11/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VSideMenuViewController.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString * const kTestViewControllerInitMethodTemplateName = @"testInitMethod";
static NSString * const kTestViewControllerNewMethodTemplateName = @"testNewMethod";

#pragma mark - VTestViewControllerWithInitMethod

@interface VTestViewControllerWithInitMethod : UIViewController <VHasManagedDependancies>

@property (nonatomic) BOOL calledInitMethod;

@end

@implementation VTestViewControllerWithInitMethod

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _calledInitMethod = YES;
    }
    return self;
}

@end

#pragma mark - VTestViewControllerWithNewMethod

@interface VTestViewControllerWithNewMethod : UIViewController <VHasManagedDependancies>

@property (nonatomic) BOOL calledNewMethod;

@end

@implementation VTestViewControllerWithNewMethod

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VTestViewControllerWithNewMethod *vc = [[VTestViewControllerWithNewMethod alloc] init];
    vc.calledNewMethod = YES;
    return vc;
}

@end

#pragma mark -

@interface VDependencyManagerTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VDependencyManager *childDependencyManager;

@end

@implementation VDependencyManagerTests

- (void)setUp
{
    [super setUp];
    
    NSDictionary *dictionaryOfClassesByTemplateName = @{ kTestViewControllerInitMethodTemplateName: @"VTestViewControllerWithInitMethod",
                                                         kTestViewControllerNewMethodTemplateName: @"VTestViewControllerWithNewMethod" };
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:configuration dictionaryOfClassesByTemplateName:dictionaryOfClassesByTemplateName];
    self.childDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:@{} dictionaryOfClassesByTemplateName:dictionaryOfClassesByTemplateName];
}

- (void)testColor
{
    UIColor *expected = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *actual = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testParentColor
{
    UIColor *expected = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    UIColor *actual = [self.childDependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testFont
{
    UIFont *expected = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
    UIFont *actual = [self.dependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testParentFont
{
    UIFont *expected = [UIFont fontWithName:@"STHeitiSC-Light" size:18];
    UIFont *actual = [self.childDependencyManager fontForKey:VDependencyManagerHeaderFontKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildFontOverridesParent
{
    NSDictionary *configuration = @{ @"font.heading1": @{ @"fontName": @"Helvetica", @"fontSize": @12 } };
    self.childDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:configuration dictionaryOfClassesByTemplateName:nil];
    
    UIFont *expected = [UIFont fontWithName:@"Helvetica" size:12];
    UIFont *actual = [self.childDependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testViewControllerWithInitMethod
{
    id viewController = [self.dependencyManager viewControllerForKey:@"ivc"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    XCTAssert([viewController calledInitMethod]);
}

- (void)testViewControllerWithNewMethod
{
    id viewController = [self.dependencyManager viewControllerForKey:@"nvc"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
}

- (void)testString
{
    NSString *expected = @"medium";
    NSString *actual = [self.dependencyManager stringForKey:@"video_quality.capture"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildString
{
    NSString *expected = @"medium";
    NSString *actual = [self.childDependencyManager stringForKey:@"video_quality.capture"];
    XCTAssertEqualObjects(expected, actual);
}

@end
