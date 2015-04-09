//
//  VDiscoverDeepLinkHandler.h
//  victorious
//
//  Created by Patrick Lynch on 4/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDeeplinkHandler.h"

@interface VDiscoverDeepLinkHandler : NSObject <VDeeplinkHandler>

@property (nonatomic, strong) UIViewController<VNavigationDestination> *navigationDestination;

@end
