//
//  VSwizzle.m
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VSwizzle.h"
#import <objc/runtime.h>

@implementation VSwizzle

+(void) swizzleWithOriginalClass:(Class)originalClass originalSelector:(SEL)originalSelector
				   swizzledClass:(Class)swizzledClass swizzledSelector:(SEL)swizzledSelector
{
	Method originalMethod = class_getInstanceMethod( originalClass, originalSelector );
	Method swizzledMethod = class_getInstanceMethod( swizzledClass, swizzledSelector );
	
	BOOL didAddMethod = class_addMethod(originalClass,
										originalSelector,
										method_getImplementation( swizzledMethod ),
										method_getTypeEncoding( swizzledMethod ) );
	if ( didAddMethod ) {
		class_replaceMethod(originalClass,
							swizzledSelector,
							method_getImplementation( originalMethod ),
							method_getTypeEncoding( originalMethod ) );
	} else {
		method_exchangeImplementations( originalMethod, swizzledMethod );
	}
}

@end