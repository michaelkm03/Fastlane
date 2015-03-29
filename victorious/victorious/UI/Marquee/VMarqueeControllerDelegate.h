//
//  VMarqueeControllerDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 3/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VAbstractMarqueeController, VStreamItem;

@protocol VMarqueeControllerDelegate <NSObject>

@required

- (void)marquee:(VAbstractMarqueeController *)marquee selectedItem:(VStreamItem *)streamItem atIndexPath:(NSIndexPath *)path previewImage:(UIImage *)image;
- (void)marqueeRefreshedContent:(VAbstractMarqueeController *)marquee;

@end
