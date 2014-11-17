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

@property (nonatomic, copy, readonly) NSString *title; ///< The text to display in the menu
@property (nonatomic, strong, readonly) UIImage *icon; ///< An icon to display next to the label in the menu
@property (nonatomic, strong, readonly) id destination; ///< This menu item's destination. Should be either a UIViewController subclass or an implementation of VNavigationDestination

- (instancetype)initWithTitle:(NSString *)title icon:(UIImage *)icon destination:(id)destination NS_DESIGNATED_INITIALIZER;

@end
