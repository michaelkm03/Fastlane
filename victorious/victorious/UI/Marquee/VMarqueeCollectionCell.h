//
//  VMarqueeCollectionCell.h
//  victorious
//
//  Created by Will Long on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"
#import "VTableViewCell.h"

@class VStreamItem, VMarqueeController;

@interface VMarqueeCollectionCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, readonly) UIImageView *currentPreviewImageView;
@property (nonatomic, readonly) VStreamItem *currentItem;
@property (nonatomic, strong) VMarqueeController *marquee;

- (void)restartAutoScroll;

@end
