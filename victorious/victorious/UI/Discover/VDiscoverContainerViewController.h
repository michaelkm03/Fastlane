//
//  VDiscoverContainerViewController.h
//  victorious
//
//  Created by Patrick Lynch on 10/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VTableContainerViewController.h"

@interface VDiscoverContainerViewController : VTableContainerViewController

+ (VDiscoverContainerViewController *)instantiateFromStoryboard:(NSString *)storyboardName;

@end
