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

@property (nonatomic, strong) NSDictionary *dictionaryOfClassesByTemplateName;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VDependencyManager *childDependencyManager;

@end

@implementation VDependencyManagerTests

- (void)setUp
{
    [super setUp];
    
    self.dictionaryOfClassesByTemplateName = @{ kTestViewControllerInitMethodTemplateName: @"VTestViewControllerWithInitMethod",
                                                kTestViewControllerNewMethodTemplateName: @"VTestViewControllerWithNewMethod",
                                                kTestObjectWithPropertyTemplateName: @"VTestObjectWithProperty"
                                            };
    
    // The presence of this "base" dependency manager (with an empty configuration dictionary) exposed a bug in a previous iteration of VDependencyManager.
    VDependencyManager *baseDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:@{} dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:baseDependencyManager configuration:configuration dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    self.childDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager configuration:@{} dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
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

- (void)testAddedDependencies
{
    NSDictionary *added = @{ @"new": @"value" };
    VTestViewControllerWithNewMethod *value = (VTestViewControllerWithNewMethod *)[self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"nvc" withAddedDependencies:added];
    XCTAssert([value isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssertEqualObjects([value.dependencyManager stringForKey:@"new"], @"value");
}

- (void)testAddedDependenciesOnChildManager
{
    NSDictionary *added = @{ @"new": @"value" };
    VTestViewControllerWithNewMethod *value = (VTestViewControllerWithNewMethod *)[self.childDependencyManager templateValueOfType:[UIViewController class] forKey:@"nvc" withAddedDependencies:added];
    XCTAssert([value isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssertEqualObjects([value.dependencyManager stringForKey:@"new"], @"value");
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
    NSString *actual = [self.dependencyManager stringForKey:@"video_quality"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testStringViaGenericMethod
{
    NSString *expected = @"medium";
    NSString *actual = [self.dependencyManager templateValueOfType:[NSString class] forKey:@"video_quality"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildString
{
    NSString *expected = @"medium";
    NSString *actual = [self.childDependencyManager stringForKey:@"video_quality"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testNumber
{
    NSNumber *expected = @YES;
    NSNumber *actual = [self.dependencyManager numberForKey:@"require_profile_image"];
    XCTAssertNotNil(actual);
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildNumber
{
    NSNumber *expected = @NO;
    NSNumber *actual = [self.childDependencyManager numberForKey:@"histogram_enabled"];
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

- (void)testArrayOfSpecificType
{
    NSArray *array = [self.dependencyManager arrayOfValuesOfType:[VTestViewControllerWithNewMethod class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 2u);
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[0] calledNewMethod]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] calledNewMethod]);
}

- (void)testSingletonArrayOfSpecificType
{
    NSArray *array = [self.dependencyManager arrayOfSingletonValuesOfType:[VTestViewControllerWithNewMethod class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 2u);
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[0] calledNewMethod]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] calledNewMethod]);
    
    NSArray *otherArray = [self.dependencyManager arrayOfSingletonValuesOfType:[VTestViewControllerWithNewMethod class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(otherArray.count, 2u);
    XCTAssertEqual(array[0], otherArray[0]);
    XCTAssertEqual(array[1], otherArray[1]);
}

#pragma mark - Images

- (void)testImageWithName
{
    UIImage *expected = [UIImage imageNamed:@"Menu"];
    UIImage *actual = [self.dependencyManager imageForKey:@"myImage"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testImage
{
    // This test may fail if the "Menu" image is ever removed from our project, but that should be
    // around the same time that the logic of this method will need to be updated anyway.
    UIImage *sampleImage = [UIImage imageNamed:@"Menu"];
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:@{ @"myImage": sampleImage }
                                                            dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    UIImage *actual = [dependencyManager imageForKey:@"myImage"];
    XCTAssertEqualObjects(actual, sampleImage);
}

#pragma mark - Dictionaries

- (void)testDictionary
{
    NSDictionary *expected = @{
        @"channels_enabled": @YES,
        @"template_c_enabled": @NO
    };
    NSDictionary *actual = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"experiments"];
    XCTAssertEqualObjects(expected, actual);
}

/**
 Dictionaries should always be immutable, so a singleton dictionary doesn't make a lot of sense. However,
 if you insist on asking VDependencyManager for a singleton dictionary, it should still work.
 */
- (void)testSingletonDictionary
{
    NSDictionary *expected = @{
        @"channels_enabled": @YES,
        @"template_c_enabled": @NO
    };
    NSDictionary *actual = [self.dependencyManager singletonObjectOfType:[NSDictionary class] forKey:@"experiments"];
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
    XCTAssertEqualObjects([vc.dependencyManager stringForKey:@"video_quality"], @"medium");
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

/**
 A "prefab" object is one that doesn't need to be instantiated--it was "prefabricated" and placed directly into
 the configuration dictionary (rather than the usual case of the configuration dictionary containing strings
 describing the object and how to initialize it). These prefab objects are ALWAYS singletons
 */
- (void)testPrefabSingletonObject
{
    static NSString * const kPFkey = @"pf";
    char bytes[] = {0x1, 0x2, 0x3, 0x4};
    size_t bytesLength = sizeof(char) * 4;
    
    NSData *prefab = [NSData dataWithBytes:&bytes length:bytesLength];
    
    NSDictionary *configuration = @{ kPFkey: prefab };
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:configuration
                                                            dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    
    id result = [dependencyManager singletonObjectOfType:[NSData class] forKey:kPFkey];
    XCTAssertEqual(result, prefab);
    
    id result2 = [dependencyManager templateValueOfType:[NSData class] forKey:kPFkey];
    XCTAssertEqual(result2, prefab);
}

- (void)testPrefabObjectInParentManager
{
    static NSString * const kPFkey = @"pf";
    char bytes[] = {0x1, 0x2, 0x3, 0x4};
    size_t bytesLength = sizeof(char) * 4;
    
    NSData *prefab = [NSData dataWithBytes:&bytes length:bytesLength];
    
    NSDictionary *configuration = @{ kPFkey: prefab };
    VDependencyManager *parentDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:configuration
                                                            dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:parentDependencyManager
                                                                                configuration:@{ }
                                                            dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    
    id result = [dependencyManager singletonObjectOfType:[NSData class] forKey:kPFkey];
    XCTAssertEqual(result, prefab);
    
    id result2 = [dependencyManager templateValueOfType:[NSData class] forKey:kPFkey];
    XCTAssertEqual(result2, prefab);
}

#pragma mark - Children

- (void)testChildManagerReturnsValuesFromParent
{
    VDependencyManager *childManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{ }];
    
    NSString *expected = @"medium";
    NSString *actual = [childManager stringForKey:@"video_quality"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildManagerReturnsNewValues
{
    VDependencyManager *childManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{ @"new": @"hotness" }];
    
    NSString *expected = @"hotness";
    NSString *actual = [childManager stringForKey:@"new"];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testChildManagerOverridesParent
{
    VDependencyManager *childManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:@{ @"video_quality": @"low" }];
    
    NSString *expected = @"low";
    NSString *actual = [childManager stringForKey:@"video_quality"];
    XCTAssertEqualObjects(expected, actual);
}

@end
