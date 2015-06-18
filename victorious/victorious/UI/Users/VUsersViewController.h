//
//  VUsersViewController.h
//  victorious
//
//  Created by Patrick Lynch on 6/17/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VHasManagedDependencies.h"
#import "VUsersDataSource.h"

@interface VUsersViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) id<VUsersDataSource> usersDataSource;

@end
