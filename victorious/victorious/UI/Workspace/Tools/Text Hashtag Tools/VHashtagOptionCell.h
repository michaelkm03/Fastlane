//
//  VHashtagOptionCell.h
//  victorious
//
//  Created by Patrick Lynch on 3/16/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

@interface VHashtagOptionCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) UIColor *selectedColor;
@property (nonatomic, copy) UIFont *font;

@end
