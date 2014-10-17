//
//  VActionSheetPresentationAnimator.h
//  victorious
//
//  Created by Michael Sena on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VActionSheetPresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign, getter = isPresenting) BOOL presenting;

@end
