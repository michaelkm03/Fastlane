//
//  VSelectorViewController.h
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  A cell configuration block for VSelectorViewController.
 */
typedef void (^VSelectionItemConfigureCellBlock)(UITableViewCell *cell, id item);

/**
 *  A selection block for VSelectorViewController.
 */
typedef void (^VSelectorViewControllerCompletionBlock)(id selectedItem);

/**
 *  VSelectorViewController provides a system-like UI for choosing among an array of items.
 */
@interface VSelectorViewController : UITableViewController

/**
 *  Use this method to create a VSelectorViewController.
 *
 *  @param items An array of items to choose from.
 *  @param configureBlock A configure block for each of the items. Use this to configure the UITableViewCell.
 *  @param completion A selection completion block. Will pass in nil for item.
 */
+ (instancetype)selectorViewControllerWithItemsToSelectFrom:(NSArray *)items
                                         withConfigureBlock:(VSelectionItemConfigureCellBlock)configureBlock
                                                 completion:(VSelectorViewControllerCompletionBlock)completion;

/**
 *  The items that this VSelectorViewController was initialized with.
 */
@property (nonatomic, strong, readonly) NSArray *items;

@end
