//
//  VContentDeepLinkHandler.h
//  victorious
//
//  Created by Patrick Lynch on 4/6/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VDeeplinkHandler.h"

@class VScaffoldViewController;

/**
 Displays a content view for deeplink URLs that point to content views.
 
 @return YES if the given URL was a content URL, or NO if it was
 some other kind of deep link.
 */
@interface VContentDeepLinkHandler : NSObject <VDeeplinkHandler>

@property (nonatomic, weak) VScaffoldViewController *scaffoldViewController;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
