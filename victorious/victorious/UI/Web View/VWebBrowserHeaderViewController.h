//
//  VWebBrowserHeaderViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VProgressBarView.h"

@protocol VWebBrowserHeaderViewDelegate <NSObject>

- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (BOOL)canRefresh;
- (void)goForward;
- (void)goBack;
- (void)reload;
- (void)export;
- (void)exit;

@end

@interface VWebBrowserHeaderViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager;
@property (nonatomic, weak) id<VWebBrowserHeaderViewDelegate> browserDelegate;

- (void)updateHeaderState;
- (void)setTitle:(NSString *)title;
- (void)setLoadingStarted;
- (void)setLoadingComplete:(BOOL)didFail;
- (void)setLoadingProgress:(float)loadingProgress;

@end
