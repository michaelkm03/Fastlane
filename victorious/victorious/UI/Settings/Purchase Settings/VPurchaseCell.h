//
//  VPurchaseCell.h
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VDependencyManager;

@interface VPurchaseCell : UITableViewCell

@property (weak, nonatomic) VDependencyManager *dependencyManager;

+ (void)registerNibWithTableView:(UITableView *)tableView;

- (void)setProductImage:(UIImage *)image title:(NSString *)title;

- (void)setSubscriptionImage:(UIImage *)image title:(NSString *)title localizedPrice:(NSString *)localizedPrice;

- (CGSize)cellSizeWithinBounds:(CGRect)bounds;

@end
