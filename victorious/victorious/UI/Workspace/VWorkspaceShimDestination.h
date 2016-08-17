//
//  VWorkspaceShimDestination.h
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

/**
 *  Presents content creation on VRootViewController when VNavigationDestination's
 *  `-(BOOL)shouldNavigate` is called.
 */
@interface VWorkspaceShimDestination : NSObject <VHasManagedDependencies>

@end
