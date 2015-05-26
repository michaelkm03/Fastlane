//
//  VDependencyManager+VBackgroundContainer.h
//  victorious
//
//  Created by Michael Sena on 3/27/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VDependencyManager.h"
#import "VBackgroundContainer.h"

/**
 *  Convenience category to safely add backgrounds to background hosts. Can only host one 
 *  type of background either background or loading background.
 */
@interface VDependencyManager (VBackgroundContainer)

/**
 *  Looks for a background at the current dependency manager level and adds 
 *  it to the background host. Fitting to the container's full size with autolayout.
 *
 *  @param backgroundHost An object that conforms to <VBackgroundContainer>
 */
- (void)addBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundContainer;

/**
 *  Adds a loading background to background hosts that provide a loading backgroundContainer. 
 *  Only adds the background if the viewForBackground has no VBackground subviews. Will send 
 *  the background view to the bottom of the subviews stack.
 *
 *  @param backgroundHost An object that conforms to <VBackgroundContainer>
 */
- (void)addLoadingBackgroundToBackgroundHost:(id <VBackgroundContainer>)backgroundContainer;

@end
