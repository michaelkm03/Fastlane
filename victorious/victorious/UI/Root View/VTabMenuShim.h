//
//  VTabMenuShim.h
//  victorious
//
//  Created by Michael Sena on 3/18/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VHasManagedDependencies.h"

@class VBackground;

@interface VTabMenuShim : NSObject <VHasManagedDependancies>

- (NSArray *)wrappedNavigationDesinations;

@property (nonatomic, readonly) VBackground *background;

@end
