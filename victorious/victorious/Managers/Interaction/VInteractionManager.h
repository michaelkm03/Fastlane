//
//  VInteractionManager.h
//  victorious
//
//  Created by Will Long on 3/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VInteraction, VNode;

@protocol VInteractionManagerDelegate <NSObject>
@required

- (void)firedInteraction:(VInteraction *)interaction;

@end

@interface VInteractionManager : NSObject

@property (strong, nonatomic) VNode *node;
@property (readonly, nonatomic) NSArray *interactions;
@property (readonly, nonatomic) CGFloat lastInteractionTimeout;
@property (weak, nonatomic) id<VInteractionManagerDelegate> delegate;

- (instancetype)initWithNode:(VNode *)node delegate:(id<VInteractionManagerDelegate>)delegate;
- (void)startInteractionTimerAtTime:(CGFloat)seconds;
- (void)pauseInterationTimer;

@end
