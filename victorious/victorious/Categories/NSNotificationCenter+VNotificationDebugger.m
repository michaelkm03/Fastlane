//
//  NSNotificationCenter+VNotificationDebugger.m
//  victorious
//
//  Created by Josh Hinman on 9/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSNotificationCenter+VNotificationDebugger.h"

#import <objc/runtime.h>

@implementation NSNotificationCenter (VNotificationDebugger)

#if 0 // Set to '1' to debug notifications.

#warning NOTIFICATION DEBUGGER ACTIVE. Please de-activate when you're done.

+ (void)load
{
    Method addObserverSelectorNameObject = class_getInstanceMethod([NSNotificationCenter class], @selector(addObserver:selector:name:object:));
    Method vAddObserverSelectorNameObject = class_getInstanceMethod([NSNotificationCenter class], @selector(v_addObserver:selector:name:object:));
    method_exchangeImplementations(addObserverSelectorNameObject, vAddObserverSelectorNameObject);
    
    Method removeObserverNameObject = class_getInstanceMethod([NSNotificationCenter class], @selector(removeObserver:name:object:));
    Method vRemoveObserverNameObject = class_getInstanceMethod([NSNotificationCenter class], @selector(v_removeObserver:name:object:));
    method_exchangeImplementations(removeObserverNameObject, vRemoveObserverNameObject);
}

- (void)v_addObserver:(id)observer selector:(SEL)aSelector name:(NSString *)aName object:(id)anObject
{
    VLog(@"addObserver: '%@' is observing '%@'", [anObject description], aName);
    [self v_addObserver:observer selector:aSelector name:aName object:anObject];
}

- (void)v_removeObserver:(id)observer name:(NSString *)aName object:(id)anObject
{
    VLog(@"removeObserver: '%@' is being removed as an observer from '%@'", [observer description], aName);
    [self v_removeObserver:observer name:aName object:anObject];
}

#endif

@end
