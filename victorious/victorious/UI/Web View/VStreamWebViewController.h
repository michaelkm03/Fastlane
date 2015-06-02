//
//  VStreamWebViewController.h
//  victorious
//
//  Created by Patrick Lynch on 1/26/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VStreamWebViewControllerDelegate <NSObject>

- (void)streamWebViewControllerContentIsVisible;

@end

@interface VStreamWebViewController : UIViewController

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, weak) id <VStreamWebViewControllerDelegate> delegate;

@end
