//
//  VWebBrowserViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

extern NSString * const VWebBrowserViewControllerLayoutKey;
extern NSString * const VWebBrowserViewControllerLayoutHeaderTop;
extern NSString * const VWebBrowserViewControllerLayoutHeaderBottom;
extern NSString * const VWebBrowserViewControllerHeaderContentAlignmentKey;

@class VSequence, VWebBrowserHeaderViewController;

@interface VWebBrowserViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;

@property (nonatomic, weak) VWebBrowserHeaderViewController *headerViewController;

@property (nonatomic, strong, readonly) VDependencyManager *dependencyManager;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)loadUrl:(NSURL *)url;

- (void)loadUrlString:(NSString *)urlString;

@end
