//
//  VCaptureContainerViewController.h
//  victorious
//
//  Created by Michael Sena on 7/7/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VAlternateCaptureOption;
@class VDependencyManager;

@interface VCaptureContainerViewController : UIViewController

+ (instancetype)captureContainerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Supports forwarding the contained ViewController's navigationItem's titleView to the captureContainer's titleView.
 */
- (void)setContainedViewController:(UIViewController *)viewController;

/**
 *  An array of VAlternateCaptureOptions.
 */
@property (nonatomic, strong) NSArray *alternateCaptureOptions;

@end
