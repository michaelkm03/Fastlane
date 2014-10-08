//
//  VNoContentTableViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentTableViewCell.h"
#import "VThemeManager.h"

static NSString *const kVNoContentTableViewCellIdentifier = @"VNoContentTableViewCell";

@interface VNoContentTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UIView *container;

@end

@implementation VNoContentTableViewCell

- (void)setTitle:(NSString *)title message:(NSString *)message iconImageName:(NSString *)imageName
{
    self.titleLabel.text = title;
    self.messageLabel.text = message;
    [self.iconImageView setImage:[UIImage imageNamed:imageName]];
    
    self.container.hidden = NO;
    
    [self applyTheme];
}

- (void)applyTheme
{
    self.titleLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading1Font];
    self.messageLabel.font = [[VThemeManager sharedThemeManager] themedFontForKey:kVHeading4Font];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView
{
    VNoContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kVNoContentTableViewCellIdentifier];
    cell.container.hidden = YES;
    return cell;
}

+ (void)registerNibWithTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:kVNoContentTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:kVNoContentTableViewCellIdentifier];
}

@end
