//
//  VPurchaseActionCell.h
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VButton.h"

@interface VPurchaseActionCell : UITableViewCell

@property (weak, nonatomic) IBOutlet VButton *button;

- (void)setAction:(void(^)(VPurchaseActionCell *))actionCallback;

@end
