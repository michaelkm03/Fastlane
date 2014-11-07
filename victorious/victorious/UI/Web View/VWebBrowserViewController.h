//
//  VWebBrowserViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence;

@interface VWebBrowserViewController : UIViewController

@property (nonatomic, strong) VSequence *sequence;

+ (VWebBrowserViewController *)instantiateFromNib;

- (void)loadUrl:(NSURL *)url;

- (void)loadUrlString:(NSString *)urlString;

@end
