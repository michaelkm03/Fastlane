//
//  VWebViewAdapter.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VWebViewDelegate <NSObject>

@end


@protocol VWebViewProtocol <NSObject>

@property (nonatomic, readonly) UIView *asView;
@property (nonatomic, strong) id<VWebViewDelegate> unifiedDelegate;

- (void)stringByEvaluatingJavaScriptFromString:(NSString *)script completionHandler:(void (^)(id, NSError *))completionHandler;
- (void)loadRequest:(NSURLRequest *)request;
- (void)goBack;
- (void)goForward;

@optional

- (void)reload;
- (void)stopLoading;

@end