//
//  VWebBrowserViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <UIKit/UIKit.h>

@class VSequence;

@interface VWebBrowserViewController : UIViewController <VHasManagedDependencies>

@property (nonatomic, strong) VSequence *sequence;

+ (instancetype)newWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)loadUrl:(NSURL *)url;

- (void)loadUrlString:(NSString *)urlString;

@end
