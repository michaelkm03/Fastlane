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

/**
 Delegate that provides navigation state data to the web browser header
 so that it can accurate represent navigation abilities.
 */
@protocol VWebBrowserHeaderStateDataSource <NSObject>

- (BOOL)canGoBack;      ///< Has the user navigated to another URL, adding at least 1 URL to the history
- (BOOL)canGoForward;   ///< Has the use navigated back after navigating forward, with at least 1 URL in the future
- (BOOL)canRefresh;     ///< Are all other loading or current refresh operations finished

@end

/**
 Delegate thatresponds to
 input events from with the header.
 */
@protocol VWebBrowserHeaderViewDelegate <NSObject>

- (void)goForward;      ///< The user has selected the forward button and wants to move forward
- (void)goBack;         ///< The user has selected the back button and wants to move back
- (void)reload;         ///< The user has selected the reload button to reload the current page
- (void)export;         ///< The user has selected to export button to present share/export options
- (void)exit;           ///< The user has selected the exit button to dismiss the web browser

@end

@interface VWebBrowserHeaderViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, weak) id<VWebBrowserHeaderViewDelegate> delegate;
@property (nonatomic, weak) id<VWebBrowserHeaderStateDataSource> stateDataSource;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@property (nonatomic, strong, readonly) IBOutlet VWebBrowserHeaderLayoutManager *layoutManager;

@property (nonatomic, weak, readonly) IBOutlet UIButton *buttonBack;
@property (nonatomic, weak, readonly) IBOutlet UILabel *labelTitle;
@property (nonatomic, weak, readonly) IBOutlet VProgressBarView *progressBar;

- (void)setTitle:(NSString *)title;
- (void)setLoadingStarted;
- (void)setLoadingComplete:(BOOL)didFail;
- (void)setLoadingProgress:(float)loadingProgress;

@end
