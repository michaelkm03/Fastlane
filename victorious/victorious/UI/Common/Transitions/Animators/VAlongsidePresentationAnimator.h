//
//  VAlongsidePresentationAnimator.h
//  victorious
//
//  Created by Michael Sena on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAlongsidePresentation <NSObject>

/**
 *  Use this method to animate alongside presentation.
 */
- (void)alongsidePresentation;

/**
 *  Use this method to animate alongside dismissal.
 */
- (void)alongsideDismissal;

@end

/**
 *  VAlongsidePresentationAnimator is a presentation animator that provides the destination
 *  with hooks to add their own animations that occur alongside the presentation animation.
 *  When a VAlongsidePresentationAnimator is the transition animator for the destinaiton
 *  it should implement the VAlongsidePresentation protocol to customize their animations 
 *  that occur alongside presentation/dismissal.
 */
@interface VAlongsidePresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
