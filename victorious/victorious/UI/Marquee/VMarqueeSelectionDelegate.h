//
//  VMarqueeSelectionDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VAbstractMarqueeController, VStreamItem, VUser;

@protocol VMarqueeSelectionDelegate <NSObject>

/**
    This protocol allows delegates to respond to selections of marquee content
 */
@required

- (void)marquee:(VAbstractMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image;

@end
