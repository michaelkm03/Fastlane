//
//  VMarqueeStreamItemCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"

@class VStreamItem, VUser, VMarqueeStreamItemCell, VDefaultProfileButton;

/**
 *  Delegate for a VMarqueeStreamItemCell
 */
@protocol VMarqueeCellDelegate <NSObject>

- (void)cell:(VMarqueeStreamItemCell *)cell selectedUser:(VUser *)user;///<Sent when the user button is clicked in a marquee cell

@end

/**
 *  A cell that displays a streamItem for a Marquee
 */
@interface VMarqueeStreamItemCell : UICollectionViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, strong) VStreamItem *streamItem; ///<Stream item to display
@property (nonatomic, weak) id<VMarqueeCellDelegate> delegate;
@property (nonatomic, weak, readonly) UIImageView *previewImageView;

@end
