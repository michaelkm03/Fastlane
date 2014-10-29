//
//  VCollectionRefreshControl.h
//  victorious
//
//  Created by Will Long on 10/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A UIRefreshControl that allows you to modify the top offset.  First it takes into account the scrollview's insets (like UIRefreshControl) and then adds the topOffset property.  Note: expects to be a subview of a scrollview.  Will result in a crash if its place in another view type.
 */
@interface VCollectionRefreshControl : UIRefreshControl

@property (nonatomic) CGFloat topOffset;

@end
