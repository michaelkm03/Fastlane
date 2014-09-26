//
//  VMarqueeTableViewCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"
#import "VTableViewCell.h"

@protocol VMarqueeDelegate;

@class VStreamItem;

@interface VMarqueeTableViewCell : VTableViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, readonly) VStreamItem *currentItem;
@property (nonatomic, weak) id<VMarqueeDelegate> delegate;

- (void)restartAutoScroll;

@end
