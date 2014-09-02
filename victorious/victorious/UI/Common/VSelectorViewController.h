//
//  VSelectorViewController.h
//  victorious
//
//  Created by Michael Sena on 8/25/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSelectorViewController;

@protocol VSelectorViewControllerDelegate <NSObject>

- (void)vSelectorViewController:(VSelectorViewController *)selectorViewController
                  didSelectItem:(id)selectedItem;

- (void)vSelectorViewControllerDidCancel:(VSelectorViewController *)selectorViewController;

@end

typedef void (^VSelectionItemConfigureCellBlock)(UITableViewCell *cell, id item);

@interface VSelectorViewController : UITableViewController

+ (instancetype)selectorViewControllerWithItemsToSelectFrom:(NSArray *)items
                                         withConfigureBlock:(VSelectionItemConfigureCellBlock)configureBlock;

@property (nonatomic, strong, readonly) NSArray *items;

@property (nonatomic, weak) id <VSelectorViewControllerDelegate> delegate;

@end
