//
//  NSObject+VMethodSwizzling.m
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "NSObject+VMethodSwizzling.h"

#import <objc/runtime.h>

@implementation NSObject (VMethodSwizzling)

+ (void)v_swizzleMethod:(SEL)aOriginalMethod withMethod:(SEL)aNewMethod executeBlock:(void (^)(void))aBlock
{
    Method originalMethod = class_getInstanceMethod(self, aOriginalMethod);
    Method mockMethod = class_getInstanceMethod(self, aNewMethod);
    method_exchangeImplementations(originalMethod, mockMethod);
    if ( aBlock )
    {
        aBlock();
    }
    method_exchangeImplementations(mockMethod, originalMethod);
}

+ (void)v_swizzleMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock executeBlock:(void (^)(void))aBlock
{
    Method originalMethod = class_getInstanceMethod(self, aOriginalMethod);
    IMP imp_original = method_getImplementation(originalMethod);
    // exchange
    IMP imp_newBlock = imp_implementationWithBlock(aNewBlock);
    method_setImplementation(originalMethod, imp_newBlock);
    if ( aBlock )
    {
        aBlock();
    }
    method_setImplementation(originalMethod, imp_original);
}

+ (IMP)v_swizzleMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock
{
    Method originalMethod = class_getInstanceMethod(self, aOriginalMethod);
    IMP imp_original = method_getImplementation(originalMethod);
    // exchange
    IMP imp_newBlock = imp_implementationWithBlock(aNewBlock);
    method_setImplementation(originalMethod, imp_newBlock);
    return imp_original;
}

+ (void)v_restoreOriginalImplementation:(IMP)originalImplementation forMethod:(SEL)aOriginalMethod
{
    Method originalMethod = class_getInstanceMethod(self, aOriginalMethod);
    method_setImplementation(originalMethod, originalImplementation);
}

+ (void)v_swizzleClassMethod:(SEL)aOriginalMethod withClassMethod:(SEL)aNewMethod executeBlock:(void (^)(void))aBlock
{
    Method originalMethod = class_getClassMethod(self, aOriginalMethod);
    Method mockMethod = class_getClassMethod(self, aNewMethod);
    method_exchangeImplementations(originalMethod, mockMethod);
    if ( aBlock )
    {
        aBlock();
    }
    method_exchangeImplementations(mockMethod, originalMethod);
}

+ (void)v_swizzleClassMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock executeBlock:(void (^)(void))aBlock
{
    Method originalMethod = class_getClassMethod(self, aOriginalMethod);
    IMP imp_original = method_getImplementation(originalMethod);
    // exchange
    IMP imp_newBlock = imp_implementationWithBlock(aNewBlock);
    method_setImplementation(originalMethod, imp_newBlock);
    if ( aBlock )
    {
        aBlock();
    }
    method_setImplementation(originalMethod, imp_original);
}

+ (IMP)v_swizzleClassMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock
{
    Method originalMethod = class_getClassMethod(self, aOriginalMethod);
    IMP imp_original = method_getImplementation(originalMethod);
    // exchange
    IMP imp_newBlock = imp_implementationWithBlock(aNewBlock);
    method_setImplementation(originalMethod, imp_newBlock);
    return imp_original;
}

+ (void)v_restoreOriginalImplementation:(IMP)originalImplementation forClassMethod:(SEL)aOriginalMethod
{
    Method originalMethod = class_getClassMethod(self, aOriginalMethod);
    method_setImplementation(originalMethod, originalImplementation);
}

@end
