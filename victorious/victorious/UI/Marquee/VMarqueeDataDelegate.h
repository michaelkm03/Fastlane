//
//  VMarqueeDataDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VAbstractMarqueeController;

/**
    This protocol allows delegates to respond to changes in marquee content
 */
@protocol VMarqueeDataDelegate <NSObject>

@required

- (void)marqueeController:(VAbstractMarqueeController *)marquee reloadedStreamWithItems:(NSArray *)streamItems;

@end
