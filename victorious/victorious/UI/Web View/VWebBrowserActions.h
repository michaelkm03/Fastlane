//
//  VWebBrowserActions.h
//  victorious
//
//  Created by Patrick Lynch on 11/6/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@import FBSDKShareKit;

@interface VWebBrowserActions : NSObject

/**
 The mode to use when creating a Facebook share dialog.
 Default is FBSDKShareDialogModeAutomatic
 */
@property (nonatomic) FBSDKShareDialogMode shareMode;

- (void)showInViewController:(UIViewController *)viewController withCurrentUrl:(NSURL *)url titleText:(NSString *)title descriptionText:(NSString *)description;

@end
