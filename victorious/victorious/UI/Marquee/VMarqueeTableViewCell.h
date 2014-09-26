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

@class VStreamItem, VUser, VMarqueeTableViewCell;

@protocol VMarqueeTableCellDelegate

- (void)marqueTableCell:(VMarqueeTableViewCell *)cell selectedItem:(VStreamItem *)item;
- (void)marqueTableCell:(VMarqueeTableViewCell *)cell selectedUser:(VUser *)user;

@end

@interface VMarqueeTableViewCell : VTableViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, readonly) VStreamItem *currentItem;
@property (nonatomic, weak) id<VMarqueeTableCellDelegate> delegate;

- (void)restartAutoScroll;

@end
