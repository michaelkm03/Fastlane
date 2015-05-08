//
//  VWebBrowserViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VWebBrowserLayout.h"

#import <UIKit/UIKit.h>

@class VSequence, VWebBrowserHeaderViewController;

@interface VWebBrowserViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, weak) VWebBrowserHeaderViewController *headerViewController;
@property (nonatomic, assign) NSString *layoutIdentifier;
@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, strong) NSString *templateTitle;
@property (nonatomic, assign) VWebBrowserHeaderContentAlignment headerContentAlignment;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)loadUrl:(NSURL *)url;

- (void)loadUrlString:(NSString *)urlString;

@end
