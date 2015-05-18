//
//  VNoContentTableViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VNoContentTableViewCell : UITableViewCell

/**
 Hides the text view and shows the animating activity indicator,
 putting the cell into a visible loading state.
 */
@property (nonatomic, assign) BOOL isLoading;

/**
 Text that will populate the text view.  The activity indicator is hidden when
 this property is set to a non-nil value.
 */
@property (nonatomic, weak) NSString *message;

/**
 When set to YES, the textview in the cell is set to center alignment.
 When set to NO, the textview has left alignment.
 */
@property (nonatomic, assign, getter=isCentered) BOOL centered;

/**
 Convenience method that handles dequeing a cell from the provided table view.
 */
+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView;

/**
 Convenience method that allows calling code to pass in a table view and have
 the cell registration handled internally.
 */
+ (void)registerNibWithTableView:(UITableView *)tableView;

/**
 This cell has an optional action button that can be configured using this method.
 The action button is hidden by default, and will appear when this method is called.
 */
- (void)showActionButtonWithLabel:(NSString *)label callback:(void(^)(void))callback;

@end
