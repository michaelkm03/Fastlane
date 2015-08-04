//
//  VInStreamCommentsShowMoreAttributesTests.m
//  victorious
//
//  Created by Sharif Ahmed on 7/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VInStreamCommentsShowMoreAttributes.h"
#import "VDependencyManager.h"

@interface VInStreamCommentsShowMoreAttributesTests : XCTestCase

@property (nonatomic, strong) NSDictionary *unselectedTextAttributes;
@property (nonatomic, strong) NSDictionary *selectedTextAttributes;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VInStreamCommentsShowMoreAttributesTests

- (void)setUp
{
    [super setUp];
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
    self.unselectedTextAttributes = @{};
    self.selectedTextAttributes = @{};
}

- (void)testClassMethodInit
{
    XCTAssertNoThrow([VInStreamCommentsShowMoreAttributes newWithDependencyManager:self.dependencyManager]);
    
    XCTAssertThrows([VInStreamCommentsShowMoreAttributes newWithDependencyManager:nil]);
}

- (void)testClassMethodInitFields
{
    VInStreamCommentsShowMoreAttributes *attributes = [VInStreamCommentsShowMoreAttributes newWithDependencyManager:self.dependencyManager];
    XCTAssertNotNil(attributes.unselectedTextAttributes);
    XCTAssertNotNil(attributes.selectedTextAttributes);
}

- (void)testInstanceMethodInit
{
    XCTAssertNoThrow([[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:self.unselectedTextAttributes selectedTextAttributes:self.selectedTextAttributes]);
    
    XCTAssertThrows([[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:nil selectedTextAttributes:self.selectedTextAttributes]);
    XCTAssertThrows([[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:self.unselectedTextAttributes selectedTextAttributes:nil]);
}

- (void)testInstanceMethodInitFields
{
    VInStreamCommentsShowMoreAttributes *attributes = [[VInStreamCommentsShowMoreAttributes alloc] initWithUnselectedTextAttributes:self.unselectedTextAttributes selectedTextAttributes:self.selectedTextAttributes];
    
    XCTAssertEqual(attributes.unselectedTextAttributes, self.unselectedTextAttributes);
    XCTAssertEqual(attributes.selectedTextAttributes, self.selectedTextAttributes);
}

@end
