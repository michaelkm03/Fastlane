//
//  VPurchaseCell.m
//  victorious
//
//  Created by Patrick Lynch on 12/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPurchaseCell.h"
#import "VDependencyManager.h"

@interface VPurchaseCell ()

@property (weak, nonatomic) IBOutlet UIImageView *productImageView;
@property (weak, nonatomic) IBOutlet UILabel *productTitle;
@property (weak, nonatomic) IBOutlet UITextView *productDescription;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation VPurchaseCell

+ (void)registerNibWithTableView:(UITableView *)tableView
{
    NSString *identifier = NSStringFromClass([VPurchaseCell class]);
    [tableView registerNib:[UINib nibWithNibName:identifier bundle:nil] forCellReuseIdentifier:identifier];
}

- (void)setProductImage:(UIImage *)image title:(NSString *)title
{
    self.productImageView.image = image;
    self.productTitle.attributedText = [[NSAttributedString alloc] initWithString:title ?: @"Product" attributes:self.titleAttributes];
    self.productDescription.text = nil;
}

- (void)setSubscriptionImage:(UIImage *)image title:(NSString *)title localizedPrice:(NSString *)localizedPrice
{
    self.productImageView.image = image;
    self.productTitle.attributedText = [[NSAttributedString alloc] initWithString:title ?: @"Product" attributes:self.titleAttributes];
    
    NSString *description = [NSString stringWithFormat:NSLocalizedString(@"SubscriptionDescriptionNoDateFormat", comment:nil), localizedPrice];
    NSMutableAttributedString *descriptionAttributedText = [[NSMutableAttributedString alloc] initWithString:description
                                                                                                  attributes:self.descriptionAttributes];
    NSRange priceRange = [description rangeOfString:localizedPrice ?: @"Price"];
    [descriptionAttributedText setAttributes:self.priceAttributes range:priceRange];
    self.productDescription.attributedText = descriptionAttributedText;
}

- (NSDictionary *)titleAttributes
{
    UIFont *font = [self.dependencyManager fontForKey:@"font.header"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [self.dependencyManager colorForKey:@"color.text.content"] };
}

- (NSDictionary *)descriptionAttributes
{
    UIFont *font = [self.dependencyManager fontForKey:@"font.label1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [self.dependencyManager colorForKey:@"color.text.content"] };
}

- (NSDictionary *)priceAttributes
{
    UIFont *font = [self.dependencyManager fontForKey:@"font.label1"];
    return @{ NSFontAttributeName: font ?: @"",
              NSForegroundColorAttributeName: [self.dependencyManager colorForKey:@"color.accent" ] };
}

- (NSDateFormatter *)dateFormatter
{
    if (_dateFormatter == nil)
    {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"MM/dd/YY";
    }
    return _dateFormatter;
}

- (CGSize)cellSizeWithinBounds:(CGRect)bounds
{
    CGFloat margin = CGRectGetMinY(self.productTitle.frame);
    CGFloat textMargin = self.productDescription.textContainerInset.top + self.productDescription.textContainerInset.bottom;
    CGFloat titleMaxY = CGRectGetMaxY(self.productTitle.frame);
    CGFloat descriptionHeight = [self.productDescription sizeThatFits:CGSizeMake(bounds.size.width, CGFLOAT_MAX)].height;
    return CGSizeMake(bounds.size.width, titleMaxY + textMargin + descriptionHeight + margin);
}

@end
