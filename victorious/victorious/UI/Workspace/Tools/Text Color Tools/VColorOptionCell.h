//
//  VColorOptionCell.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

@interface VColorOptionCell : VBaseCollectionViewCell

@property (nonatomic, strong) UIFont *font;

- (void)setColor:(UIColor *)color withTitle:(NSString *)title;

@end
