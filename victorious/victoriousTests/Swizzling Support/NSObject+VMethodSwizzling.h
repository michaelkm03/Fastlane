//
//  NSObject+VMethodSwizzling.h
//  victorious
//
//  Created by Josh Hinman on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (VMethodSwizzling)

/**
 Swaps the implementations of two instance methods,
 executes a block, then restores the original
 method implementations.
 */
+ (void)v_swizzleMethod:(SEL)aOriginalMethod withMethod:(SEL)aNewMethod executeBlock:(void (^)(void))aBlock;

/**
 Replaces the implementation of an instance method with a block, executes
 a block, then restores the original method implementation.
 */
+ (void)v_swizzleMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock executeBlock:(void (^)(void))aBlock;

/**
 Replaces the implementation of an instance method with a block
 
 @return the method's original implementation
 */
+ (IMP)v_swizzleMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock;

/**
 Restores the original implementation of an instance
 method that was previously swizzled.
 */
+ (void)v_restoreOriginalImplementation:(IMP)originalImplementation forMethod:(SEL)aOriginalMethod;

/**
 Swaps the implementations of two class methods,
 executes a block, then restores the original
 method implementations.
 */
+ (void)v_swizzleClassMethod:(SEL)aOriginalMethod withClassMethod:(SEL)aNewMethod executeBlock:(void (^)(void))aBlock;

/**
 Replaces the implementation of a class method with a block, executes
 a block, then restores the original method implementation.
 */
+ (void)v_swizzleClassMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock executeBlock:(void (^)(void))aBlock;

/**
 Replaces the implementation of a class method with a block
 
 @return the method's original implementation
 */
+ (IMP)v_swizzleClassMethod:(SEL)aOriginalMethod withBlock:(id)aNewBlock;

/**
 Restores the original implementation of a class
 method that was previously swizzled.
 */
+ (void)v_restoreOriginalImplementation:(IMP)originalImplementation forClassMethod:(SEL)aOriginalMethod;

@end
