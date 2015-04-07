//
//  VKeyboardInputAccessoryViewTests.m
//  victorious
//
//  Created by Sharif Ahmed on 2/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "VKeyboardInputAccessoryView.h"
#import "VDependencyManager.h"

@interface VKeyboardInputAccessoryViewTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VKeyboardInputAccessoryViewTests

- (void)setUp
{
    //Setup a dependency manager so that the VUserTaggingTextView created in awakeFromNib of the defaultInputAccessoryView below can use it
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                 configuration:@{
                                                                                 VDependencyManagerLabel1FontKey : @{
                                                                                         @"fontSize" : @10,
                                                                                         @"fontName" : @"STHeitiSC-Light"
                                                                                         }
                                                                                 }
                                             dictionaryOfClassesByTemplateName:nil];
}

- (void)testInit
{
    XCTAssertNotNil([VKeyboardInputAccessoryView defaultInputAccessoryViewWithDependencyManager:self.dependencyManager], @"should return a valid keyboardInputAccessoryView for nil dependency manager");
}

@end
