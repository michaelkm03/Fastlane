//
//  VAppInfoTests.m
//  victorious
//
//  Created by Sharif Ahmed on 3/23/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VAppInfo.h"
#import "VDependencyManager.h"

static NSString * const kOwnerName = @"ownerName";
static NSString * const kOwnerProfileImageURL = @"http://imageURL";
static NSString * const kOwnerId = @"ownerId";
static NSString * const kAppStoreURL = @"http://appStoreURL";
static NSString * const kAppName = @"appName";

@interface VAppInfoTests : XCTestCase

@property (nonatomic, strong) NSDictionary *validDependencyManagerConfigurationDictionary;

@end

@implementation VAppInfoTests

- (void)setUp
{
    [super setUp];
    self.validDependencyManagerConfigurationDictionary =
    @{
      @"owner" :
          @{
              @"name" : kOwnerName,
              @"profile_image" : kOwnerProfileImageURL,
              @"id" : kOwnerId
              },
      @"appStoreURL" : kAppStoreURL,
      @"appName" : kAppName
      };
}

- (void)tearDown
{
    self.validDependencyManagerConfigurationDictionary = nil;
    [super tearDown];
}

- (void)testInitWithValidDependencyManager
{
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:self.validDependencyManagerConfigurationDictionary dictionaryOfClassesByTemplateName:nil];
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:dependencyManager];
    XCTAssertEqualObjects(appInfo.ownerName, kOwnerName, @"owner name should be equivalent to string at name key of owner dictionary");
    XCTAssertEqualObjects(appInfo.profileImageURL.absoluteString, kOwnerProfileImageURL, @"owner profile image url string should be equivalent to string at profile_image key of owner dictionary");
    XCTAssertEqualObjects(appInfo.ownerId, kOwnerId, @"owner id should be equivalent to string at name key of owner dictionary");
    XCTAssertEqualObjects(appInfo.appURL.absoluteString, kAppStoreURL, @"app url string should be equivalent to string at appStoreURL key of root dictionary");
    XCTAssertEqualObjects(appInfo.appName, kAppName, @"app name should be equivalent to string at appName key of root dictionary");
}

- (void)testInitWithNil
{
    XCTAssertThrows([[VAppInfo alloc] initWithDependencyManager:nil], @"appInfo should throw an assertion when init-ed with a nil dependencyManager");
}

- (void)testInitWithDependencyManagerWithMissingKeys
{
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil configuration:nil dictionaryOfClassesByTemplateName:nil];
    XCTAssertNoThrow([[VAppInfo alloc] initWithDependencyManager:dependencyManager], @"App info should not throw assertion when init-ed with a dependencyManager appInfo keys");
    
    VAppInfo *appInfo = [[VAppInfo alloc] initWithDependencyManager:dependencyManager];
    XCTAssertNil(appInfo.ownerName, @"owner name should be nil if there is no string at name key of owner dictionary");
    XCTAssertNil(appInfo.profileImageURL.absoluteString, @"owner profile image url string should be nil if there is no string at profile_image key of owner dictionary");
    XCTAssertNil(appInfo.ownerId, @"owner id should be nil if there is no string at name key of owner dictionary");
    XCTAssertNil(appInfo.appURL.absoluteString, @"app url string should be nil if there is no string at appStoreURL key of root dictionary");
    XCTAssertNil(appInfo.appName, @"app name should be nil if there is no string at appName key of root dictionary");
}

@end
