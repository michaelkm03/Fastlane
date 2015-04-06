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

@interface VProfileDeeplinkHandler : NSObject <VDeeplinkHandler>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
