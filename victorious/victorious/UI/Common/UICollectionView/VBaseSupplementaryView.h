//
//  VBaseSupplementaryView.h
//  victorious
//
//  Created by Michael Sena on 9/12/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VSharedCollectionReusableViewMethods.h"

/**
 *  Implements sensible defaults of VSharedCollectionReusableViewMethods. All supplementary views should subclass VBaseSupplementaryView.
 */
@interface VBaseSupplementaryView : UICollectionReusableView <VSharedCollectionReusableViewMethods>

@end
