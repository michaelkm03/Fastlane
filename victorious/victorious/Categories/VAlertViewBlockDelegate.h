//
//  VAlertViewBlockDelegate.h
//  victorious
//
//  Created by Josh Hinman on 5/27/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 An implementation of `UIAlertViewDelegate` used by the UIAlertView+VBlocks category.
 */
@interface VAlertViewBlockDelegate : NSObject <UIAlertViewDelegate>

@property (nonatomic, copy)     void                (^onCancel)(void);
@property (nonatomic, readonly) NSMutableDictionary  *otherButtonHandlers;

/**
 The designated initializer.
 */
- (id)initWithCancelBlock:(void(^)(void))cancelBlock;

@end
