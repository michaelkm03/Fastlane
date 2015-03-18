//
//  VStreamContentPermissionsTests.m
//  victorious
//
//  Created by Patrick Lynch on 3/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VDummyModels.h"
#import "VStream.h"
#import "VDependencyManager.h"
#import "VStreamCollectionViewcontroller.h"

static NSString * const kCanAddContentKey = @"canAddContent";

@interface VDependencyManager ()

@property (nonatomic, strong) NSDictionary *configuration;

@end

@interface VStreamCollectionViewController ()

- (BOOL)isUserPostAllowedInStream:(VStream *)stream withDependencyManager:(VDependencyManager *)dependencyManager;

@end

@interface VStreamContentPermissionsTests : XCTestCase

@end

@implementation VStreamContentPermissionsTests

- (void)testCanPostContent
{
    VDependencyManager *depenendecyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                 configuration:nil
                                                             dictionaryOfClassesByTemplateName:nil];
    VStream *stream = [VDummyModels objectsWithEntityName:@"Stream" subclass:[VStream class] count:1].firstObject;
    
    VStreamCollectionViewController *streamViewController = [[VStreamCollectionViewController alloc] init];
    
    stream.isUserPostAllowed = @YES;
    depenendecyManager.configuration = @{ kCanAddContentKey : @YES };
    XCTAssert( [streamViewController isUserPostAllowedInStream:stream withDependencyManager:depenendecyManager] );
    
    stream.isUserPostAllowed = @YES;
    depenendecyManager.configuration = @{ kCanAddContentKey : @NO };
    XCTAssert( [streamViewController isUserPostAllowedInStream:stream withDependencyManager:depenendecyManager] );
    
    stream.isUserPostAllowed = @NO;
    depenendecyManager.configuration = @{ kCanAddContentKey : @YES };
    XCTAssert( [streamViewController isUserPostAllowedInStream:stream withDependencyManager:depenendecyManager] );
    
    stream.isUserPostAllowed = @NO;
    depenendecyManager.configuration = @{ kCanAddContentKey : @NO };
    XCTAssertFalse( [streamViewController isUserPostAllowedInStream:stream withDependencyManager:depenendecyManager] );
}

@end
