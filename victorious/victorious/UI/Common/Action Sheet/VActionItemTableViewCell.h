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

@property (nonatomic, copy) void (^accessorySelectionHandler)(void);

@property (nonatomic, assign) UIEdgeInsets separatorInsets;

@end
