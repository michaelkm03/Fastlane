//
//  VBlurOverTransitioner.h
//  victorious
//
//  Created by Michael Sena on 3/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VBlurOverAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter=isPresentation) BOOL presentation;

@end

@interface VBlurOverTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate>

@end
