//
//  VWebBrowserHeaderViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"
#import "VProgressBarView.h"
#import "VWebBrowserHeaderLayoutManager.h"

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
@property (nonatomic, strong) IBOutlet VWebBrowserHeaderLayoutManager *layoutManager;

@property (nonatomic, weak) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak) IBOutlet VProgressBarView *progressBar;

- (void)setTitle:(NSString *)title;
- (void)setLoadingStarted;
- (void)setLoadingComplete:(BOOL)didFail;
- (void)setLoadingProgress:(float)loadingProgress;

@end
