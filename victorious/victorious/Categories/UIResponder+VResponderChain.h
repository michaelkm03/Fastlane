//
//  UIResponder+VResponderChain.h
//  victorious
//
//  Created by Patrick Lynch on 5/19/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIResponder (VResponderChain)

/**
 Walks the responder chain starting with self, synchronously executing the
 provided block with the current responder in the chain on which to
 perform any operations or read any values.
 */
- (void)v_walkWithBlock:(void(^)(UIResponder *responder, BOOL *stop))block;

@end
