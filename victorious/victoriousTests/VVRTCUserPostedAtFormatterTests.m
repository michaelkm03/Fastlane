//
//  VVRTCUserPostedAtFormatterTests.m
//  victorious
//
//  Created by Michael Sena on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

#import "VRTCUserPostedAtFormatter.h"
#import "VThemeManager.h"
#import "VDependencyManager.h"

@interface VVRTCUserPostedAtFormatterTests : XCTestCase

@end

@implementation VVRTCUserPostedAtFormatterTests

- (void)setUp
{
    //Setup the shared theme manager with a dependency manager so that the VRTCUserPostedAtFormatter can use it
    VDependencyManager *dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                                configuration:@{
                                                                                                kVLinkColor : @{
                                                                                                        @"red" : @255,
                                                                                                        @"green" : @0,
                                                                                                        @"blue" : @255,
                                                                                                        @"alpha" : @255
                                                                                                        },
                                                                                                kVLabel2Font : @{
                                                                                                        @"fontSize" : @10,
                                                                                                        @"fontName" : @"STHeitiSC-Light"
                                                                                                        }
                                                                                                }
                                                            dictionaryOfClassesByTemplateName:nil];
    [[VThemeManager sharedThemeManager] setDependencyManager:dependencyManager];
}

- (void)testNilArguments
{
    XCTAssertNoThrow([VRTCUserPostedAtFormatter formatRTCUserName:nil]);
    XCTAssertNoThrow([VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:nil
                                                                             andPostedTime:nil]);
    
    NSAttributedString *shouldBeNil = [VRTCUserPostedAtFormatter formatRTCUserName:nil];
    XCTAssertNil(shouldBeNil);
    
    shouldBeNil = [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:nil
                                                                          andPostedTime:nil];
    XCTAssertNil(shouldBeNil);
}

- (void)testFormatRTCUserName
{
    NSAttributedString *test = [VRTCUserPostedAtFormatter formatRTCUserName:@"username"];
    __block BOOL appliedLinkColor;
    __block BOOL appliedLabel2Font;
    
    [test enumerateAttributesInRange:NSMakeRange(0, test.string.length)
                             options:kNilOptions
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         if (attrs[NSForegroundColorAttributeName] != nil)
         {
             UIColor *formattedColor = attrs[NSForegroundColorAttributeName];
             UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
             appliedLinkColor = ([formattedColor isEqual:linkColor]) ? YES : NO;
         }
         if (attrs[NSFontAttributeName] != nil)
         {
             UIFont *formattedFont = attrs[NSFontAttributeName];
             UIFont *label2Font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
             appliedLabel2Font = ([formattedFont isEqual:label2Font]) ? YES : NO;
         }
     }];
    XCTAssertTrue(appliedLinkColor);
    XCTAssertTrue(appliedLabel2Font);
}

- (void)testFormatRTCUserNameWithPostedTime
{
    NSString *usernameString = @"username";
    NSAttributedString *test = [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:usernameString
                                                                                       andPostedTime:@1.5f];
    XCTAssertEqualObjects(test.string, @"username at 0:02");
    
    __block BOOL appliedLinkColorToUsername;
    __block BOOL appliedLabel2FontToFullString;
    
    [test enumerateAttributesInRange:NSMakeRange(0, usernameString.length)
                             options:kNilOptions
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         if (attrs[NSForegroundColorAttributeName])
         {
             UIColor *formattedColor = attrs[NSForegroundColorAttributeName];
             UIColor *linkColor = [[VThemeManager sharedThemeManager] themedColorForKey:kVLinkColor];
             appliedLinkColorToUsername = ([formattedColor isEqual:linkColor]) ? YES : NO;
         }
     }];
    [test enumerateAttributesInRange:NSMakeRange(0, test.string.length)
                             options:kNilOptions
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         if (attrs[NSFontAttributeName] != nil)
         {
             UIFont *formattedFont = attrs[NSFontAttributeName];
             UIFont *label2Font = [[VThemeManager sharedThemeManager] themedFontForKey:kVLabel2Font];
             appliedLabel2FontToFullString = ([formattedFont isEqual:label2Font]) ? YES : NO;
         }
     }];
    
    XCTAssertTrue(appliedLinkColorToUsername);
    XCTAssertTrue(appliedLabel2FontToFullString);
}

@end
