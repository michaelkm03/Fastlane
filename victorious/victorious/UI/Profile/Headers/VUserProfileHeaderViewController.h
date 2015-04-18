//
//  VUserProfileHeaderViewController.h
//  victorious
//
//  Created by Will Long on 6/18/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VButton.h"
#import "VHasManagedDependencies.h"
#import "VUserProfileHeader.h"

@class VUser, VDefaultProfileImageView, VDependencyManager;

@interface VUserProfileHeaderViewController : UIViewController <VUserProfileHeader, VHasManagedDependencies>

@end
