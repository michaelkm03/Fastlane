//
//  VWebBrowserActions.h
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VSequence;

@interface VWebBrowserActions : NSObject

- (void)showInViewController:(UIViewController *)viewController withCurrentUrl:(NSURL *)url text:(NSString *)text;

@end
