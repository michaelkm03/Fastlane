//
//  VBackground.h
//  victorious
//
//  Created by Michael Sena on 2/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

/**
 *  Background components sit behind a user interface and are usually not themselves interactive;
    they just make everything look pretty.
 */
@interface VBackground : NSObject <VHasManagedDependancies>

/**
 *  MUST be overriden by subclasses!
 *
 *  @return A view representing the appropriate background.
 */
- (UIView *)viewForBackground;

/**
 *  If this is a translucent background and should show content scrolling underneath.
    Use this property to adjust insets or layout accordingly.
 */
@property (nonatomic, readonly) BOOL isTranslucent;

@end
