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
#import "VThemeManager.h"
#import "VDependencyManager.h"

@interface VKeyboardInputAccessoryViewTests : XCTestCase

@end

@implementation VKeyboardInputAccessoryViewTests

- (void)setUp
{
    //Setup the shared theme manager with a dependency manager so that the VUserTaggingTextView created in awakeFromNib of the defaultInputAccessoryView below can use it
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:@{
                                                                                                VDependencyManagerLabel1FontKey : @{
                                                                                                        @"fontSize" : @10,
                                                                                                        @"fontName" : @"STHeitiSC-Light"
                                                                                                        }
                                                                                                }
                                                            dictionaryOfClassesByTemplateName:nil];
    [[VThemeManager sharedThemeManager] setDependencyManager:dependencyManager];
}

- (void)testInit
{
    XCTAssertNotNil([VKeyboardInputAccessoryView defaultInputAccessoryView], @"should return a valid keyboardInputAccessoryView for nil dependency manager");
}

@end
