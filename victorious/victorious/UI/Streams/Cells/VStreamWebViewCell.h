//
//  VStreamWebViewCell.h
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VStreamViewCell.h"

@class VWebContentViewController;

NSString * const VStreamWebViewCellNibName = @"VStreamWebViewCell";

@interface VStreamWebViewCell : VStreamViewCell

@property (nonatomic, weak) IBOutlet VWebContentViewController *webContentViewController;

@end
