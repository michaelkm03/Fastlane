//
//  VModalTransition.h
//  victorious
//
//  Created by Patrick Lynch on 12/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAnimatedTransition.h"

/**
 To be animated in the transition style of VModalTransition, the preseted view
 controller must conform to this protocol
 */
@protocol VModalTransitionPresentedViewController <NSObject>

@property (nonatomic, weak) UIView *view;
@property (nonatomic, weak) UIView *backgroundScreen;
@property (nonatomic, weak) UIView *modalContainer;

@end

@interface VModalTransition : NSObject <VAnimatedTransition>

@end
