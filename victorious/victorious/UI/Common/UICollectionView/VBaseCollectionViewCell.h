//
//  VBaseCollectionViewCell.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"
#import "VSwipeCollectionViewCell.h"

/**
 *  Implements sensible defaults of VSharedCollectionReusableViewMethods. All CollectionViewCell subclasses should subclass VBaseCollectionViewCell.
 */
@interface VBaseCollectionViewCell : VSwipeCollectionViewCell <VSharedCollectionReusableViewMethods>

@end
