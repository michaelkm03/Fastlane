//
//  VAlongsidePresentationAnimator.h
//  victorious
//
//  Created by Michael Sena on 7/21/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol VAlongsidePresentation <NSObject>

- (void)alongsidePresentation;

- (void)alongsideDismissal;

@end

@interface VAlongsidePresentationAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL presenting;

@end
