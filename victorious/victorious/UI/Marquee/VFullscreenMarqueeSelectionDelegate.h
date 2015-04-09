//
//  VFullscreenMarqueeControllerDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMarqueeSelectionDelegate.h"

@class VUser, VAbstractMarqueeController;

@protocol VFullscreenMarqueeSelectionDelegate <VMarqueeSelectionDelegate>

@required

- (void)marquee:(VAbstractMarqueeController *)marquee selectedUser:(VUser *)user atIndexPath:(NSIndexPath *)path;

@end