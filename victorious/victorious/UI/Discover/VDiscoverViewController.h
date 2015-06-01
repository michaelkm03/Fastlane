//
//  VDiscoverViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VMultipleContainer.h"

@class VDependencyManager;

enum
{
    VDiscoverViewControllerSectionSuggestedPeople,
    VDiscoverViewControllerSectionTrendingTags,
    VDiscoverViewControllerSectionsCount
};

@interface VDiscoverViewController : UITableViewController <VMultipleContainerChild>

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
