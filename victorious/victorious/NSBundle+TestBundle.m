//
//  NSBundle+TestBundle.m
//  victorious
//
//  Created by Patrick Lynch on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

#import "NSBundle+TestBundle.h"

@implementation NSBundle (TestBundle)

- (BOOL)v_shouldCompleteLaunch
{
    NSBundle *testBundle = [NSBundle v_testBundle];
    if ( testBundle != nil )
    {
        NSNumber *shouldCompleteLaunchObject = [testBundle objectForInfoDictionaryKey:@"VShouldCompleteLaunch"];
        return shouldCompleteLaunchObject == nil ? NO : shouldCompleteLaunchObject.boolValue;
    }
    return YES;
}

+ (nullable NSBundle *)v_testBundle
{
    NSDictionary *environment = [[NSProcessInfo processInfo] environment];
    NSString *injectBundlePath = environment[@"XCInjectBundle"];
    
    if ( [[injectBundlePath pathExtension] isEqualToString:@"xctest"] )
    {
        NSBundle *bundleInCorrectLocation = [NSBundle bundleWithPath:injectBundlePath];
        
        if ( bundleInCorrectLocation != nil )
        {
            return bundleInCorrectLocation;
        }
        NSString *bundleName = [injectBundlePath lastPathComponent];
        NSString *alternateBundlePath = [NSTemporaryDirectory() stringByAppendingPathComponent:bundleName];
        return [NSBundle bundleWithPath:alternateBundlePath];
    }
    return nil;
}

@end