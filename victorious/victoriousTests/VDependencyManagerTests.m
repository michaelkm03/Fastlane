//
//  VDependencyManagerTests.m
//  victorious
//
//  Created by Josh Hinman on 11/2/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VHasManagedDependencies.h"
#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

static NSString * const kTestViewControllerInitMethodTemplateName = @"testInitMethod";
static NSString * const kTestViewControllerNewMethodTemplateName = @"testNewMethod";
static NSString * const kTestObjectWithPropertyTemplateName = @"testProperty";

#pragma mark - VTestProtocol

@protocol VTestProtocol <NSObject>

@required
- (void)testMethod;

@end

#pragma mark - VTestViewControllerWithInitMethod

@interface VTestViewControllerWithInitMethod : UIViewController <VHasManagedDependencies, VTestProtocol>

@property (nonatomic, readonly) VDependencyManager *dependencyManager;
@property (nonatomic) BOOL calledInitMethod;

@end

@implementation VTestViewControllerWithInitMethod

- (instancetype)initWithDependencyManager:(VDependencyManager *)dependencyManager
{
    self = [super init];
    if (self)
    {
        _calledInitMethod = YES;
        _dependencyManager = dependencyManager;
    }
    return self;
}

- (void)testMethod
{
}

@end

#pragma mark - VTestViewControllerWithNewMethod

@interface VTestViewControllerWithNewMethod : UIViewController <VHasManagedDependencies>

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

@interface VTestObjectWithProperty : NSObject <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VTestObjectWithProperty

@end

#pragma mark -

@interface VDependencyManagerTests : XCTestCase

@property (nonatomic, strong) NSDictionary *dictionaryOfClassesByTemplateName;
@property (nonatomic, strong) VDependencyManager *baseDependencyManager;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) VDependencyManager *childDependencyManager;

@end

@implementation VDependencyManagerTests

- (void)setUp
{
    [super setUp];
    
    self.dictionaryOfClassesByTemplateName = @{ kTestViewControllerInitMethodTemplateName: @"VTestViewControllerWithInitMethod",
                                                kTestViewControllerNewMethodTemplateName: @"VTestViewControllerWithNewMethod",
                                                kTestObjectWithPropertyTemplateName: @"VTestObjectWithProperty",
                                                @"solidColor.background": @"VSolidColorBackground",
                                            };
    
    self.baseDependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                     configuration:@{ @"rootComponent": @{ @"name": @"testNewMethod" } }
                                                 dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"template" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:self.baseDependencyManager
                                                                 configuration:configuration
                                             dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
    self.childDependencyManager = [[VDependencyManager alloc] initWithParentManager:self.dependencyManager
                                                                      configuration:@{ @"invalidColor": @{ @"red": @"spot",
                                                                                                           @"green": @"monkey",
                                                                                                           @"blue": @255,
                                                                                                           @"alpha": @255,
                                                                                                           },
                                                                                       @"color.text": @{ @"red": @"green",
                                                                                                         @"green": @"red",
                                                                                                         @"blue": @"blue",
                                                                                                         @"alpha": @"refridgerator",
                                                                                                         },
                                                                                       @"color.background": @{ @"red": @153,
                                                                                                         @"green": @51,
                                                                                                         @"blue": @102,
                                                                                                         @"alpha": @255,
                                                                                                         },
                                                                                       @"invalidFont": @{ @"fontName": @"Comic Sans",
                                                                                                          @"fontSize": @24,
                                                                                                          },
                                                                                       @"font.heading1": @{
                                                                                               
                                                                                               },
                                                                                       @"font.heading2": @{ @"fontName": @"Not Your Father's Font",
                                                                                                            @"fontSize": @36
                                                                                               },
                                                                                       }
                                                  dictionaryOfClassesByTemplateName:self.dictionaryOfClassesByTemplateName];
}

- (void)tearDown
{
    [self.baseDependencyManager cleanup];
    [super tearDown];
}

#pragma mark - Colors, fonts

- (void)testColor
{
    UIColor *expected = [UIColor colorWithRed:0.2 green:0.6 blue:0.4 alpha:1];
    UIColor *actual = [self.dependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testParentColor
{
    UIColor *expected = [UIColor colorWithRed:0.2 green:0.6 blue:0.4 alpha:1];
    UIColor *actual = [self.childDependencyManager colorForKey:VDependencyManagerMainTextColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testBackgroundColor
{
    UIColor *expected = [UIColor colorWithRed:0.6 green:0.2 blue:0.4 alpha:1];
    UIColor *actual = [self.childDependencyManager colorForKey:VDependencyManagerBackgroundColorKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testInvalidColorReturnsNil
{
    UIColor *invalid = [self.childDependencyManager colorForKey:@"invalidColor"];
    XCTAssertNil(invalid);
}

- (void)testInvalidColorDefaultsToParent
{
    UIColor *expected = [UIColor colorWithRed:0.2 green:0.6 blue:0.4 alpha:1];
    UIColor *actual = [self.childDependencyManager colorForKey:VDependencyManagerMainTextColorKey];
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

- (void)testInvalidFontReturnsNil
{
    UIFont *invalid = [self.childDependencyManager fontForKey:@"invalidFont"];
    XCTAssertNil(invalid);
}

- (void)testInvalidFontDefaultsToParent
{
    UIFont *expected = [UIFont fontWithName:@"STHeitiSC-Light" size:24];
    UIFont *actual = [self.childDependencyManager fontForKey:VDependencyManagerHeading1FontKey];
    XCTAssertEqualObjects(expected, actual);
}

- (void)testAnotherKindOfInvalidFontDefaultsToParent
{
    UIFont *expected = [UIFont fontWithName:@"STHeitiSC-Light" size:20];
    UIFont *actual = [self.childDependencyManager fontForKey:VDependencyManagerHeading2FontKey];
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

#pragma mark - Protocols

- (void)testValueConformingToProtocol
{
    id<VTestProtocol> viewController = [self.dependencyManager templateValueConformingToProtocol:@protocol(VTestProtocol) forKey:@"ivc"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    XCTAssert([(VTestViewControllerWithInitMethod *)viewController calledInitMethod]);
}

- (void)testValueDoesNotConformToProtocol
{
    id viewController = [self.dependencyManager templateValueConformingToProtocol:@protocol(VTestProtocol) forKey:@"nvc"];
    XCTAssertNil(viewController);
}

- (void)testValueConformingToProtocolWithExtraDependencies
{
    id<VTestProtocol> viewController = [self.dependencyManager templateValueConformingToProtocol:@protocol(VTestProtocol) forKey:@"ivc" withAddedDependencies:@{ @"hi": @"world" }];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    XCTAssertEqualObjects([[(VTestViewControllerWithInitMethod *)viewController dependencyManager] stringForKey:@"hi"], @"world");
}

- (void)testValueDoesNotConformToProtocolWithExtraDependencies
{
    id<VTestProtocol> viewController = [self.dependencyManager templateValueConformingToProtocol:@protocol(VTestProtocol) forKey:@"nvc" withAddedDependencies:@{ @"hi": @"world" }];
    XCTAssertNil(viewController);
}

#pragma mark - Objects

- (void)testNSObjectInstantiation
{
    id nvc = [self.dependencyManager templateValueOfType:[NSObject class] forKey:@"nvc"];
    XCTAssert([nvc isKindOfClass:[VTestViewControllerWithNewMethod class]]);
}

- (void)testNSObjectSingleton
{
    id nvc = [self.dependencyManager singletonObjectOfType:[NSObject class] forKey:@"nvc"];
    XCTAssert([nvc isKindOfClass:[VTestViewControllerWithNewMethod class]]);
}

- (void)testNSObjectReference
{
    id nvc = [self.dependencyManager templateValueOfType:[NSObject class] forKey:@"otherNVC"];
    XCTAssert([nvc isKindOfClass:[VTestViewControllerWithNewMethod class]]);
}

- (void)testNSObjectReferenceSingleton
{
    id nvc = [self.dependencyManager singletonObjectOfType:[NSObject class] forKey:@"otherNVC"];
    XCTAssert([nvc isKindOfClass:[VTestViewControllerWithNewMethod class]]);
}

- (void)testArraysOfNSObjects
{
    NSArray *array = [self.dependencyManager arrayOfValuesOfType:[NSObject class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 5u);
    
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[2] isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    XCTAssert([array[3] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[4] isKindOfClass:[VTestViewControllerWithInitMethod class]]);
}

- (void)testArraysOfSingletonNSObjects
{
    NSArray *array = [self.dependencyManager arrayOfSingletonValuesOfType:[NSObject class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 5u);
    
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[2] isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    XCTAssert([array[3] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[4] isKindOfClass:[VTestViewControllerWithInitMethod class]]);
}

- (void)testRootObject
{
    id viewController = [self.dependencyManager viewControllerForKey:@"rootComponent"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
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
    XCTAssertEqual(array.count, 3u);
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[0] calledNewMethod]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] calledNewMethod]);
    XCTAssert([array[2] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[2] calledNewMethod]);
}

- (void)testSingletonArrayOfSpecificType
{
    NSArray *array = [self.dependencyManager arrayOfSingletonValuesOfType:[VTestViewControllerWithNewMethod class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 3u);
    XCTAssert([array[0] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[0] calledNewMethod]);
    XCTAssert([array[1] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[1] calledNewMethod]);
    XCTAssert([array[2] isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([array[2] calledNewMethod]);
    
    NSArray *otherArray = [self.dependencyManager arrayOfSingletonValuesOfType:[VTestViewControllerWithNewMethod class] forKey:@"arrayOfObjects"];
    XCTAssertEqual(otherArray.count, 3u);
    XCTAssertEqual(array[0], otherArray[0]);
    XCTAssertEqual(array[1], otherArray[1]);
    XCTAssertEqual(array[2], otherArray[2]);
    
    VTestViewControllerWithNewMethod *otherSingletonReference = (VTestViewControllerWithNewMethod *)[self.dependencyManager singletonViewControllerForKey:@"otherNVC"];
    XCTAssertEqual(otherArray[2], otherSingletonReference);
}

- (void)testArrayOfProtocols
{
    NSArray *array = [self.dependencyManager arrayOfValuesConformingToProtocol:@protocol(VTestProtocol) forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 2u);
    XCTAssert([array[0] conformsToProtocol:@protocol(VTestProtocol)]);
    XCTAssert([array[1] conformsToProtocol:@protocol(VTestProtocol)]);
}

- (void)testSingletonArrayOfProtocols
{
    NSArray *array = [self.dependencyManager arrayOfSingletonValuesConformingToProtocol:@protocol(VTestProtocol) forKey:@"arrayOfObjects"];
    XCTAssertEqual(array.count, 2u);
    XCTAssert([array[0] conformsToProtocol:@protocol(VTestProtocol)]);
    XCTAssert([array[1] conformsToProtocol:@protocol(VTestProtocol)]);

    NSArray *otherArray = [self.dependencyManager arrayOfSingletonValuesConformingToProtocol:@protocol(VTestProtocol) forKey:@"arrayOfObjects"];
    XCTAssertEqual(otherArray.count, 2u);
    XCTAssertEqual(array[0], otherArray[0]);
    XCTAssertEqual(array[1], otherArray[1]);
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

#pragma mark - Instantiating objects via references

- (void)testReferencedObject
{
    id viewController = [self.dependencyManager viewControllerForKey:@"otherNVC"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
}

- (void)testReferencedObjectWithAddedDependencies
{
    NSDictionary *added = @{ @"new": @"value" };
    VTestViewControllerWithNewMethod *value = (VTestViewControllerWithNewMethod *)[self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"otherNVC" withAddedDependencies:added];
    XCTAssert([value isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssertEqualObjects([value.dependencyManager stringForKey:@"new"], @"value");
}

- (void)testDeepReference
{
    VTestViewControllerWithNewMethod *viewController = (VTestViewControllerWithNewMethod *)[self.dependencyManager viewControllerForKey:@"deeplyReferencedNVC"];
    XCTAssert([viewController isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([viewController calledNewMethod]);
    
    // Test that the new object pulls its dependencies from its original context, not the context of the reference
    NSString *expected = @"deep_store_url";
    NSString *actual = [viewController.dependencyManager stringForKey:@"app_store_url"];
    XCTAssertEqualObjects(expected, actual);
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

- (void)testSingletonOveriddenByChild
{
    NSDictionary *childConfiguration = @{ @"nvc": @{ @"id": @"e37b71af-ca8d-4eea-a3d3-d67aa0ecb018", @"name": @"testInitMethod" } };
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
    
    UIViewController *parentSingleton = [self.dependencyManager singletonViewControllerForKey:@"nvc"];
    UIViewController *childSingleton = [childDependencyManager singletonViewControllerForKey:@"nvc"];
    XCTAssertNotNil(parentSingleton);
    XCTAssertNotNil(childSingleton);
    XCTAssertNotEqual(parentSingleton, childSingleton);
    XCTAssert([parentSingleton isKindOfClass:[VTestViewControllerWithNewMethod class]]);
    XCTAssert([childSingleton isKindOfClass:[VTestViewControllerWithInitMethod class]]);
    
    UIViewController *childSingletonAgain = [childDependencyManager singletonViewControllerForKey:@"nvc"];
    XCTAssertEqual(childSingleton, childSingletonAgain);
    
    UIViewController *parentSingletonAgain = [self.dependencyManager singletonViewControllerForKey:@"nvc"];
    XCTAssertEqual(parentSingleton, parentSingletonAgain);
}

- (void)testSingletonInParentReferencedByChild
{
    NSDictionary *childConfiguration = @{ @"childRef": @{ @"referenceID": @"ae742d8a-aaea-43db-b99a-707d72b147cb" } };
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
    
    UIViewController *parentSingleton = [self.dependencyManager singletonViewControllerForKey:@"nvc"];
    UIViewController *childSingleton = [childDependencyManager singletonViewControllerForKey:@"childRef"];
    XCTAssertNotNil(parentSingleton);
    XCTAssertNotNil(childSingleton);
    XCTAssertEqual(parentSingleton, childSingleton);
    
    UIViewController *childSingletonAgain = [childDependencyManager singletonViewControllerForKey:@"childRef"];
    XCTAssertEqual(childSingleton, childSingletonAgain);
}

- (void)testNonSingletonObjectByID
{
    UIViewController *result1 = [self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"nvc"];
    UIViewController *result2 = [self.dependencyManager templateValueOfType:[UIViewController class] forKey:@"otherNVC"];
    XCTAssert([result1 isKindOfClass:[UIViewController class]]);
    XCTAssert([result2 isKindOfClass:[UIViewController class]]);
    XCTAssertNotEqual(result1, result2);
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

- (void)testChildPropertiesOverrideParentPropertiesForSingletons
{
    NSDictionary *childConfiguration = [self.dependencyManager templateValueOfType:[NSDictionary class] forKey:@"ivc"];
    VDependencyManager *childDependencyManager = [self.dependencyManager childDependencyManagerWithAddedConfiguration:childConfiguration];
    VTestViewControllerWithNewMethod *viewController = (VTestViewControllerWithNewMethod *)[childDependencyManager singletonViewControllerForKey:@"inner"];
    
    NSString *expected = @"http://example.com/";
    NSString *actual = [viewController.dependencyManager stringForKey:@"app_store_url"];
    XCTAssertEqualObjects(expected, actual);
}

#pragma mark - Cleanup

- (VDependencyManager *)extractChildFromDependencyManager:(VDependencyManager *)dependencyManager
{
    VTestViewControllerWithInitMethod *vc = (VTestViewControllerWithInitMethod *)[dependencyManager viewControllerForKey:@"ivc"];
    return vc.dependencyManager;
}

- (void)testCleanupRemovesSingletons
{
    // One of the main sources of retain cycles that -cleanup targets is singletons.
    // This method ensures they are released
    
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotNil(result1);

    [self.baseDependencyManager cleanup];
    
    UIViewController *result2 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotEqual(result1, result2);
}

- (void)testCleanupDoesntWorkOnChildren
{
    // -cleanup is documented to not work when called on child dependency managers.
    // This test verifies that's true.
    
    UIViewController *result1 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotNil(result1);
    
    [self.dependencyManager cleanup];
    
    UIViewController *result2 = [self.dependencyManager singletonObjectOfType:[UIViewController class] forKey:@"nvc"];
    XCTAssertNotNil(result2);
    XCTAssertEqual(result1, result2);
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
