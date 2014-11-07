//
//  VValidator.h
//  victorious
//
//  Created by Patrick Lynch on 11/3/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VValidator : NSObject

/**
 Loads the appropriate title and error localized strings depending on the error's code property
 and displays an alert view.
 */
- (void)showAlertInViewController:(UIViewController *)viewController withError:(NSError *)error;

@end
