//
//  VAnimatedTransitionViewController.h
//  victorious
//
//  Created by Patrick Lynch on 12/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAnimatedTransitionViewController <NSObject>

- (void)prepareForTransitionIn:(UIImageView *)imageViewOfOriginViewControllerOrNil;

- (void)performTransitionIn:(NSTimeInterval)duration;

- (void)prepareForTransitionOut:(UIImageView *)imageViewOfOriginViewControllerOrNil;

- (void)performTransitionOut:(NSTimeInterval)duration;

- (BOOL)requiresImageViewFromOriginViewController;

@end
