//
//  VSwizzle.h
//  victorious
//
//  Created by Patrick Lynch on 9/30/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VSwizzle : NSObject

/**
 Switches method implementations.
 Based on sample by NSHipter http://nshipster.com/method-swizzling/
 */
+ (void)swizzleWithOriginalClass:(Class)originalClass originalSelector:(SEL)originalSelector
				   swizzledClass:(Class)swizzledClass swizzledSelector:(SEL)swizzledSelector;

@end