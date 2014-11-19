//
//  VDiscoverContainerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTableContainerViewController.h"
#import "VHasManagedDependencies.h"

@interface VDiscoverContainerViewController : VTableContainerViewController <VHasManagedDependancies>

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

@end
