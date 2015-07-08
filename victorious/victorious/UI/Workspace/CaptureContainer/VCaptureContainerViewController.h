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

@protocol VCaptureContainedViewController <NSObject>

- (UIView *)titleView;

@end

@interface VCaptureContainerViewController : UIViewController

+ (instancetype)captureContainerWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)setContainedViewController:(UIViewController<VCaptureContainedViewController> *)viewController;

@property (nonatomic, strong) NSArray *alternateCaptureOptions;

@end
