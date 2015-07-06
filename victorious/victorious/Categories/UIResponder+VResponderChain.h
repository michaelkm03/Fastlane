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

/**
 Walks the responder chain test for conformance to the provided protocol and 
 returns any resonder that does so.  Intended as a complement to `targetForAction:withSender`
 that allows locating an object in the responder chain by protocol instead of
 by a specific selector.
 */
- (id)v_targetConformingToProtocol:(Protocol *)protocol;

/**
 Logs the entire responder chain starting with self.
 */
- (void)v_logResponderChain;

@end
