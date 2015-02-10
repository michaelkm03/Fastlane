//
//  VLoginButton.m
//  victorious
//
//  Created by Patrick Lynch on 2/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VLoginButton.h"

@interface VLoginButton ()

@property (nonatomic, weak) IBOutlet UILabel *label;
@property (nonatomic, weak) IBOutlet UIButton *button;

@end

@implementation VLoginButton

- (void)setEnabled:(BOOL)enabled
{
    _enabled = enabled;
    self.button.enabled = enabled;
}

- (void)setFont:(UIFont *)font
{
    self.label.font = font;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.label.textColor = textColor;
}

@end
