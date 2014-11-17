//
//  VInboxContainerViewController.h
//  victorious
//
//  Created by Will Long on 5/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNavigationDestination.h"
#import "VTableContainerViewController.h"

@interface VInboxContainerViewController : VTableContainerViewController <VNavigationDestination>

+ (instancetype)inboxContainer;

@end
