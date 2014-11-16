//
//  VNavigationMenuItem.h
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/**
 An item in a navigation menu
 */
@interface VNavigationMenuItem : NSObject

@property (nonatomic, copy, readonly) NSString *label; ///< The text to display in the menu
@property (nonatomic, strong, readonly) UIImage *icon; ///< An icon to display next to the label in the menu
@property (nonatomic, strong, readonly) UIViewController *destination; ///< The view controller that will be displayed when this menu item is selected

- (instancetype)initWithLabel:(NSString *)label icon:(UIImage *)icon destination:(UIViewController *)destination NS_DESIGNATED_INITIALIZER;

@end
