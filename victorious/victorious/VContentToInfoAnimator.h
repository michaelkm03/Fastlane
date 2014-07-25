//
//  VContentToInfoAnimator.h
//  victorious
//
//  Created by Will Long on 7/23/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VContentToInfoAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL isPresenting;

@property (nonatomic, weak) UIViewController* movingChildVC;///<The child VC that is transitioning to the toVC.
@property (nonatomic, weak) UIImage* movingImage;///<The view that is to be moved to the toVC.

@property (nonatomic, weak) UIView* fromChildContainerView;       ///<This is the view that contains the child VC
@property (nonatomic, weak) IBOutlet UIView* toChildContainerView;    ///<The new container for the childVC after the transition

@end
