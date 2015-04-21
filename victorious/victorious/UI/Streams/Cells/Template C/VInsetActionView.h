//
//  VInsetActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractActionView.h"
#import "VHasManagedDependencies.h"

/**
 *  VInsetActionView is a VAbstractActionView subclass for use in insetCollectionCells.
 */
@interface VInsetActionView : VAbstractActionView <VHasManagedDependencies>

@end
