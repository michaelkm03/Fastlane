//
//  VWorkspaceShimDestination.h
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VNavigationDestination.h"
#import "VHasManagedDependencies.h"

/**
 *  Presents content creation on VRootViewController when VNavigationDestination's
 *  "-(BOOL)shouldNavigateWithAlternateDestination:" is called.
 */
@interface VWorkspaceShimDestination : NSObject <VHasManagedDependencies, VNavigationDestination>

@end
