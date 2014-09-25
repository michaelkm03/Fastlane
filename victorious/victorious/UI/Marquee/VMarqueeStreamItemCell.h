//
//  VMarqueeStreamItemCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"

@class VStreamItem;

@interface VMarqueeStreamItemCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, strong) VStreamItem *streamItem;

@end
