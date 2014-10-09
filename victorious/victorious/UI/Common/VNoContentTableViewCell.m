//
//  VNoContentTableViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 10/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VNoContentTableViewCell.h"
#import "VThemeManager.h"

static NSString *const kVNoContentTableViewCellIdentifier   = @"VNoContentTableViewCell";
static NSString *const kVNoContentMessageFontName           = @"Helvetica Neue Light Italic";

@interface VNoContentTableViewCell()

@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation VNoContentTableViewCell

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    self.messageLabel.hidden = NO;
    [self applyTheme];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.messageLabel.hidden = YES;
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    self.messageLabel.hidden = YES;
}

- (void)applyTheme
{
    CGFloat currentSize = self.messageLabel.font.pointSize;
    self.messageLabel.font = [UIFont fontWithName:kVNoContentMessageFontName size:currentSize];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

+ (VNoContentTableViewCell *)createCellFromTableView:(UITableView *)tableView
{
    return [tableView dequeueReusableCellWithIdentifier:kVNoContentTableViewCellIdentifier];
}

+ (void)registerNibWithTableView:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:kVNoContentTableViewCellIdentifier bundle:nil] forCellReuseIdentifier:kVNoContentTableViewCellIdentifier];
}

@end
