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

NS_ASSUME_NONNULL_BEGIN

@interface VCaptureContainerViewController : UIViewController

+ (instancetype)captureContainerWithDependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Supports forwarding the contained ViewController's navigationItem's titleView to the captureContainer's titleView.
 */
- (void)setContainedViewController:(UIViewController *)viewController;

/**
 *  An array of VAlternateCaptureOptions. Disables the alternate capture buttons after an option has been chosen. 
 *  Will not re-enable until viewWillAppear: is called again.
 */
@property (nonatomic, strong) NSArray *alternateCaptureOptions;

@end

NS_ASSUME_NONNULL_END
