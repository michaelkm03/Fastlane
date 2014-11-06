//
//  VWebBrowserHeaderView.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHeaderView.h"
#import "VProgressBarView.h"

@protocol VWebBrowserHeaderViewDelegate <NSObject>

- (BOOL)canGoBack;
- (BOOL)canGoForward;
- (void)goForward;
- (void)goBack;
- (void)openInBrowser;
- (void)exit;

@end

@interface VWebBrowserHeaderView : VHeaderView

@property (nonatomic, weak) id<VWebBrowserHeaderViewDelegate> browserDelegate;

- (void)updateHeaderState;
- (void)setTitle:(NSString *)title;
- (void)setSubtitle:(NSString *)subtitle;

- (void)setLoadingStarted;
- (void)setLoadingComplete:(BOOL)didFail;
- (void)setLoadingProgress:(float)loadingProgress;

@end
