//
//  VHashtagFollowingTableViewController.h
//  victorious
//
//  Created by Lawrence Leach on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"

@class PaginatedDataSource;

@interface VHashtagFollowingTableViewController : UITableViewController <VHasManagedDependencies>

@property (nonatomic, strong) PaginatedDataSource *paginatedDataSource;

@end
