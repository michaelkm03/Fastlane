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
static NSString * const kTestObjectWithPropertyTemplateName = @"testProperty";

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
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VTestViewControllerWithNewMethod

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager
{
    VTestViewControllerWithNewMethod *vc = [[VTestViewControllerWithNewMethod alloc] init];
    vc.calledNewMethod = YES;
    vc.dependencyManager = dependencyManager;
    return vc;
}

@end

#pragma mark - VTestObjectWithProperty

@interface VTestObjectWithProperty : NSObject <VHasManagedDependancies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VTestObjectWithProperty

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
                                                         kTestViewControllerNewMethodTemplateName: @"VTestViewControllerWithNewMethod",
                                                         kTestObjectWithPropertyTemplateName: @"VTestObjectWithProperty"
                                                      };
    
    // The presence of this "base" dependency manager (with an empty configuration dictionary) exposed a bug in a previous iteration of VDependencyManager.
    VDependencyManager *baseDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:@{} dictionaryOfClassesByTemplateName:dictionaryOfClassesByTemplateName];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:baseDependencyManager configuration:configuration dictionaryOfClassesByTemplateName:dictionaryOfClassesByTemplateName];
    self.childDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:@{} dictionaryOfClassesByTemplateName:dictionaryOfClassesByTemplateName];
}

#pragma mark - Colors, fonts

- (void)testColor
{
    UIColor *expected = [UIColor colorWithRed:0.2 green:0.6 blue:0.4 alpha:1];
    UIColor *actual = [self.dependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testParentColor
{
    UIColor *expected = [UIColor colorWithRed:0.2 green:0.6 blue:0.4 alpha:1];
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

#pragma mark - VHasManagedDependencies conformance

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

- (void)testViewControllerViaGenericMethod
{
    id viewController = [self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
}

- (void)testPropertySetter
{
    VTestObjectWithProperty *obj = [self.dependencyManager templateValueOfType:[VTestObjectWithProperty class] forKey:@"testProp"];
    XCTAssert([obj isKindOfClass:[VTestObjectWithProperty class]]);
    XCTAssertNotNil(obj.dependencyManager);
}

#pragma mark - Strings, numbers, arrays

- (void)testString
{
    NSString *expected = @"medium";
    NSString *actual = [self.dependencyManager stringForKey:@"video_quality.capture"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringViaGenericMethod
{
    NSString *expected = @"medium";
    NSString *actual = [self.dependencyManager templateValueOfType:[NSString class] forKey:@"video_quality.capture"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildString
{
    NSString *expected = @"medium";
    NSString *actual = [self.childDependencyManager stringForKey:@"video_quality.capture"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testNumber
{
    NSNumber *expected = @YES;
    NSNumber *actual = [self.dependencyManager numberForKey:@"experiments.require_profile_image"];
    XCTAssertNotNil(actual);
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildNumber
{
    NSNumber *expected = @NO;
    NSNumber *actual = [self.childDependencyManager numberForKey:@"experiments.histogram_enabled"];
    XCTAssertNotNil(actual);
    XCTAssertEqualObjects(expected, actual);
}

- (void)testArray
{
    NSArray *expected = @[ @"red", @"fish", @"blue", @"fish" ];
    NSArray *actual = [self.dependencyManager arrayForKey:@"arrayOfStrings"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildArray
{
    NSArray *expected = @[ @"red", @"fish", @"blue", @"fish" ];
    NSArray *actual = [self.childDependencyManager arrayForKey:@"arrayOfStrings"];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - Instantiating objects via dictionaries and references

- (void)testObjectFromDictionary
{
    NSDictionary *configuration = @{ @"name": kTestViewControllerNewMethodTemplateName, @"one": @1, @"two": @2 };
    
    VTestViewControllerWithNewMethod *vc = (VTestViewControllerWithNewMethod *)[self.dependencyManager objectOfType:[UIViewController class] fromDictionary:configuration];
    XCTAssertNotNil(vc);
    XCTAssertEqualObjects([vc.dependencyManager numberForKey:@"one"], @1);
    XCTAssertEqualObjects([vc.dependencyManager numberForKey:@"two"], @2);
    XCTAssertEqualObjects([vc.dependencyManager numberForKey:@"experiments.require_profile_image"], @YES);
}

- (void)testReferencedObject
{
    id viewController = [self.dependencyManager viewControllerForKey:@"otherNVC"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
}

- (void)testDeepReference
{
    id viewController = [self.dependencyManager viewControllerForKey:@"deeplyReferencedNVC"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
}

- (void)testMissingReferenceReturnsNil
{
    id result = [self.dependencyManager templateValueOfType:[NSObject class] forKey:@"missingReference"];
    XCTAssertNil(result);
}

#pragma mark - Singletons

- (void)testSingletonObject
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testChildSingletonObject
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.childDependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testSingletonObjectWithoutID
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"ivc"];
    UIViewController *result2 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"ivc"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testChildSingletonObjectWithoutID
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"ivc"];
    UIViewController *result2 = [self.childDependencyManager singletonObjectOfType:[UIViewController class] forKey:@"ivc"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testSingletonByID
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"otherNVC"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testChildSingletonByID
{
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.childDependencyManager singletonObjectOfType:[UIViewController class] forKey:@"otherNVC"];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testNonSingletonObjectByID
{
    UIViewController *result1 = [self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"otherNVC"];
    XCTAssert([result1 isKindOfClass:[UIViewController class]]);
    XCTAssert([result2 isKindOfClass:[UIViewController class]]);
    XCTAssertNotEqual(result1, result2);
}

- (void)testSingletonByDictionary
{
    NSDictionary *configuration = @{ @"id": [[NSUUID UUID] UUIDString], @"name": kTestViewControllerNewMethodTemplateName, @"one": @1, @"two": @2 };
    
    VTestViewControllerWithNewMethod *result1 = (VTestViewControllerWithNewMethod *)[self.dependencyManager singletonObjectOfType:[UIViewController class] fromDictionary:configuration];
    VTestViewControllerWithNewMethod *result2 = (VTestViewControllerWithNewMethod *)[self.dependencyManager singletonObjectOfType:[UIViewController class] fromDictionary:configuration];
    XCTAssertNotNil(result1);
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
}

- (void)testSingletonObjectFromDictionaryWithoutID
{
    NSDictionary *configuration = @{ @"name": kTestViewControllerNewMethodTemplateName, @"one": @1, @"two": @2 };
    
    VTestViewControllerWithNewMethod *result = (VTestViewControllerWithNewMethod *)[self.dependencyManager singletonObjectOfType:[UIViewController class] fromDictionary:configuration];
    XCTAssert([result isKindOfClass:[VTestViewControllerWithNewMethod class]]);
}

@end
