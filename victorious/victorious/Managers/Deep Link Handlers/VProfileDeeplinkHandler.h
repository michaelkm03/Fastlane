//
//  VProfileDeeplinkHandler.h
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDeeplinkHandler.h"

@class VDependencyManager;

/**
 Handles deep links related to showing user profiles.
 */
@interface VProfileDeeplinkHandler : NSObject <VDeeplinkHandler>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
