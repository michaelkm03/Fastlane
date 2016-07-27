//
//  VFullscreenMarqueeControllerDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMarqueeSelectionDelegate.h"

@class VUser, VAbstractMarqueeController;

/**
 An extension, of sorts, of the VMarqueeSelectionDelegate protocol to allow delegates
 to respond to selections of users from the marquee cells.
 */
@protocol VFullscreenMarqueeSelectionDelegate <VMarqueeSelectionDelegate>

- (void)marqueeController:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;

@end
