//
//  VPurchaseCell.m
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseCell.h"
#import "VThemeManager.h"

@interface VPurchaseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;

@end

@implementation VPurchaseCell

- (void)setProductImage:(UIImage *)image withTitle:(NSString *)title
{
    self.productImageView.image = image;
    self.productTitle.text = title;
    self.productTitle.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeaderFont];
}

@end
