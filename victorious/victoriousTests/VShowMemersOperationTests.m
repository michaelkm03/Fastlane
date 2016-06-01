//
//  VShowMemersOperationTests.m
//  victorious
//
//  Created by Vincent Ho on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+VMethodSwizzling.h"
#import "VDependencyManager.h"
#import "VDummyModels.h"
#import "VSequence.h"
#import "VStreamCollectionViewController.h"

#import "victorious-Swift.h"

@interface VShowMemersOperationTests : XCTestCase

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VShowMemersOperationTests

- (void)setUp
{
    [super setUp];
    
    self.navigationController = [[UINavigationController alloc] init];
    self.viewController = [[UIViewController alloc] init];
    self.sequence = [VDummyModels objectWithEntityName:@"Sequence" subclass:[VSequence class]];
    [self.navigationController setViewControllers:@[self.viewController] animated:NO];
    
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                 configuration:nil
                                             dictionaryOfClassesByTemplateName:nil];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testStreamPushed
{
    ShowMemersOperation *operation = [[ShowMemersOperation alloc] initWithOriginViewController:self.viewController
                                                                             dependencyManager:self.dependencyManager
                                                                                      sequence:self.sequence];
    [operation queueWithCompletion:^(NSError *error, BOOL cancelled)
     {
         UIViewController *topVC = self.navigationController.topViewController;
         XCTAssert([topVC isKindOfClass:[VStreamCollectionViewController class]]);
         
         VStreamCollectionViewController *memeStream = (VStreamCollectionViewController *)topVC;
         
         [memeStream dismissViewControllerAnimated:NO completion:^
          {
              XCTAssert([self.navigationController.viewControllers isEqualToArray:@[self.viewController]]);
          }];
     }];
}

@end
