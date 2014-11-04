//
//  VStreamWebViewCell.m
//  victorious
//
//  Created by Patrick Lynch on 11/4/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamWebViewCell.h"
#import "VWebContentViewController.h"

@implementation VStreamWebViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.webContentViewController.urlToView = [NSURL URLWithString:@"http://www.apple.com"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
