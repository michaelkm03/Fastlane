//
//  VNoContentTableViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VNoContentTableViewCell : UITableViewCell

- (void)setMessage:(NSString *)message;

+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView;

+ (void)registerNibWithTableView:(UITableView *)tableView;

@end
