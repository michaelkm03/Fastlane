//
//  UIAlertController+VSimpleAlert.h
//  victorious
//
//  Created by Michael Sena on 6/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertController (VSimpleAlert)

/**
 *  A convenience factory method for creation an alert with a title, message, and cancel button title.
 */
+ (instancetype)simpleAlertControllerWithTitle:(NSString *)title
                                       message:(NSString *)message
                          andCancelButtonTitle:(NSString *)cancelButtontitle;

@end
