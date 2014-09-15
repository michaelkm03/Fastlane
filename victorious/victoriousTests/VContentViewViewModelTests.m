//
//  VContentViewViewModelTests.m
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "VContentViewViewModel.h"

#import "VObjectManager.h"
#import "VConstants.h"
#import "VSequence+RestKit.h"
#import <RKManagedObjectStore.h>


@interface VContentViewViewModelTests : XCTestCase

@property (nonatomic, strong) VSequence *someSequence;

@end

@implementation VContentViewViewModelTests

- (void)setUp
{
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[VSequence entityName]
                                                         inManagedObjectContext:[[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
    self.someSequence = [[VSequence alloc] initWithEntity:entityDescription
                                 insertIntoManagedObjectContext:[[[VObjectManager sharedManager] managedObjectStore] mainQueueManagedObjectContext]];
}

- (void)testDesignatedInitializerAssignsPublicProperty
{
    VContentViewViewModel *contentViewViewModel = [[VContentViewViewModel alloc] initWithSequence:self.someSequence];
    XCTAssertEqual(self.someSequence, contentViewViewModel.sequence, @"ContentViewViewModel's sequence should be what is passed in to the designate initializer.");
}

- (void)testOwnerPollType
{
    self.someSequence.category = kVOwnerPollCategory;
    VContentViewViewModel *contentViewViewModel = [[VContentViewViewModel alloc] initWithSequence:self.someSequence];
    XCTAssertEqual(contentViewViewModel.type, VContentViewTypePoll, @"ContentViewViewModel's type should be of poll type when category is kVOwnerPollCategory.");
}

- (void)testUGCPollType
{
    self.someSequence.category = kVUGCPollCategory;
    VContentViewViewModel *contentViewViewModel = [[VContentViewViewModel alloc] initWithSequence:self.someSequence];
    XCTAssertEqual(contentViewViewModel.type, VContentViewTypePoll, @"ContentViewViewModel's type should be of poll type when category is kVOwnerPollCategory.");
}

@end
