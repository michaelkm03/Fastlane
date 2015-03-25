//
//  VPublishViewController.h
//  victorious
//
//  Created by Michael Sena on 12/17/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VHasManagedDependencies.h"

@class VPublishParameters;

/**
 *  A ViewController for publshing content.
 */
@interface VPublishViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, copy) void (^completion)(BOOL published); ///< Called upon completion, YES indicates successful publish

@property (nonatomic, copy, readonly) void (^animateInBlock)(void); ///< PublishViewController wants this to be called by animators

@property (nonatomic, strong) VPublishParameters *publishParameters; ///< Publish parameters that are to be configured by this publishViewController

@end
