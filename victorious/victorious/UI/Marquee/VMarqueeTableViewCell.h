//
//  VMarqueeTableViewCell.h
//  victorious
//
//  Created by Will Long on 9/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"

@class VStreamItem;

@interface VMarqueeTableViewCell : UITableViewCell <VSharedCollectionReusableViewMethods>

@property (nonatomic, readonly) VStreamItem *currentItem;

@end
