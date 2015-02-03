//
//  VSearchResultsNavigationController.h
//  victorious
//
//  Created by Lawrence Leach on 2/3/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VUsersAndTagsSearchViewController.h"

@interface VSearchResultsNavigationController : UINavigationController

@property (nonatomic, strong) VUsersAndTagsSearchViewController *usersAndTagsSearchViewController;

@end
