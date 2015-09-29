//
//  VMarqueeSelectionDelegate.h
//  victorious
//
//  Created by Sharif Ahmed on 4/8/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VAbstractMarqueeController, VStreamItem, VUser;

NS_ASSUME_NONNULL_BEGIN

/**
 Allows delegates to respond to selection of marquee items.
 */
@protocol VMarqueeSelectionDelegate <NSObject>

- (void)marqueeController:(VAbstractMarqueeController *)marquee
            didSelectItem:(VStreamItem *)streamItem
         withPreviewImage:(nullable UIImage *)image
       fromCollectionView:(UICollectionView *)collectionView
              atIndexPath:(NSIndexPath *)path;

@end

NS_ASSUME_NONNULL_END
