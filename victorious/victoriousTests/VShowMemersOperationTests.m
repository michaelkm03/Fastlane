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
#import "VUser.h"
#import "VStreamCollectionViewController.h"

#import "victorious-Swift.h"

@interface VShowMemersOperationTests : XCTestCase

@property (nonatomic, strong) UINavigationController *navigationController;
@property (nonatomic, strong) UIViewController *viewController;
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, assign) IMP origImp;

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
    
    self.origImp = [VDependencyManager v_swizzleMethod:@selector(templateValueOfType:forKey:withAddedDependencies:)
                                             withBlock:^id(VDependencyManager *dependencyManager, Class type, NSString *key, NSDictionary *dependencies)
                    {
                        VStreamCollectionViewController *memeStream = [VStreamCollectionViewController newWithDependencyManager:self.dependencyManager];
                        return memeStream;
                    }];
}

- (void)tearDown
{
    [super tearDown];
    [VDependencyManager v_restoreOriginalImplementation:self.origImp
                                         forClassMethod:@selector(templateValueOfType:forKey:withAddedDependencies:)];
}

- (void)testStreamPushed
{
    ShowMemersOperation *operation = [[ShowMemersOperation alloc] initWithOriginViewController:self.viewController
                                                                             dependencyManager:self.dependencyManager
                                                                                      sequence:self.sequence];
    [operation queueWithCompletion:^
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
