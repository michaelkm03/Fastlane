//
//  VNavigationWebBrowserHeader.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VNavigationWebBrowserHeaderDelegate <NSObject>

- (void)didGoBack;
- (void)didGoForward;
- (void)didExit;

@end

@interface VNavigationWebBrowserHeader : UIViewController

@property (nonatomic, weak) id<VNavigationWebBrowserHeaderDelegate> delegate;

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSURL *URL;

@property (nonatomic, assign) BOOL canGoBack;
@property (nonatomic, assign) BOOL canGoForward;

@end
