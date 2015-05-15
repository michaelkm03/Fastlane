//
//  VDependencyManager_VNavigationMenuItemTests.m
//  victorious
//
//  Created by Josh Hinman on 4/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager+VNavigationMenuItem.h"
#import "VNavigationMenuItem.h"

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface VMenuItemTestObject : NSObject

@end

@implementation VMenuItemTestObject

@end

#pragma mark -

@interface VDependencyManager_VNavigationMenuItemTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManagerWithSections;
@property (nonatomic, strong) VDependencyManager *dependencyManagerWithItems;

@end

@implementation VDependencyManager_VNavigationMenuItemTests

- (void)setUp
{
    [super setUp];
    
    NSData *testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"menuSectionsTemplate" withExtension:@"json"]];
    NSDictionary *configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];

    self.dependencyManagerWithSections = [[VDependencyManager alloc] initWithParentManager:nil
                                                                 configuration:configuration
                                             dictionaryOfClassesByTemplateName:@{ NSStringFromClass([VMenuItemTestObject class]): NSStringFromClass([VMenuItemTestObject class]) }];

    testData = [NSData dataWithContentsOfURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"menuItemsTemplate" withExtension:@"json"]];
    configuration = [NSJSONSerialization JSONObjectWithData:testData options:0 error:nil];
    
    self.dependencyManagerWithItems = [[VDependencyManager alloc] initWithParentManager:nil
                                                                          configuration:configuration
                                                      dictionaryOfClassesByTemplateName:@{ NSStringFromClass([VMenuItemTestObject class]): NSStringFromClass([VMenuItemTestObject class]) }];

}

- (void)testSections
{
    NSArray *sections = [self.dependencyManagerWithSections menuItemSections];
    XCTAssertEqual(sections.count, 1u);
    
    NSArray *section = sections[0];
    XCTAssertEqual(section.count, 2u);

    VNavigationMenuItem *item1 = section[0];
    XCTAssert([item1.destination isKindOfClass:[VMenuItemTestObject class]]);
    XCTAssertEqualObjects(item1.icon, [UIImage imageNamed:@"D_home"]);
    XCTAssertEqualObjects(item1.selectedIcon, [UIImage imageNamed:@"D_home_selected"]);
    XCTAssertEqualObjects(item1.title, @"Home");
    XCTAssertEqualObjects(item1.identifier, @"Menu Home");
    
    VNavigationMenuItem *item2 = section[1];
    XCTAssert([item2.destination isKindOfClass:[VMenuItemTestObject class]]);
    XCTAssertEqualObjects(item2.icon, [UIImage imageNamed:@"D_channels"]);
    XCTAssertEqualObjects(item2.selectedIcon, [UIImage imageNamed:@"D_channels_selected"]);
    XCTAssertEqualObjects(item2.title, @"Channels");
    XCTAssertEqualObjects(item2.identifier, @"Menu Channels");
}

- (void)testSectionsAreSingletons
{
    NSArray *sections = [self.dependencyManagerWithSections menuItemSections];
    XCTAssertEqual(sections.count, 1u);
    NSArray *section = sections[0];
    
    NSArray *sections2 = [self.dependencyManagerWithSections menuItemSections];
    XCTAssertEqual(sections2.count, 1u);
    NSArray *section2 = sections2[0];
    
    VNavigationMenuItem *item1 = section[0];
    VNavigationMenuItem *item2 = section2[0];
    
    XCTAssertEqual(item1.destination, item2.destination);
}

- (void)testItems
{
    NSArray *items = [self.dependencyManagerWithItems menuItems];
    XCTAssertEqual(items.count, 2u);
    
    VNavigationMenuItem *item1 = items[0];
    XCTAssert([item1.destination isKindOfClass:[VMenuItemTestObject class]]);
    XCTAssertEqualObjects(item1.icon, [UIImage imageNamed:@"D_home"]);
    XCTAssertEqualObjects(item1.selectedIcon, [UIImage imageNamed:@"D_home_selected"]);
    XCTAssertEqualObjects(item1.title, @"Home");
    XCTAssertEqualObjects(item1.identifier, @"Menu Home");
    
    VNavigationMenuItem *item2 = items[1];
    XCTAssert([item2.destination isKindOfClass:[VMenuItemTestObject class]]);
    XCTAssertEqualObjects(item2.icon, [UIImage imageNamed:@"D_channels"]);
    XCTAssertEqualObjects(item2.selectedIcon, [UIImage imageNamed:@"D_channels_selected"]);
    XCTAssertEqualObjects(item2.title, @"Channels");
    XCTAssertEqualObjects(item2.identifier, @"Menu Channels");
}

- (void)testItemsAreSingletons
{
    NSArray *items = [self.dependencyManagerWithItems menuItems];
    XCTAssertEqual(items.count, 2u);
    
    NSArray *items2 = [self.dependencyManagerWithItems menuItems];
    XCTAssertEqual(items2.count, 2u);
    
    VNavigationMenuItem *item1 = items[0];
    VNavigationMenuItem *item2 = items2[0];
    
    XCTAssertEqual(item1.destination, item2.destination);
}

@end
