//
//  VPublishViewController.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"
#import "VDependencyManager.h"

@class VPublishParameters;

/**
 *  A ViewController for publshing content.
 */
@interface VPublishViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, copy) void (^completion)(BOOL published); ///< Called upon completion, YES indicates successful publish

@property (nonatomic, strong) VPublishParameters *publishParameters; ///< Publish parameters that are to be configured by this publishViewController

@end

@interface VDependencyManager (VPublishViewController)

/**
    Creates and returns a new publish view controller based on the contents of this dependency manager.
 */
- (VPublishViewController *)newPublishViewController;

@end
