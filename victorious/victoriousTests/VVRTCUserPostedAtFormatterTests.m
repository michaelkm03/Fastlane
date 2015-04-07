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
#import "VDependencyManager.h"

@interface VVRTCUserPostedAtFormatterTests : XCTestCase

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end

@implementation VVRTCUserPostedAtFormatterTests

- (void)setUp
{
    //Setup a dependency manager to pass into the VRTCUserPostedAtFormatter calls below
    self.dependencyManager = [[VDependencyManager alloc] initWithParentManager:nil
                                                                 configuration:@{
                                                                                 VDependencyManagerLinkColorKey : @{
                                                                                         @"red" : @255,
                                                                                         @"green" : @0,
                                                                                         @"blue" : @255,
                                                                                         @"alpha" : @255
                                                                                         },
                                                                                 VDependencyManagerLabel2FontKey : @{
                                                                                         @"fontSize" : @10,
                                                                                         @"fontName" : @"STHeitiSC-Light"
                                                                                         }
                                                                                 }
                                             dictionaryOfClassesByTemplateName:nil];
}

- (void)testNilArguments
{
    XCTAssertNoThrow([VRTCUserPostedAtFormatter formatRTCUserName:nil
                                            withDependencyManager:self.dependencyManager]);
    XCTAssertNoThrow([VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:nil
                                                                             andPostedTime:nil
                                                                     withDependencyManager:self.dependencyManager]);
    
    NSAttributedString *shouldBeNil = [VRTCUserPostedAtFormatter formatRTCUserName:nil
                                                             withDependencyManager:self.dependencyManager];
    XCTAssertNil(shouldBeNil);
    
    shouldBeNil = [VRTCUserPostedAtFormatter formattedRTCUserPostedAtStringWithUserName:nil
                                                                          andPostedTime:nil
                                                                  withDependencyManager:self.dependencyManager];
    XCTAssertNil(shouldBeNil);
}

- (void)testFormatRTCUserName
{
    NSAttributedString *test = [VRTCUserPostedAtFormatter formatRTCUserName:@"username"
                                                      withDependencyManager:self.dependencyManager];
    __block BOOL appliedLinkColor;
    __block BOOL appliedLabel2Font;
    
    [test enumerateAttributesInRange:NSMakeRange(0, test.string.length)
                             options:kNilOptions
                          usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
     {
         if (attrs[NSForegroundColorAttributeName] != nil)
         {
             UIColor *formattedColor = attrs[NSForegroundColorAttributeName];
             UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
             appliedLinkColor = ([formattedColor isEqual:linkColor]) ? YES : NO;
         }
         if (attrs[NSFontAttributeName] != nil)
         {
             UIFont *formattedFont = attrs[NSFontAttributeName];
             UIFont *label2Font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
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
                                                                                       andPostedTime:@1.5f
                                                                               withDependencyManager:self.dependencyManager];
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
             UIColor *linkColor = [self.dependencyManager colorForKey:VDependencyManagerLinkColorKey];
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
             UIFont *label2Font = [self.dependencyManager fontForKey:VDependencyManagerLabel2FontKey];
             appliedLabel2FontToFullString = ([formattedFont isEqual:label2Font]) ? YES : NO;
         }
     }];
    
    XCTAssertTrue(appliedLinkColorToUsername);
    XCTAssertTrue(appliedLabel2FontToFullString);
}

@end
