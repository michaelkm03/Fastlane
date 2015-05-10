//
//  VSleekActionView.h
//  victorious
//
//  Created by Michael Sena on 4/14/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VAbstractActionView.h"
#import "VHasManagedDependencies.h"
#import "VStreamCellSpecialization.h"

/**
 *  An VAbstractActionView for sleek cells
 */
@interface VSleekActionView : VAbstractActionView <VHasManagedDependencies, VStreamCellComponentSpecialization>

@end
