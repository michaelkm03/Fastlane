//
//  VActionItemTableViewCell.h
//  victorious
//
//  Created by Michael Sena on 9/26/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VActionItemTableViewCell : UITableViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detailTitle;
@property (nonatomic, strong) UIImage *actionIcon;

/**
 *  Accessory selection. A button exists under detail title and when selected this handler is called.
 */
@property (nonatomic, copy) void (^accessorySelectionHandler)(void);
@property (nonatomic, assign) UIEdgeInsets separatorInsets;

@property (nonatomic, assign) BOOL enabled;

/**
 Sets the cell in a loading state.
 */
- (void)setLoading:(BOOL)loading animated:(BOOL)animated;

@end
