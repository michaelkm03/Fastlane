//
//  UIActionSheet+VBlocks.h
//  victorious
//
//  Created by Josh Hinman on 4/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIActionSheet (VBlocks)

/**
 Creates an action sheet using blocks instead of a delegate
 */
- (instancetype)initWithTitle:(NSString *)title
            cancelButtonTitle:(NSString *)cancelButtonTitle
               onCancelButton:(void(^)(void))cancelButtonBlock
       destructiveButtonTitle:(NSString *)destructiveButtonTitle
          onDestructiveButton:(void(^)(void))destructiveButtonBlock
   otherButtonTitlesAndBlocks:(NSString *)firstButtonTitle, ... NS_REQUIRES_NIL_TERMINATION;

/**
 Adds a button and block to the receiver. Only call this method on
 a receiver that has been initialized with the block initalizer,
 otherwise it will have no effect.
 */
- (NSInteger)addButtonWithTitle:(NSString *)title block:(void(^)(void))block;

/**
 Sets a block to be called when the action sheet is cancelled.
 Only call this method on a receiver that has been initial-
 ized with the block initalizer, otherwise it will have no 
 effect.
 */
- (void)setOnActionSheetCancel:(void(^)(void))cancelBlock;

@end
