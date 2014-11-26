//
//  VNoContentTableViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VNoContentTableViewCell : UITableViewCell

@property (nonatomic, assign) BOOL isLoading;

@property (nonatomic, weak) NSString *message;

@property (nonatomic, assign) BOOL isCentered;

+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView;

+ (void)registerNibWithTableView:(UITableView *)tableView;

- (void)showActionButtonWithLabel:(NSString *)label callback:(void(^)(void))callback;

@end
